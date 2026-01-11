<?php

namespace Tests\Feature\Api;

use App\Models\Institute;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TeacherControllerTest extends TestCase
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

    public function test_can_list_teachers(): void
    {
        Teacher::factory()->count(3)->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson('/api/teachers?institute_id=' . $this->institute->id);

        $response->assertOk()
            ->assertJsonStructure([
                'success',
                'data' => [
                    'data' => [
                        '*' => ['id', 'user_id', 'subject_specialization', 'is_active'],
                    ],
                ],
            ]);
    }

    public function test_can_create_teacher(): void
    {
        Sanctum::actingAs($this->admin);

        $teacherData = [
            'name' => 'John Teacher',
            'email' => 'teacher@example.com',
            'password' => 'SecurePass123',
            'phone' => '0771234567',
            'subject_specialization' => 'Mathematics',
            'qualification' => 'B.Sc. in Mathematics',
            'institute_id' => $this->institute->id,
        ];

        $response = $this->postJson('/api/teachers', $teacherData);

        $response->assertCreated()
            ->assertJson([
                'success' => true,
                'message' => 'Teacher created successfully',
            ]);

        $this->assertDatabaseHas('teachers', [
            'subject_specialization' => 'Mathematics',
            'qualification' => 'B.Sc. in Mathematics',
        ]);

        $this->assertDatabaseHas('users', [
            'email' => 'teacher@example.com',
            'role' => 'teacher',
        ]);
    }

    public function test_can_update_teacher(): void
    {
        $teacher = Teacher::factory()->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $updateData = [
            'name' => 'Updated Teacher Name',
            'subject_specialization' => 'Science',
            'institute_id' => $this->institute->id,
        ];

        $response = $this->putJson("/api/teachers/{$teacher->id}", $updateData);

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Teacher updated successfully',
            ]);

        $this->assertDatabaseHas('teachers', [
            'id' => $teacher->id,
            'subject_specialization' => 'Science',
        ]);
    }

    public function test_cannot_update_teacher_from_different_institute(): void
    {
        $otherInstitute = Institute::factory()->create();
        $teacher = Teacher::factory()->withInstitute($otherInstitute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->putJson("/api/teachers/{$teacher->id}", [
            'name' => 'Updated Name',
            'institute_id' => $this->institute->id,
        ]);

        $response->assertForbidden()
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized access',
            ]);
    }

    public function test_can_delete_teacher(): void
    {
        $teacher = Teacher::factory()->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->deleteJson("/api/teachers/{$teacher->id}?institute_id={$this->institute->id}");

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Teacher deleted successfully',
            ]);

        $this->assertDatabaseMissing('teachers', ['id' => $teacher->id]);
        $this->assertDatabaseMissing('users', ['id' => $teacher->user_id]);
    }

    public function test_can_toggle_teacher_status(): void
    {
        $teacher = Teacher::factory()->withInstitute($this->institute)->create(['is_active' => true]);

        Sanctum::actingAs($this->admin);

        $response = $this->postJson("/api/teachers/{$teacher->id}/toggle-status?institute_id={$this->institute->id}");

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Teacher status updated successfully',
            ]);

        $this->assertDatabaseHas('teachers', [
            'id' => $teacher->id,
            'is_active' => false,
        ]);
    }

    public function test_can_filter_teachers_by_active_status(): void
    {
        Teacher::factory()->withInstitute($this->institute)->create(['is_active' => true]);
        Teacher::factory()->count(2)->inactive()->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/teachers?institute_id={$this->institute->id}&is_active=1");

        $response->assertOk();
        $data = $response->json('data.data');

        $this->assertCount(1, $data);
        $this->assertTrue($data[0]['is_active']);
    }

    public function test_can_search_teachers_by_name(): void
    {
        Teacher::factory()->withInstitute($this->institute)->create([
            'user_id' => User::factory()->teacher()->create([
                'name' => 'Searchable Teacher',
                'institute_id' => $this->institute->id,
            ]),
        ]);

        Teacher::factory()->count(2)->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/teachers?institute_id={$this->institute->id}&search=Searchable");

        $response->assertOk();
        $data = $response->json('data.data');

        $this->assertCount(1, $data);
        $this->assertStringContainsString('Searchable', $data[0]['user']['name']);
    }
}
