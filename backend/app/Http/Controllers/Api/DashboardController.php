<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\ClassModel;
use App\Models\Payment;
use App\Models\Attendance;
use App\Models\GateLog;
use App\Models\ActivityLog;
use App\Services\RFIDService;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    protected $rfidService;
    protected $paymentService;

    public function __construct(RFIDService $rfidService, PaymentService $paymentService)
    {
        $this->rfidService = $rfidService;
        $this->paymentService = $paymentService;
    }

    /**
     * Get dashboard statistics
     */
    public function stats(Request $request)
    {
        try {
            $instituteId = $request->institute_id;
            $today = Carbon::today();

            // Student statistics
            $totalStudents = Student::where('institute_id', $instituteId)->count();
            $activeStudents = Student::where('institute_id', $instituteId)
                ->where('is_active', true)
                ->count();

            // Teacher statistics
            $totalTeachers = Teacher::where('institute_id', $instituteId)->count();
            $activeTeachers = Teacher::where('institute_id', $instituteId)
                ->where('is_active', true)
                ->count();

            // Class statistics
            $totalClasses = ClassModel::where('institute_id', $instituteId)->count();

            // Payment statistics (current month)
            $paymentStats = $this->paymentService->getPaymentStatistics(
                $instituteId,
                Carbon::now()->format('F'),
                Carbon::now()->year
            );

            // Attendance statistics (today) - Optimized to use single query
            $attendanceStats = Attendance::where('institute_id', $instituteId)
                ->whereDate('date', $today)
                ->selectRaw('
                    COUNT(*) as total_marked,
                    SUM(CASE WHEN status = "present" THEN 1 ELSE 0 END) as present,
                    SUM(CASE WHEN status = "absent" THEN 1 ELSE 0 END) as absent,
                    SUM(CASE WHEN status = "late" THEN 1 ELSE 0 END) as late
                ')
                ->first();

            $attendanceStats = [
                'total_marked' => (int) $attendanceStats->total_marked,
                'present' => (int) $attendanceStats->present,
                'absent' => (int) $attendanceStats->absent,
                'late' => (int) $attendanceStats->late,
            ];

            // Gate statistics (today)
            $gateStats = $this->rfidService->getGateStatistics($instituteId);

            // Payment defaulters count
            $defaultersCount = $this->paymentService->getDefaulters($instituteId)->count();

            return response()->json([
                'success' => true,
                'data' => [
                    'students' => [
                        'total' => $totalStudents,
                        'active' => $activeStudents,
                        'inactive' => $totalStudents - $activeStudents,
                    ],
                    'teachers' => [
                        'total' => $totalTeachers,
                        'active' => $activeTeachers,
                        'inactive' => $totalTeachers - $activeTeachers,
                    ],
                    'classes' => [
                        'total' => $totalClasses,
                    ],
                    'payments' => $paymentStats,
                    'attendance' => $attendanceStats,
                    'gate' => $gateStats,
                    'defaulters_count' => $defaultersCount,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch dashboard statistics'
            ], 500);
        }
    }

    /**
     * Get recent activities
     */
    public function recentActivities(Request $request)
    {
        try {
            // Limit validation: max 100 records
            $limit = min($request->input('limit', 20), 100);

            $activities = ActivityLog::with('user')
                ->whereHas('user', function ($query) use ($request) {
                    $query->where('institute_id', $request->institute_id);
                })
                ->recent($limit)
                ->get();

            return response()->json([
                'success' => true,
                'data' => $activities
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch recent activities'
            ], 500);
        }
    }
}
