<?php

namespace Tests\Unit\Services;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Student;
use App\Services\AttendanceService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AttendanceServiceTest extends TestCase
{
    use RefreshDatabase;

    private AttendanceService $service;
    private Institute $institute;
    private Student $student;
    private ClassModel $class;

    protected function setUp(): void
    {
        parent::setUp();

        $this->service = new AttendanceService();
        $this->institute = Institute::factory()->create();
        $this->student = Student::factory()->withInstitute($this->institute)->create();
        $this->class = ClassModel::factory()->withInstitute($this->institute)->create();
    }

    public function test_can_get_student_attendance_summary(): void
    {
        // Create attendance records
        Attendance::factory()->count(5)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'present',
            'date' => now()->startOfMonth(),
        ]);

        Attendance::factory()->count(2)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'absent',
            'date' => now()->startOfMonth(),
        ]);

        Attendance::factory()->count(1)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'late',
            'date' => now()->startOfMonth(),
        ]);

        $summary = $this->service->getStudentAttendanceSummary(
            $this->student->id,
            now()->format('m'),
            now()->format('Y')
        );

        $this->assertArrayHasKey('total', $summary);
        $this->assertArrayHasKey('present', $summary);
        $this->assertArrayHasKey('absent', $summary);
        $this->assertArrayHasKey('late', $summary);
        $this->assertArrayHasKey('percentage', $summary);

        $this->assertEquals(8, $summary['total']);
        $this->assertEquals(5, $summary['present']);
        $this->assertEquals(2, $summary['absent']);
        $this->assertEquals(1, $summary['late']);
        $this->assertEquals(62.5, $summary['percentage']); // 5/8 * 100
    }

    public function test_attendance_percentage_calculation(): void
    {
        Attendance::factory()->count(8)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'present',
            'date' => now()->startOfMonth(),
        ]);

        Attendance::factory()->count(2)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'absent',
            'date' => now()->startOfMonth(),
        ]);

        $summary = $this->service->getStudentAttendanceSummary(
            $this->student->id,
            now()->format('m'),
            now()->format('Y')
        );

        $this->assertEquals(80.0, $summary['percentage']); // 8/10 * 100
    }

    public function test_returns_zero_for_student_with_no_attendance(): void
    {
        $summary = $this->service->getStudentAttendanceSummary(
            $this->student->id,
            now()->format('m'),
            now()->format('Y')
        );

        $this->assertEquals(0, $summary['total']);
        $this->assertEquals(0, $summary['present']);
        $this->assertEquals(0, $summary['absent']);
        $this->assertEquals(0, $summary['late']);
        $this->assertEquals(0, $summary['percentage']);
    }

    public function test_filters_attendance_by_month_and_year(): void
    {
        // Current month
        Attendance::factory()->count(5)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'present',
            'date' => now(),
        ]);

        // Previous month
        Attendance::factory()->count(3)->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'present',
            'date' => now()->subMonth(),
        ]);

        $currentMonthSummary = $this->service->getStudentAttendanceSummary(
            $this->student->id,
            now()->format('m'),
            now()->format('Y')
        );

        $previousMonthSummary = $this->service->getStudentAttendanceSummary(
            $this->student->id,
            now()->subMonth()->format('m'),
            now()->subMonth()->format('Y')
        );

        $this->assertEquals(5, $currentMonthSummary['total']);
        $this->assertEquals(3, $previousMonthSummary['total']);
    }

    public function test_can_mark_bulk_attendance(): void
    {
        $students = Student::factory()->count(5)->withInstitute($this->institute)->create();

        $attendanceData = $students->map(fn ($student) => [
            'student_id' => $student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'status' => 'present',
            'date' => now()->format('Y-m-d'),
        ])->toArray();

        $result = $this->service->markBulkAttendance($attendanceData);

        $this->assertTrue($result);
        $this->assertDatabaseCount('attendances', 5);

        foreach ($students as $student) {
            $this->assertDatabaseHas('attendances', [
                'student_id' => $student->id,
                'status' => 'present',
            ]);
        }
    }

    public function test_calculates_class_attendance_rate(): void
    {
        $students = Student::factory()->count(10)->withInstitute($this->institute)->create();

        // 7 students present
        foreach ($students->take(7) as $student) {
            Attendance::factory()->create([
                'student_id' => $student->id,
                'class_id' => $this->class->id,
                'institute_id' => $this->institute->id,
                'status' => 'present',
                'date' => now(),
            ]);
        }

        // 3 students absent
        foreach ($students->skip(7) as $student) {
            Attendance::factory()->create([
                'student_id' => $student->id,
                'class_id' => $this->class->id,
                'institute_id' => $this->institute->id,
                'status' => 'absent',
                'date' => now(),
            ]);
        }

        $rate = $this->service->getClassAttendanceRate($this->class->id, now()->format('Y-m-d'));

        $this->assertEquals(70.0, $rate); // 7/10 * 100
    }
}
