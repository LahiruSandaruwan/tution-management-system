<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Payment;
use App\Services\NotificationService;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PaymentController extends Controller
{
    protected $paymentService;
    protected $notificationService;

    public function __construct(PaymentService $paymentService, NotificationService $notificationService)
    {
        $this->paymentService = $paymentService;
        $this->notificationService = $notificationService;
    }

    /**
     * Display a listing of payments
     */
    public function index(Request $request)
    {
        try {
            $query = Payment::with(['student.user'])
                ->where('institute_id', $request->institute_id);

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Filter by month and year
            if ($request->has('month')) {
                $query->where('month', $request->month);
            }
            if ($request->has('year')) {
                $query->where('year', $request->year);
            }

            // Filter by student
            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }

            $payments = $query->latest('created_at')->paginate(min($request->input('per_page', 15), 100));

            return response()->json([
                'success' => true,
                'data' => $payments,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch payments',
            ], 500);
        }
    }

    /**
     * Store a newly created payment
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'student_id' => 'required|exists:students,id',
            'amount' => 'required|numeric|min:0',
            'month' => 'required|string',
            'year' => 'required|integer',
            'payment_method' => 'nullable|in:cash,bank_transfer,online',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $payment = $this->paymentService->recordPayment([
                'institute_id' => $request->institute_id,
                'student_id' => $request->student_id,
                'amount' => $request->amount,
                'month' => $request->month,
                'year' => $request->year,
                'payment_method' => $request->payment_method,
                'notes' => $request->notes,
                'received_by' => auth()->id(),
            ]);

            ActivityLog::logActivity('payment_recorded', Payment::class, $payment->id);

            return response()->json([
                'success' => true,
                'message' => 'Payment recorded successfully',
                'data' => $payment->load('student.user'),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to record payment',
            ], 500);
        }
    }

    /**
     * Display the specified payment
     */
    public function show(Request $request, Payment $payment)
    {
        // Verify payment belongs to the same institute
        if ($payment->institute_id !== $request->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        try {
            $payment->load(['student.user', 'receivedBy']);

            return response()->json([
                'success' => true,
                'data' => $payment,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch payment',
            ], 500);
        }
    }

    /**
     * Get payments for specific student
     */
    public function studentPayments(Request $request, $studentId)
    {
        try {
            $payments = Payment::where('student_id', $studentId)
                ->where('institute_id', $request->institute_id)
                ->with('receivedBy')
                ->latest('payment_date')
                ->get();

            $summary = $this->paymentService->getStudentPaymentSummary($studentId);

            return response()->json([
                'success' => true,
                'data' => [
                    'payments' => $payments,
                    'summary' => $summary,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch student payments',
            ], 500);
        }
    }

    /**
     * Generate monthly payments for all students
     */
    public function generateMonthly(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'month' => 'required|string',
            'year' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $count = $this->paymentService->generateMonthlyPayments(
                $request->institute_id,
                $request->month,
                $request->year
            );

            ActivityLog::logActivity('monthly_payments_generated', null, null);

            return response()->json([
                'success' => true,
                'message' => "Monthly payments generated for {$count} students",
                'data' => ['count' => $count],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate monthly payments',
            ], 500);
        }
    }

    /**
     * Get list of payment defaulters
     */
    public function defaulters(Request $request)
    {
        try {
            $defaulters = $this->paymentService->getDefaulters($request->institute_id);

            return response()->json([
                'success' => true,
                'data' => $defaulters,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch defaulters',
            ], 500);
        }
    }

    /**
     * Get payment statistics
     */
    public function statistics(Request $request)
    {
        try {
            $month = $request->input('month');
            $year = $request->input('year');

            $statistics = $this->paymentService->getPaymentStatistics(
                $request->institute_id,
                $month,
                $year
            );

            return response()->json([
                'success' => true,
                'data' => $statistics,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch payment statistics',
            ], 500);
        }
    }
}
