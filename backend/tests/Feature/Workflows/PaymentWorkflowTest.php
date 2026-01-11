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

class PaymentWorkflowTest extends TestCase
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

    public function test_complete_payment_lifecycle(): void
    {
        Sanctum::actingAs($this->admin);

        // Step 1: Create payment
        $paymentData = [
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => 2000.00,
            'due_date' => now()->addDays(7)->format('Y-m-d'),
            'month' => now()->format('m'),
            'year' => now()->format('Y'),
        ];

        $createResponse = $this->postJson('/api/payments', $paymentData);

        $createResponse->assertCreated()
            ->assertJson([
                'success' => true,
                'message' => 'Payment created successfully',
            ]);

        $paymentId = $createResponse->json('data.id');

        // Verify payment is pending
        $this->assertDatabaseHas('payments', [
            'id' => $paymentId,
            'status' => 'pending',
            'paid_date' => null,
        ]);

        // Step 2: Record payment
        $recordData = [
            'payment_method' => 'cash',
            'institute_id' => $this->institute->id,
        ];

        $recordResponse = $this->postJson("/api/payments/{$paymentId}/record", $recordData);

        $recordResponse->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Payment recorded successfully',
            ]);

        // Verify payment is now paid
        $this->assertDatabaseHas('payments', [
            'id' => $paymentId,
            'status' => 'paid',
            'payment_method' => 'cash',
            'received_by' => $this->admin->id,
        ]);

        $payment = Payment::find($paymentId);
        $this->assertNotNull($payment->paid_date);

        // Step 3: Get payment details
        $detailsResponse = $this->getJson("/api/payments/{$paymentId}?institute_id={$this->institute->id}");

        $detailsResponse->assertOk()
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $paymentId,
                    'status' => 'paid',
                    'amount' => '2000.00',
                ],
            ]);
    }

    public function test_can_filter_pending_payments(): void
    {
        Payment::factory()->count(3)->pending()->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
        ]);

        Payment::factory()->count(2)->paid()->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/payments?institute_id={$this->institute->id}&status=pending");

        $response->assertOk();
        $data = $response->json('data.data');

        $this->assertCount(3, $data);
        foreach ($data as $payment) {
            $this->assertEquals('pending', $payment['status']);
        }
    }

    public function test_can_identify_overdue_payments(): void
    {
        $overduePayment = Payment::factory()->overdue()->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/payments?institute_id={$this->institute->id}&status=pending");

        $response->assertOk();
        $data = $response->json('data.data');

        $foundOverdue = false;
        foreach ($data as $payment) {
            if ($payment['id'] === $overduePayment->id) {
                $foundOverdue = true;
                $this->assertEquals('pending', $payment['status']);
                $this->assertTrue(strtotime($payment['due_date']) < time());
            }
        }

        $this->assertTrue($foundOverdue, 'Overdue payment should be in the pending list');
    }

    public function test_cannot_record_payment_twice(): void
    {
        $payment = Payment::factory()->paid()->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->postJson("/api/payments/{$payment->id}/record", [
            'payment_method' => 'cash',
            'institute_id' => $this->institute->id,
        ]);

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
                'message' => 'Payment already recorded',
            ]);
    }

    public function test_can_search_payments_by_student(): void
    {
        $otherStudent = Student::factory()->withInstitute($this->institute)->create();

        Payment::factory()->count(3)->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
        ]);

        Payment::factory()->count(2)->create([
            'institute_id' => $this->institute->id,
            'student_id' => $otherStudent->id,
            'class_id' => $this->class->id,
        ]);

        Sanctum::actingAs($this->admin);

        $response = $this->getJson("/api/payments?institute_id={$this->institute->id}&student_id={$this->student->id}");

        $response->assertOk();
        $data = $response->json('data.data');

        $this->assertCount(3, $data);
        foreach ($data as $payment) {
            $this->assertEquals($this->student->id, $payment['student_id']);
        }
    }

    public function test_payment_amount_validation(): void
    {
        Sanctum::actingAs($this->admin);

        $paymentData = [
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => -100, // Invalid: negative amount
            'due_date' => now()->addDays(7)->format('Y-m-d'),
            'month' => now()->format('m'),
            'year' => now()->format('Y'),
        ];

        $response = $this->postJson('/api/payments', $paymentData);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['amount']);
    }
}
