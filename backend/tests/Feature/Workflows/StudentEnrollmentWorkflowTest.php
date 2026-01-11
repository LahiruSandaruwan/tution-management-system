<?php

namespace Tests\Feature\Workflows;

use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StudentEnrollmentWorkflowTest extends TestCase
{
    use RefreshDatabase;

    private Institute $institute;
    private User $admin;
    private Student $student;
    private ClassModel $class;

    protected function setUp(): void
    {
        parent::setUp();

        $this->institute = Institute::factory()->create();
        $this->admin = User::factory()->admin()->create(['institute_id' => $this->institute->id]);
        $this->student = Student::factory()->withInstitute($this->institute)->create();
        $this->class = ClassModel::factory()->withInstitute($this->institute)->create();
    }

    public function test_complete_student_enrollment_workflow(): void
    {
        Sanctum::actingAs($this->admin);

        // Step 1: Enroll student in class
        $enrollResponse = $this->postJson("/api/classes/{$this->class->id}/enroll", [
            'student_id' => $this->student->id,
            'institute_id' => $this->institute->id,
        ]);

        $enrollResponse->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Student enrolled successfully',
            ]);

        // Verify enrollment
        $this->assertDatabaseHas('class_student', [
            'class_id' => $this->class->id,
            'student_id' => $this->student->id,
        ]);

        // Step 2: Verify student appears in class students list
        $studentsResponse = $this->getJson("/api/classes/{$this->class->id}/students?institute_id={$this->institute->id}");

        $studentsResponse->assertOk();
        $students = $studentsResponse->json('data');

        $this->assertCount(1, $students);
        $this->assertEquals($this->student->id, $students[0]['id']);

        // Step 3: Create payment for the enrolled student
        $paymentData = [
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => $this->class->class_fee,
            'due_date' => now()->addDays(7)->format('Y-m-d'),
            'month' => now()->format('m'),
            'year' => now()->format('Y'),
        ];

        $paymentResponse = $this->postJson('/api/payments', $paymentData);

        $paymentResponse->assertCreated()
            ->assertJson([
                'success' => true,
                'message' => 'Payment created successfully',
            ]);

        // Step 4: Verify payment in student's payment list
        $studentPaymentsResponse = $this->getJson("/api/students/{$this->student->id}?institute_id={$this->institute->id}");

        $studentPaymentsResponse->assertOk();

        // Step 5: Unenroll student
        $unenrollResponse = $this->deleteJson("/api/classes/{$this->class->id}/unenroll/{$this->student->id}?institute_id={$this->institute->id}");

        $unenrollResponse->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Student unenrolled successfully',
            ]);

        // Verify unenrollment
        $this->assertDatabaseMissing('class_student', [
            'class_id' => $this->class->id,
            'student_id' => $this->student->id,
        ]);
    }

    public function test_cannot_enroll_student_from_different_institute(): void
    {
        $otherInstitute = Institute::factory()->create();
        $otherStudent = Student::factory()->withInstitute($otherInstitute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->postJson("/api/classes/{$this->class->id}/enroll", [
            'student_id' => $otherStudent->id,
            'institute_id' => $this->institute->id,
        ]);

        $response->assertForbidden()
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized access',
            ]);
    }

    public function test_cannot_enroll_student_in_class_from_different_institute(): void
    {
        $otherInstitute = Institute::factory()->create();
        $otherClass = ClassModel::factory()->withInstitute($otherInstitute)->create();

        Sanctum::actingAs($this->admin);

        $response = $this->postJson("/api/classes/{$otherClass->id}/enroll", [
            'student_id' => $this->student->id,
            'institute_id' => $this->institute->id,
        ]);

        $response->assertForbidden();
    }

    public function test_student_can_be_enrolled_in_multiple_classes(): void
    {
        $class2 = ClassModel::factory()->withInstitute($this->institute)->create();

        Sanctum::actingAs($this->admin);

        // Enroll in first class
        $this->postJson("/api/classes/{$this->class->id}/enroll", [
            'student_id' => $this->student->id,
            'institute_id' => $this->institute->id,
        ])->assertOk();

        // Enroll in second class
        $this->postJson("/api/classes/{$class2->id}/enroll", [
            'student_id' => $this->student->id,
            'institute_id' => $this->institute->id,
        ])->assertOk();

        // Verify enrollments
        $this->assertDatabaseHas('class_student', [
            'class_id' => $this->class->id,
            'student_id' => $this->student->id,
        ]);

        $this->assertDatabaseHas('class_student', [
            'class_id' => $class2->id,
            'student_id' => $this->student->id,
        ]);

        // Verify student shows in both class lists
        $student = Student::find($this->student->id);
        $this->assertCount(2, $student->classes);
    }
}
