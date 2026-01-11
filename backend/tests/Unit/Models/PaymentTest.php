<?php

namespace Tests\Unit\Models;

use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentTest extends TestCase
{
    use RefreshDatabase;

    public function test_payment_belongs_to_student(): void
    {
        $payment = Payment::factory()->create();

        $this->assertInstanceOf(Student::class, $payment->student);
    }

    public function test_payment_belongs_to_class(): void
    {
        $payment = Payment::factory()->create();

        $this->assertInstanceOf(ClassModel::class, $payment->class);
    }

    public function test_payment_belongs_to_institute(): void
    {
        $payment = Payment::factory()->create();

        $this->assertInstanceOf(Institute::class, $payment->institute);
    }

    public function test_payment_can_have_received_by_user(): void
    {
        $receivedBy = User::factory()->admin()->create();
        $payment = Payment::factory()->paid()->create(['received_by' => $receivedBy->id]);

        $this->assertInstanceOf(User::class, $payment->receivedBy);
        $this->assertEquals($receivedBy->id, $payment->receivedBy->id);
    }

    public function test_payment_has_correct_status(): void
    {
        $pendingPayment = Payment::factory()->pending()->create();
        $paidPayment = Payment::factory()->paid()->create();

        $this->assertEquals('pending', $pendingPayment->status);
        $this->assertEquals('paid', $paidPayment->status);
    }

    public function test_payment_can_be_overdue(): void
    {
        $overduePayment = Payment::factory()->overdue()->create();

        $this->assertEquals('pending', $overduePayment->status);
        $this->assertTrue($overduePayment->due_date < now());
    }

    public function test_payment_has_fillable_attributes(): void
    {
        $fillable = [
            'student_id',
            'class_id',
            'institute_id',
            'amount',
            'due_date',
            'paid_date',
            'payment_method',
            'status',
            'month',
            'year',
            'received_by',
            'remarks',
        ];

        $payment = new Payment();

        $this->assertEquals($fillable, $payment->getFillable());
    }

    public function test_payment_method_is_set_when_paid(): void
    {
        $paidPayment = Payment::factory()->paid()->create();

        $this->assertNotNull($paidPayment->payment_method);
        $this->assertContains($paidPayment->payment_method, ['cash', 'card', 'bank_transfer', 'online']);
    }

    public function test_pending_payment_has_no_paid_date(): void
    {
        $pendingPayment = Payment::factory()->pending()->create();

        $this->assertNull($pendingPayment->paid_date);
        $this->assertNull($pendingPayment->payment_method);
    }
}
