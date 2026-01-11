<?php

namespace App\Services;

use App\Models\FeeStructure;
use App\Models\Payment;
use App\Models\Student;
use Carbon\Carbon;
use Illuminate\Support\Str;

class PaymentService
{
    /**
     * Record a new payment
     *
     * @param array $data
     * @return Payment
     */
    public function recordPayment(array $data): Payment
    {
        // Generate receipt number if not provided
        if (!isset($data['receipt_number'])) {
            $data['receipt_number'] = $this->generateReceiptNumber();
        }

        // Set payment date to today if not provided
        if (!isset($data['payment_date'])) {
            $data['payment_date'] = now();
        }

        // Mark as paid
        $data['status'] = 'paid';

        return Payment::create($data);
    }

    /**
     * Get defaulters (students with overdue payments)
     *
     * @param int $instituteId
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getDefaulters(int $instituteId)
    {
        return Student::where('institute_id', $instituteId)
            ->where('is_active', true)
            ->whereHas('payments', function ($query) {
                $query->where('status', 'overdue');
            })
            ->with(['user', 'payments' => function ($query) {
                $query->where('status', 'overdue')->latest();
            }])
            ->get();
    }

    /**
     * Get payment summary for a student
     *
     * @param int $studentId
     * @return array
     */
    public function getStudentPaymentSummary(int $studentId): array
    {
        $payments = Payment::where('student_id', $studentId)->get();

        return [
            'total_paid' => (float) $payments->where('status', 'paid')->sum('amount'),
            'total_pending' => (float) $payments->where('status', 'pending')->sum('amount'),
            'total_overdue' => (float) $payments->where('status', 'overdue')->sum('amount'),
            'overdue_count' => $payments->where('status', 'overdue')->count(),
            'last_payment' => $payments->where('status', 'paid')->sortByDesc('payment_date')->first(),
        ];
    }

    /**
     * Generate monthly payments for all students
     *
     * @param int $instituteId
     * @param string $month
     * @param int $year
     * @return int
     */
    public function generateMonthlyPayments(int $instituteId, string $month, int $year): int
    {
        $students = Student::where('institute_id', $instituteId)
            ->where('is_active', true)
            ->get();

        $count = 0;

        foreach ($students as $student) {
            // Check if payment already exists for this month
            $exists = Payment::where('student_id', $student->id)
                ->where('month', $month)
                ->where('year', $year)
                ->exists();

            if ($exists) {
                continue;
            }

            // Get fee structure for student's grade
            $feeStructure = FeeStructure::where('institute_id', $instituteId)
                ->where('grade', $student->grade)
                ->first();

            if (!$feeStructure) {
                continue; // Skip if no fee structure defined
            }

            // Create payment record
            Payment::create([
                'institute_id' => $instituteId,
                'student_id' => $student->id,
                'amount' => $feeStructure->monthly_fee,
                'payment_date' => null,
                'due_date' => Carbon::create($year, Carbon::parse($month)->month, 10), // Due on 10th of month
                'month' => $month,
                'year' => $year,
                'status' => 'pending',
            ]);

            $count++;
        }

        return $count;
    }

    /**
     * Mark overdue payments
     *
     * @param int $instituteId
     * @return int
     */
    public function markOverduePayments(int $instituteId): int
    {
        return Payment::where('institute_id', $instituteId)
            ->where('status', 'pending')
            ->where('due_date', '<', now())
            ->update(['status' => 'overdue']);
    }

    /**
     * Generate receipt number
     *
     * @return string
     */
    private function generateReceiptNumber(): string
    {
        return 'RCP-' . strtoupper(Str::random(3)) . '-' . now()->format('Ymd') . '-' . rand(1000, 9999);
    }

    /**
     * Get payment statistics
     *
     * @param int $instituteId
     * @param string|null $month
     * @param int|null $year
     * @return array
     */
    public function getPaymentStatistics(int $instituteId, ?string $month = null, ?int $year = null): array
    {
        $query = Payment::where('institute_id', $instituteId);

        if ($month && $year) {
            $query->where('month', $month)->where('year', $year);
        }

        $payments = $query->get();

        return [
            'total_collected' => (float) $payments->where('status', 'paid')->sum('amount'),
            'total_pending' => (float) $payments->where('status', 'pending')->sum('amount'),
            'total_overdue' => (float) $payments->where('status', 'overdue')->sum('amount'),
            'paid_count' => $payments->where('status', 'paid')->count(),
            'pending_count' => $payments->where('status', 'pending')->count(),
            'overdue_count' => $payments->where('status', 'overdue')->count(),
        ];
    }
}
