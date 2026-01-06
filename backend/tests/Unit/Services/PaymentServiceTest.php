<?php

namespace Tests\Unit\Services;

use App\Models\Payment;
use App\Models\Student;
use App\Models\ClassModel;
use App\Models\Institute;
use App\Services\PaymentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentServiceTest extends TestCase
{
    use RefreshDatabase;

    private PaymentService $service;
    private Institute $institute;
    private Student $student;
    private ClassModel $class;

    protected function setUp(): void
    {
        parent::setUp();

        $this->service = new PaymentService();
        $this->institute = Institute::factory()->create();
        $this->student = Student::factory()->withInstitute($this->institute)->create();
        $this->class = ClassModel::factory()->withInstitute($this->institute)->create();
    }

    public function test_can_get_student_payment_summary(): void
    {
        // Create paid payments
        Payment::factory()->count(5)->paid()->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => 1000,
        ]);

        // Create pending payments
        Payment::factory()->count(2)->pending()->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => 1000,
        ]);

        // Create overdue payment
        Payment::factory()->count(1)->overdue()->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => 1000,
        ]);

        $summary = $this->service->getStudentPaymentSummary($this->student->id);

        $this->assertArrayHasKey('total_paid', $summary);
        $this->assertArrayHasKey('total_pending', $summary);
        $this->assertArrayHasKey('total_overdue', $summary);
        $this->assertArrayHasKey('payment_count', $summary);

        $this->assertEquals(5000, $summary['total_paid']); // 5 * 1000
        $this->assertEquals(2000, $summary['total_pending']); // 2 * 1000
        $this->assertEquals(1000, $summary['total_overdue']); // 1 * 1000
        $this->assertEquals(8, $summary['payment_count']);
    }

    public function test_returns_zero_for_student_with_no_payments(): void
    {
        $summary = $this->service->getStudentPaymentSummary($this->student->id);

        $this->assertEquals(0, $summary['total_paid']);
        $this->assertEquals(0, $summary['total_pending']);
        $this->assertEquals(0, $summary['total_overdue']);
        $this->assertEquals(0, $summary['payment_count']);
    }

    public function test_can_calculate_monthly_revenue(): void
    {
        $currentMonth = now()->format('m');
        $currentYear = now()->format('Y');

        Payment::factory()->count(10)->paid()->create([
            'student_id' => $this->student->id,
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
            'amount' => 2000,
            'month' => $currentMonth,
            'year' => $currentYear,
        ]);

        $revenue = $this->service->getMonthlyRevenue($this->institute->id, $currentMonth, $currentYear);

        $this->assertEquals(20000, $revenue); // 10 * 2000
    }

    public function test_monthly_revenue_excludes_pending_payments(): void
    {
        $currentMonth = now()->format('m');
        $currentYear = now()->format('Y');

        // Paid payments
        Payment::factory()->count(5)->paid()->create([
            'institute_id' => $this->institute->id,
            'amount' => 2000,
            'month' => $currentMonth,
            'year' => $currentYear,
        ]);

        // Pending payments (should not be included)
        Payment::factory()->count(3)->pending()->create([
            'institute_id' => $this->institute->id,
            'amount' => 2000,
            'month' => $currentMonth,
            'year' => $currentYear,
        ]);

        $revenue = $this->service->getMonthlyRevenue($this->institute->id, $currentMonth, $currentYear);

        $this->assertEquals(10000, $revenue); // Only 5 paid * 2000
    }

    public function test_can_get_overdue_payments(): void
    {
        // Create overdue payments
        Payment::factory()->count(3)->overdue()->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
        ]);

        // Create future payments
        Payment::factory()->count(2)->pending()->create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'due_date' => now()->addDays(10),
        ]);

        $overduePayments = $this->service->getOverduePayments($this->institute->id);

        $this->assertCount(3, $overduePayments);

        foreach ($overduePayments as $payment) {
            $this->assertEquals('pending', $payment->status);
            $this->assertTrue($payment->due_date < now());
        }
    }

    public function test_can_get_pending_payments_by_class(): void
    {
        $class2 = ClassModel::factory()->withInstitute($this->institute)->create();

        // Class 1 pending payments
        Payment::factory()->count(4)->pending()->create([
            'class_id' => $this->class->id,
            'institute_id' => $this->institute->id,
        ]);

        // Class 2 pending payments
        Payment::factory()->count(2)->pending()->create([
            'class_id' => $class2->id,
            'institute_id' => $this->institute->id,
        ]);

        $class1Pending = $this->service->getPendingPaymentsByClass($this->class->id);
        $class2Pending = $this->service->getPendingPaymentsByClass($class2->id);

        $this->assertCount(4, $class1Pending);
        $this->assertCount(2, $class2Pending);
    }

    public function test_can_calculate_payment_completion_rate(): void
    {
        // 7 paid, 3 pending = 70% completion rate
        Payment::factory()->count(7)->paid()->create([
            'institute_id' => $this->institute->id,
        ]);

        Payment::factory()->count(3)->pending()->create([
            'institute_id' => $this->institute->id,
        ]);

        $rate = $this->service->getPaymentCompletionRate($this->institute->id);

        $this->assertEquals(70.0, $rate); // 7/10 * 100
    }

    public function test_payment_completion_rate_is_zero_with_no_payments(): void
    {
        $rate = $this->service->getPaymentCompletionRate($this->institute->id);

        $this->assertEquals(0, $rate);
    }

    public function test_can_get_payment_statistics_by_method(): void
    {
        Payment::factory()->count(5)->paid()->create([
            'institute_id' => $this->institute->id,
            'payment_method' => 'cash',
            'amount' => 1000,
        ]);

        Payment::factory()->count(3)->paid()->create([
            'institute_id' => $this->institute->id,
            'payment_method' => 'card',
            'amount' => 1500,
        ]);

        Payment::factory()->count(2)->paid()->create([
            'institute_id' => $this->institute->id,
            'payment_method' => 'online',
            'amount' => 2000,
        ]);

        $stats = $this->service->getPaymentStatisticsByMethod($this->institute->id);

        $this->assertEquals(5000, $stats['cash']); // 5 * 1000
        $this->assertEquals(4500, $stats['card']); // 3 * 1500
        $this->assertEquals(4000, $stats['online']); // 2 * 2000
    }
}
