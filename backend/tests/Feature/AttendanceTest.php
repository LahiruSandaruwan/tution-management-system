<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Institute;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\ClassModel;
use App\Models\Subject;
use App\Models\Attendance;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AttendanceTest extends TestCase
{
    use RefreshDatabase;

    protected $teacher;
    protected $student;
    protected $class;
    protected $institute;

    protected function setUp(): void
    {
        parent::setUp();

        $this->institute = Institute::create([
            'name' => 'Test Institute',
            'code' => 'TEST001',
            'address' => 'Test Address',
            'phone' => '0771234567',
            'email' => 'test@institute.com',
            'status' => 'active',
        ]);

        $teacherUser = User::create([
            'name' => 'Teacher User',
            'email' => 'teacher@test.com',
            'password' => bcrypt('password'),
            'role' => 'teacher',
            'institute_id' => $this->institute->id,
        ]);

        $this->teacher = Teacher::create([
            'user_id' => $teacherUser->id,
            'institute_id' => $this->institute->id,
            'employee_id' => 'EMP001',
            'specialization' => 'Mathematics',
            'status' => 'active',
        ]);

        $studentUser = User::create([
            'name' => 'Test Student',
            'email' => 'student@test.com',
            'password' => bcrypt('password'),
            'role' => 'student',
            'institute_id' => $this->institute->id,
        ]);

        $this->student = Student::create([
            'user_id' => $studentUser->id,
            'institute_id' => $this->institute->id,
            'student_id_number' => 'STU001',
            'grade' => 'Grade 10',
            'date_of_birth' => '2005-01-01',
            'status' => 'active',
        ]);

        $subject = Subject::create([
            'institute_id' => $this->institute->id,
            'name' => 'Mathematics',
            'code' => 'MATH101',
        ]);

        $this->class = ClassModel::create([
            'institute_id' => $this->institute->id,
            'subject_id' => $subject->id,
            'teacher_id' => $this->teacher->id,
            'name' => 'Grade 10 Math',
            'grade' => 'Grade 10',
            'schedule' => 'Monday 3:00 PM',
            'status' => 'active',
        ]);

        $this->class->students()->attach($this->student->id);
    }

    /** @test */
    public function teacher_can_mark_attendance()
    {
        $token = $this->teacher->user->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/attendance/mark', [
                'class_id' => $this->class->id,
                'student_id' => $this->student->id,
                'date' => now()->format('Y-m-d'),
                'status' => 'present',
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data',
            ]);

        $this->assertDatabaseHas('attendances', [
            'class_id' => $this->class->id,
            'student_id' => $this->student->id,
            'status' => 'present',
        ]);
    }

    /** @test */
    public function teacher_can_mark_bulk_attendance()
    {
        $student2User = User::create([
            'name' => 'Student 2',
            'email' => 'student2@test.com',
            'password' => bcrypt('password'),
            'role' => 'student',
            'institute_id' => $this->institute->id,
        ]);

        $student2 = Student::create([
            'user_id' => $student2User->id,
            'institute_id' => $this->institute->id,
            'student_id_number' => 'STU002',
            'grade' => 'Grade 10',
            'date_of_birth' => '2005-02-01',
            'status' => 'active',
        ]);

        $this->class->students()->attach($student2->id);

        $token = $this->teacher->user->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/attendance/mark-bulk', [
                'class_id' => $this->class->id,
                'date' => now()->format('Y-m-d'),
                'attendances' => [
                    [
                        'student_id' => $this->student->id,
                        'status' => 'present',
                    ],
                    [
                        'student_id' => $student2->id,
                        'status' => 'absent',
                    ],
                ],
            ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('attendances', [
            'student_id' => $this->student->id,
            'status' => 'present',
        ]);

        $this->assertDatabaseHas('attendances', [
            'student_id' => $student2->id,
            'status' => 'absent',
        ]);
    }

    /** @test */
    public function can_get_class_attendance()
    {
        Attendance::create([
            'institute_id' => $this->institute->id,
            'class_id' => $this->class->id,
            'student_id' => $this->student->id,
            'date' => now(),
            'status' => 'present',
        ]);

        $token = $this->teacher->user->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/attendance/class/{$this->class->id}?date=" . now()->format('Y-m-d'));

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['student_id', 'status', 'date'],
                ],
            ]);
    }

    /** @test */
    public function can_get_student_attendance_summary()
    {
        Attendance::create([
            'institute_id' => $this->institute->id,
            'class_id' => $this->class->id,
            'student_id' => $this->student->id,
            'date' => now(),
            'status' => 'present',
        ]);

        $token = $this->student->user->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/attendance/student/{$this->student->id}/summary");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'total_days',
                    'present_days',
                    'absent_days',
                    'attendance_percentage',
                ],
            ]);
    }

    /** @test */
    public function attendance_status_must_be_valid()
    {
        $token = $this->teacher->user->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/attendance/mark', [
                'class_id' => $this->class->id,
                'student_id' => $this->student->id,
                'date' => now()->format('Y-m-d'),
                'status' => 'invalid_status', // Invalid
            ]);

        $response->assertStatus(422);
    }
}
