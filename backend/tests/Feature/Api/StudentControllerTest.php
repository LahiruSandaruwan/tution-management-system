<?php

namespace Tests\Feature\Api;

use App\Models\Student;
use App\Models\User;
use App\Models\Institute;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StudentControllerTest extends TestCase
{
    use RefreshDatabase;

    private Institute $institute;
    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->institute = Institute::factory()->create();
        $this->admin = User::factory()->admin()->create(['institute_id' => $this->institute->id]);
    }

    public function test_can_list_students(): void
    {
        Student::factory()->count(3)->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson('/api/students?institute_id=' . $this->institute->id);

        $response->assertOk()
            ->assertJsonStructure([
                'success',
                'data' => [
                    'data' => [
                        '*' => ['id', 'user_id', 'student_id_number', 'grade', 'is_active']
                    ]
                ]
            ]);
    }

    public function test_can_create_student(): void
    {
        Sanctum::actingAs($this->admin);

        $studentData = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'SecurePass123',
            'phone' => '0771234567',
            'student_id_number' => 'STU001',
            'grade' => 'Grade 10',
            'parent_name' => 'Jane Doe',
            'parent_phone' => '0779876543',
            'institute_id' => $this->institute->id,
        ];

        $response = $this->postJson('/api/students', $studentData);

        $response->assertCreated()
            ->assertJson([
                'success' => true,
                'message' => 'Student created successfully'
            ]);

        $this->assertDatabaseHas('students', [
            'student_id_number' => 'STU001',
            'grade' => 'Grade 10'
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
            'role' => 'student'
        ]);
    }

    public function test_cannot_create_student_with_duplicate_email(): void
    {
        $existingUser = User::factory()->create(['email' => 'duplicate@example.com']);

        Sanctum::actingAs($this->admin);

        $studentData = [
            'name' => 'John Doe',
            'email' => 'duplicate@example.com',
            'password' => 'SecurePass123',
            'phone' => '0771234567',
            'student_id_number' => 'STU002',
            'grade' => 'Grade 10',
            'institute_id' => $this->institute->id,
        ];

        $response = $this->postJson('/api/students', $studentData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_can_update_student(): void
    {
        $student = Student::factory()->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $updateData = [
            'name' => 'Updated Name',
            'grade' => 'Grade 11',
            'institute_id' => $this->institute->id,
        ];

        $response = $this->putJson("/api/students/{$student->id}", $updateData);

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Student updated successfully'
            ]);

        $this->assertDatabaseHas('students', [
            'id' => $student->id,
            'grade' => 'Grade 11'
        ]);

        $this->assertDatabaseHas('users', [
            'id' => $student->user_id,
            'name' => 'Updated Name'
        ]);
    }

    public function test_cannot_update_student_from_different_institute(): void
    {
        $otherInstitute = Institute::factory()->create();
        $student = Student::factory()->withInstitute($otherInstitute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->putJson("/api/students/{$student->id}", [
            'name' => 'Updated Name',
            'institute_id' => $this->institute->id,
        ]);

        $response->assertForbidden()
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized access'
            ]);
    }

    public function test_can_delete_student(): void
    {
        $student = Student::factory()->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->deleteJson("/api/students/{$student->id}?institute_id={$this->institute->id}");

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Student deleted successfully'
            ]);

        $this->assertDatabaseMissing('students', ['id' => $student->id]);
        $this->assertDatabaseMissing('users', ['id' => $student->user_id]);
    }

    public function test_can_toggle_student_status(): void
    {
        $student = Student::factory()->withInstitute($this->institute)->create(['is_active' => true]);

        Sanctum::actingAs($this->admin);

        $response = $this->postJson("/api/students/{$student->id}/toggle-status?institute_id={$this->institute->id}");

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Student status updated successfully'
            ]);

        $this->assertDatabaseHas('students', [
            'id' => $student->id,
            'is_active' => false
        ]);
    }

    public function test_can_search_students(): void
    {
        Student::factory()->withInstitute($this->institute)->create([
            'user_id' => User::factory()->student()->create([
                'name' => 'Searchable Student',
                'institute_id' => $this->institute->id
            ])
        ]);

        Student::factory()->count(2)->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/students?institute_id={$this->institute->id}&search=Searchable");

        $response->assertOk();
        $data = $response->json('data.data');

        $this->assertCount(1, $data);
        $this->assertStringContainsString('Searchable', $data[0]['user']['name']);
    }

    public function test_password_must_be_at_least_12_characters(): void
    {
        Sanctum::actingAs($this->admin);

        $studentData = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'short',
            'phone' => '0771234567',
            'student_id_number' => 'STU003',
            'grade' => 'Grade 10',
            'institute_id' => $this->institute->id,
        ];

        $response = $this->postJson('/api/students', $studentData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['password']);
    }
}
