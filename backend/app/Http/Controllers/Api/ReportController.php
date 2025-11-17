<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Payment;
use App\Models\GateLog;
use App\Models\Grade;
use App\Models\Institute;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;

class ReportController extends Controller
{
    /**
     * Generate attendance report
     */
    public function attendance(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'class_id' => 'nullable|exists:classes,id',
            'student_id' => 'nullable|exists:students,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $query = Attendance::where('institute_id', $request->institute_id)
                ->whereBetween('date', [$request->start_date, $request->end_date])
                ->with(['student.user', 'class']);

            if ($request->has('class_id')) {
                $query->where('class_id', $request->class_id);
            }

            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }

            $attendances = $query->get();

            // Calculate statistics
            $stats = [
                'total_records' => $attendances->count(),
                'present' => $attendances->where('status', 'present')->count(),
                'absent' => $attendances->where('status', 'absent')->count(),
                'late' => $attendances->where('status', 'late')->count(),
                'attendance_rate' => $attendances->count() > 0
                    ? round(($attendances->where('status', 'present')->count() / $attendances->count()) * 100, 2)
                    : 0,
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'attendances' => $attendances,
                    'statistics' => $stats,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate attendance report',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate payment report
     */
    public function payments(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'month' => 'nullable|string',
            'year' => 'nullable|integer',
            'status' => 'nullable|in:paid,pending,overdue',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $query = Payment::where('institute_id', $request->institute_id)
                ->with(['student.user', 'receivedBy']);

            if ($request->has('start_date') && $request->has('end_date')) {
                $query->whereBetween('payment_date', [$request->start_date, $request->end_date]);
            }

            if ($request->has('month')) {
                $query->where('month', $request->month);
            }

            if ($request->has('year')) {
                $query->where('year', $request->year);
            }

            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            $payments = $query->latest('payment_date')->get();

            // Calculate statistics
            $stats = [
                'total_amount' => $payments->sum('amount'),
                'paid_amount' => $payments->where('status', 'paid')->sum('amount'),
                'pending_amount' => $payments->where('status', 'pending')->sum('amount'),
                'overdue_amount' => $payments->where('status', 'overdue')->sum('amount'),
                'total_count' => $payments->count(),
                'paid_count' => $payments->where('status', 'paid')->count(),
                'pending_count' => $payments->where('status', 'pending')->count(),
                'overdue_count' => $payments->where('status', 'overdue')->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'payments' => $payments,
                    'statistics' => $stats,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate payment report',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate gate logs report
     */
    public function gateLogs(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'action' => 'nullable|in:entry,exit',
            'student_id' => 'nullable|exists:students,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $query = GateLog::where('institute_id', $request->institute_id)
                ->with(['student.user', 'rfidCard']);

            if ($request->has('start_date') && $request->has('end_date')) {
                $query->whereBetween('timestamp', [
                    Carbon::parse($request->start_date)->startOfDay(),
                    Carbon::parse($request->end_date)->endOfDay()
                ]);
            } else {
                // Default to today
                $query->whereDate('timestamp', Carbon::today());
            }

            if ($request->has('action')) {
                $query->where('action', $request->action);
            }

            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }

            $logs = $query->latest('timestamp')->get();

            // Calculate statistics
            $stats = [
                'total_logs' => $logs->count(),
                'entries' => $logs->where('action', 'entry')->count(),
                'exits' => $logs->where('action', 'exit')->count(),
                'success' => $logs->where('status', 'success')->count(),
                'denied' => $logs->where('status', 'denied')->count(),
                'unique_students' => $logs->pluck('student_id')->unique()->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'logs' => $logs,
                    'statistics' => $stats,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate gate logs report',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate academic report
     */
    public function academic(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'class_id' => 'nullable|exists:classes,id',
            'student_id' => 'nullable|exists:students,id',
            'exam_id' => 'nullable|exists:exams,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $query = Grade::where('institute_id', $request->institute_id)
                ->with(['student.user', 'class', 'exam', 'subject']);

            if ($request->has('class_id')) {
                $query->where('class_id', $request->class_id);
            }

            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }

            if ($request->has('exam_id')) {
                $query->where('exam_id', $request->exam_id);
            }

            $grades = $query->get();

            // Calculate statistics
            $stats = [
                'total_records' => $grades->count(),
                'average_marks' => $grades->avg('marks_obtained'),
                'highest_marks' => $grades->max('marks_obtained'),
                'lowest_marks' => $grades->min('marks_obtained'),
                'pass_count' => $grades->where('is_pass', true)->count(),
                'fail_count' => $grades->where('is_pass', false)->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'grades' => $grades,
                    'statistics' => $stats,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate academic report',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Export attendance report as PDF
     */
    public function exportAttendancePdf(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'class_id' => 'nullable|exists:classes,id',
            'student_id' => 'nullable|exists:students,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $query = Attendance::where('institute_id', $request->institute_id)
                ->whereBetween('date', [$request->start_date, $request->end_date])
                ->with(['student.user', 'class']);

            if ($request->has('class_id')) {
                $query->where('class_id', $request->class_id);
            }

            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }

            $attendances = $query->get();

            $stats = [
                'total_records' => $attendances->count(),
                'present' => $attendances->where('status', 'present')->count(),
                'absent' => $attendances->where('status', 'absent')->count(),
                'late' => $attendances->where('status', 'late')->count(),
                'attendance_rate' => $attendances->count() > 0
                    ? round(($attendances->where('status', 'present')->count() / $attendances->count()) * 100, 2)
                    : 0,
            ];

            $institute = Institute::find($request->institute_id);

            $pdf = Pdf::loadView('reports.attendance', [
                'attendances' => $attendances,
                'stats' => $stats,
                'institute' => $institute,
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'generated_at' => Carbon::now()->format('F j, Y g:i A'),
            ]);

            return $pdf->download('attendance_report_' . date('Y-m-d') . '.pdf');

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate PDF',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Export payment report as PDF
     */
    public function exportPaymentsPdf(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'month' => 'nullable|string',
            'year' => 'nullable|integer',
            'status' => 'nullable|in:paid,pending,overdue',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $query = Payment::where('institute_id', $request->institute_id)
                ->with(['student.user', 'receivedBy']);

            if ($request->has('start_date') && $request->has('end_date')) {
                $query->whereBetween('payment_date', [$request->start_date, $request->end_date]);
            }

            if ($request->has('month')) {
                $query->where('month', $request->month);
            }

            if ($request->has('year')) {
                $query->where('year', $request->year);
            }

            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            $payments = $query->latest('payment_date')->get();

            $stats = [
                'total_amount' => $payments->sum('amount'),
                'paid_amount' => $payments->where('status', 'paid')->sum('amount'),
                'pending_amount' => $payments->where('status', 'pending')->sum('amount'),
                'overdue_amount' => $payments->where('status', 'overdue')->sum('amount'),
                'total_count' => $payments->count(),
                'paid_count' => $payments->where('status', 'paid')->count(),
                'pending_count' => $payments->where('status', 'pending')->count(),
                'overdue_count' => $payments->where('status', 'overdue')->count(),
            ];

            $institute = Institute::find($request->institute_id);

            $pdf = Pdf::loadView('reports.payments', [
                'payments' => $payments,
                'stats' => $stats,
                'institute' => $institute,
                'filters' => $request->all(),
                'generated_at' => Carbon::now()->format('F j, Y g:i A'),
            ]);

            return $pdf->download('payment_report_' . date('Y-m-d') . '.pdf');

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate PDF',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Export monthly summary report as PDF
     */
    public function exportMonthlySummaryPdf(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'month' => 'required|integer|between:1,12',
            'year' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $startDate = Carbon::createFromDate($request->year, $request->month, 1)->startOfDay();
            $endDate = $startDate->copy()->endOfMonth();

            $instituteId = $request->institute_id;

            // Attendance stats
            $attendances = Attendance::where('institute_id', $instituteId)
                ->whereBetween('date', [$startDate, $endDate])
                ->get();

            $attendanceStats = [
                'total_records' => $attendances->count(),
                'present' => $attendances->where('status', 'present')->count(),
                'absent' => $attendances->where('status', 'absent')->count(),
                'late' => $attendances->where('status', 'late')->count(),
                'attendance_rate' => $attendances->count() > 0
                    ? round(($attendances->where('status', 'present')->count() / $attendances->count()) * 100, 2)
                    : 0,
            ];

            // Payment stats
            $payments = Payment::where('institute_id', $instituteId)
                ->whereBetween('created_at', [$startDate, $endDate])
                ->get();

            $paymentStats = [
                'total_amount' => $payments->sum('amount'),
                'paid_amount' => $payments->where('status', 'paid')->sum('amount'),
                'pending_amount' => $payments->where('status', 'pending')->sum('amount'),
                'overdue_amount' => $payments->where('status', 'overdue')->sum('amount'),
                'total_count' => $payments->count(),
                'paid_count' => $payments->where('status', 'paid')->count(),
                'collection_rate' => $payments->sum('amount') > 0
                    ? round(($payments->where('status', 'paid')->sum('amount') / $payments->sum('amount')) * 100, 2)
                    : 0,
            ];

            $institute = Institute::find($instituteId);

            $pdf = Pdf::loadView('reports.monthly-summary', [
                'institute' => $institute,
                'month' => $startDate->format('F Y'),
                'attendance_stats' => $attendanceStats,
                'payment_stats' => $paymentStats,
                'generated_at' => Carbon::now()->format('F j, Y g:i A'),
            ]);

            return $pdf->download('monthly_summary_' . $startDate->format('Y-m') . '.pdf');

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate PDF',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
