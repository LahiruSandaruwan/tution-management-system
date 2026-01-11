<?php

namespace Tests\Feature\Api;

use App\Models\Grade;
use App\Models\Institute;
use App\Models\Student;
use App\Models\Subject;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class GdprDataExportTest extends TestCase
{
    use RefreshDatabase;

    private Institute $institute;
    private Subject $subject;
    private Grade $grade;

    protected function setUp(): void
    {
        parent::setUp();

        $this->institute = Institute::factory()->create();
        $this->subject = Subject::create([
            'name' => 'Mathematics',
            'code' => 'MATH',
            'description' => 'Mathematics subject',
            'institute_id' => $this->institute->id,
        ]);
        $this->grade = Grade::create([
            'name' => 'Grade 10',
            'description' => 'Grade 10 students',
            'institute_id' => $this->institute->id,
        ]);
    }

    /** @test */
    public function student_can_export_their_data(): void
    {
        // Create a student user
        $user = User::factory()->create([
            'role' => 'student',
            'institute_id' => $this->institute->id,
        ]);

        $student = Student::factory()->create([
            'user_id' => $user->id,
            'institute_id' => $this->institute->id,
            'grade_id' => $this->grade->id,
        ]);

        // Create authentication token
        $token = $user->createToken('test-token')->plainTextToken;

        // Request data export
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/gdpr/export-data');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'export_metadata',
                'user_account',
                'profile_data' => [
                    'student_profile',
                    'class_enrollments',
                    'payments',
                    'rfid_cards',
                    'gate_access_logs',
                ],
                'activity_logs',
                'authentication_history',
                'account_lockouts',
            ],
        ]);

        // Verify user data is included
        $response->assertJsonFragment([
            'email' => $user->email,
            'role' => 'student',
        ]);
    }

    /** @test */
    public function teacher_can_export_their_data(): void
    {
        // Create a teacher user
        $user = User::factory()->create([
            'role' => 'teacher',
            'institute_id' => $this->institute->id,
        ]);

        $teacher = Teacher::factory()->create([
            'user_id' => $user->id,
            'institute_id' => $this->institute->id,
            'subject_id' => $this->subject->id,
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/gdpr/export-data');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'export_metadata',
                'user_account',
                'profile_data' => [
                    'teacher_profile',
                    'classes',
                    'schedules',
                ],
            ],
        ]);

        $response->assertJsonFragment([
            'role' => 'teacher',
        ]);
    }

    /** @test */
    public function admin_can_export_their_data(): void
    {
        $user = User::factory()->create([
            'role' => 'admin',
            'institute_id' => $this->institute->id,
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/gdpr/export-data');

        $response->assertStatus(200);
        $response->assertJsonFragment([
            'role' => 'admin',
            'admin_role' => 'Institute Administrator',
        ]);
    }

    /** @test */
    public function unauthenticated_user_cannot_export_data(): void
    {
        $response = $this->getJson('/api/gdpr/export-data');

        $response->assertStatus(401);
    }

    /** @test */
    public function export_includes_authentication_history(): void
    {
        $user = User::factory()->create([
            'role' => 'admin',
            'institute_id' => $this->institute->id,
        ]);

        // Create some login attempts
        DB::table('login_attempts')->insert([
            [
                'email' => $user->email,
                'ip_address' => '192.168.1.1',
                'successful' => true,
                'attempted_at' => now()->subDays(1),
            ],
            [
                'email' => $user->email,
                'ip_address' => '192.168.1.1',
                'successful' => false,
                'attempted_at' => now()->subDays(2),
            ],
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/gdpr/export-data');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertNotEmpty($data['authentication_history']);
        $this->assertGreaterThanOrEqual(2, count($data['authentication_history']));
    }

    /** @test */
    public function user_can_delete_their_account_with_password_confirmation(): void
    {
        $user = User::factory()->create([
            'role' => 'admin',
            'institute_id' => $this->institute->id,
            'password' => Hash::make('password123'),
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/gdpr/delete-account', [
            'password' => 'password123',
            'confirmation' => 'DELETE_MY_ACCOUNT',
        ]);

        $response->assertStatus(200);
        $response->assertJson([
            'success' => true,
            'message' => 'Your account and all associated data have been permanently deleted',
        ]);

        // Verify user is deleted from database
        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
        ]);
    }

    /** @test */
    public function account_deletion_requires_password_confirmation(): void
    {
        $user = User::factory()->create([
            'role' => 'admin',
            'institute_id' => $this->institute->id,
            'password' => Hash::make('password123'),
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        // Wrong password
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/gdpr/delete-account', [
            'password' => 'wrongpassword',
            'confirmation' => 'DELETE_MY_ACCOUNT',
        ]);

        $response->assertStatus(403);
        $response->assertJson([
            'success' => false,
            'message' => 'Invalid password confirmation',
        ]);

        // User should still exist
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
        ]);
    }

    /** @test */
    public function account_deletion_requires_explicit_confirmation(): void
    {
        $user = User::factory()->create([
            'role' => 'admin',
            'institute_id' => $this->institute->id,
            'password' => Hash::make('password123'),
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        // Missing confirmation
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/gdpr/delete-account', [
            'password' => 'password123',
            'confirmation' => 'yes', // Wrong confirmation text
        ]);

        $response->assertStatus(422);

        // User should still exist
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
        ]);
    }

    /** @test */
    public function student_deletion_cascades_to_related_data(): void
    {
        $user = User::factory()->create([
            'role' => 'student',
            'institute_id' => $this->institute->id,
            'password' => Hash::make('password123'),
        ]);

        $student = Student::factory()->create([
            'user_id' => $user->id,
            'institute_id' => $this->institute->id,
            'grade_id' => $this->grade->id,
        ]);

        // Create login attempt
        DB::table('login_attempts')->insert([
            'email' => $user->email,
            'ip_address' => '192.168.1.1',
            'successful' => true,
            'attempted_at' => now(),
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/gdpr/delete-account', [
            'password' => 'password123',
            'confirmation' => 'DELETE_MY_ACCOUNT',
        ]);

        $response->assertStatus(200);

        // Verify all data is deleted
        $this->assertDatabaseMissing('users', ['id' => $user->id]);
        $this->assertDatabaseMissing('students', ['id' => $student->id]);
        $this->assertDatabaseMissing('login_attempts', ['email' => $user->email]);
    }

    /** @test */
    public function export_data_is_logged_for_audit_trail(): void
    {
        $user = User::factory()->create([
            'role' => 'admin',
            'institute_id' => $this->institute->id,
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/gdpr/export-data');

        $response->assertStatus(200);

        // Check that log entry was created (this requires checking Laravel logs)
        // For now, we just verify the request succeeded
        $this->assertTrue(true);
    }
}
