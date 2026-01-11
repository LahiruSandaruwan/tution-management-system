<?php

namespace Tests\Feature\Api;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Payment;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DashboardControllerTest extends TestCase
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

    public function test_can_get_dashboard_statistics(): void
    {
        // Create test data
        Student::factory()->count(10)->withInstitute($this->institute)->create();
        Teacher::factory()->count(5)->withInstitute($this->institute)->create();
        ClassModel::factory()->count(8)->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/dashboard/statistics?institute_id={$this->institute->id}");

        $response->assertOk()
            ->assertJsonStructure([
                'success',
                'data' => [
                    'total_students',
                    'total_teachers',
                    'total_classes',
                    'active_students',
                    'active_teachers',
                    'active_classes',
                ],
            ]);

        $data = $response->json('data');

        $this->assertEquals(10, $data['total_students']);
        $this->assertEquals(5, $data['total_teachers']);
        $this->assertEquals(8, $data['total_classes']);
    }

    public function test_dashboard_shows_attendance_summary(): void
    {
        $students = Student::factory()->count(10)->withInstitute($this->institute)->create();
        $class = ClassModel::factory()->withInstitute($this->institute)->create();

        // Mark 7 present, 2 absent, 1 late
        foreach ($students->take(7) as $student) {
            Attendance::factory()->present()->create([
                'student_id' => $student->id,
                'class_id' => $class->id,
                'institute_id' => $this->institute->id,
                'date' => now(),
            ]);
        }

        foreach ($students->skip(7)->take(2) as $student) {
            Attendance::factory()->absent()->create([
                'student_id' => $student->id,
                'class_id' => $class->id,
                'institute_id' => $this->institute->id,
                'date' => now(),
            ]);
        }

        Attendance::factory()->late()->create([
            'student_id' => $students->last()->id,
            'class_id' => $class->id,
            'institute_id' => $this->institute->id,
            'date' => now(),
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/dashboard/statistics?institute_id={$this->institute->id}");

        $response->assertOk();
        $data = $response->json('data');

        $this->assertArrayHasKey('attendance', $data);
        $this->assertEquals(10, $data['attendance']['total_marked']);
        $this->assertEquals(7, $data['attendance']['present']);
        $this->assertEquals(2, $data['attendance']['absent']);
        $this->assertEquals(1, $data['attendance']['late']);
    }

    public function test_dashboard_shows_payment_summary(): void
    {
        $student = Student::factory()->withInstitute($this->institute)->create();
        $class = ClassModel::factory()->withInstitute($this->institute)->create();

        Payment::factory()->count(15)->paid()->create([
            'student_id' => $student->id,
            'class_id' => $class->id,
            'institute_id' => $this->institute->id,
            'amount' => 2000,
        ]);

        Payment::factory()->count(5)->pending()->create([
            'student_id' => $student->id,
            'class_id' => $class->id,
            'institute_id' => $this->institute->id,
            'amount' => 2000,
        ]);

        Payment::factory()->count(3)->overdue()->create([
            'student_id' => $student->id,
            'class_id' => $class->id,
            'institute_id' => $this->institute->id,
            'amount' => 2000,
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/dashboard/statistics?institute_id={$this->institute->id}");

        $response->assertOk();
        $data = $response->json('data');

        $this->assertArrayHasKey('payments', $data);
        $this->assertEquals(30000, $data['payments']['total_collected']); // 15 * 2000
        $this->assertEquals(10000, $data['payments']['total_pending']); // 5 * 2000
        $this->assertEquals(6000, $data['payments']['total_overdue']); // 3 * 2000
    }

    public function test_dashboard_filters_by_institute(): void
    {
        $otherInstitute = Institute::factory()->create();

        // This institute's data
        Student::factory()->count(5)->withInstitute($this->institute)->create();

        // Other institute's data (should not appear)
        Student::factory()->count(10)->withInstitute($otherInstitute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/dashboard/statistics?institute_id={$this->institute->id}");

        $response->assertOk();
        $data = $response->json('data');

        $this->assertEquals(5, $data['total_students']);
    }

    public function test_dashboard_shows_recent_activities(): void
    {
        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/dashboard/recent-activities?institute_id={$this->institute->id}");

        $response->assertOk()
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'description', 'created_at'],
                ],
            ]);
    }

    public function test_requires_authentication(): void
    {
        $response = $this->getJson("/api/dashboard/statistics?institute_id={$this->institute->id}");

        $response->assertUnauthorized();
    }

    public function test_dashboard_shows_monthly_revenue_trend(): void
    {
        $currentMonth = now()->format('m');
        $currentYear = now()->format('Y');

        Payment::factory()->count(20)->paid()->create([
            'institute_id' => $this->institute->id,
            'amount' => 1500,
            'month' => $currentMonth,
            'year' => $currentYear,
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/dashboard/statistics?institute_id={$this->institute->id}");

        $response->assertOk();
        $data = $response->json('data');

        $this->assertArrayHasKey('monthly_revenue', $data);
        $this->assertEquals(30000, $data['monthly_revenue']); // 20 * 1500
    }
}
