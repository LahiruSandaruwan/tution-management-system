<?php

namespace App\Jobs;

use App\Models\Institute;
use App\Models\Attendance;
use App\Models\Payment;
use App\Models\Grade;
use App\Models\User;
use App\Mail\MonthlyReportMail;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class GenerateMonthlyReportJob implements ShouldQueue
{
    use Queueable;

    public $timeout = 600; // 10 minutes
    public $tries = 3;

    protected $month;
    protected $year;
    protected $instituteId;

    /**
     * Create a new job instance.
     */
    public function __construct($month = null, $year = null, $instituteId = null)
    {
        $this->month = $month ?? Carbon::now()->subMonth()->month;
        $this->year = $year ?? Carbon::now()->subMonth()->year;
        $this->instituteId = $instituteId;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        Log::info("Starting monthly report generation for {$this->year}-{$this->month}");

        if ($this->instituteId) {
            $this->generateReportForInstitute($this->instituteId);
        } else {
            // Generate reports for all active institutes
            $institutes = Institute::where('status', 'active')->get();

            foreach ($institutes as $institute) {
                try {
                    $this->generateReportForInstitute($institute->id);
                } catch (\Exception $e) {
                    Log::error("Failed to generate report for institute {$institute->id}: " . $e->getMessage());
                }
            }
        }

        Log::info("Monthly report generation completed");
    }

    /**
     * Generate comprehensive monthly report for a specific institute
     */
    protected function generateReportForInstitute($instituteId): void
    {
        $institute = Institute::with(['owner'])->find($instituteId);

        if (!$institute) {
            Log::warning("Institute {$instituteId} not found");
            return;
        }

        Log::info("Generating report for institute: {$institute->name}");

        // Collect all report data
        $reportData = [
            'institute' => $institute,
            'month' => Carbon::createFromDate($this->year, $this->month, 1)->format('F Y'),
            'attendance' => $this->getAttendanceStats($instituteId),
            'payments' => $this->getPaymentStats($instituteId),
            'students' => $this->getStudentStats($instituteId),
            'teachers' => $this->getTeacherStats($instituteId),
            'grades' => $this->getGradeStats($instituteId),
        ];

        // Send email to institute owner and admins
        $this->sendReportEmail($institute, $reportData);

        Log::info("Report generated and sent for institute: {$institute->name}");
    }

    /**
     * Get attendance statistics for the month
     */
    protected function getAttendanceStats($instituteId): array
    {
        $startDate = Carbon::createFromDate($this->year, $this->month, 1)->startOfDay();
        $endDate = $startDate->copy()->endOfMonth();

        $totalRecords = Attendance::where('institute_id', $instituteId)
            ->whereBetween('date', [$startDate, $endDate])
            ->count();

        $presentCount = Attendance::where('institute_id', $instituteId)
            ->whereBetween('date', [$startDate, $endDate])
            ->where('status', 'present')
            ->count();

        $absentCount = Attendance::where('institute_id', $instituteId)
            ->whereBetween('date', [$startDate, $endDate])
            ->where('status', 'absent')
            ->count();

        $lateCount = Attendance::where('institute_id', $instituteId)
            ->whereBetween('date', [$startDate, $endDate])
            ->where('status', 'late')
            ->count();

        $attendanceRate = $totalRecords > 0 ? round(($presentCount / $totalRecords) * 100, 2) : 0;

        return [
            'total_records' => $totalRecords,
            'present' => $presentCount,
            'absent' => $absentCount,
            'late' => $lateCount,
            'attendance_rate' => $attendanceRate,
        ];
    }

    /**
     * Get payment statistics for the month
     */
    protected function getPaymentStats($instituteId): array
    {
        $startDate = Carbon::createFromDate($this->year, $this->month, 1)->startOfDay();
        $endDate = $startDate->copy()->endOfMonth();

        $totalAmount = Payment::where('institute_id', $instituteId)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');

        $paidAmount = Payment::where('institute_id', $instituteId)
            ->where('status', 'paid')
            ->whereBetween('paid_date', [$startDate, $endDate])
            ->sum('amount');

        $pendingAmount = Payment::where('institute_id', $instituteId)
            ->where('status', 'pending')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->sum('amount');

        $overdueAmount = Payment::where('institute_id', $instituteId)
            ->where('status', 'overdue')
            ->sum('amount');

        $totalPayments = Payment::where('institute_id', $instituteId)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->count();

        $paidPayments = Payment::where('institute_id', $instituteId)
            ->where('status', 'paid')
            ->whereBetween('paid_date', [$startDate, $endDate])
            ->count();

        $collectionRate = $totalAmount > 0 ? round(($paidAmount / $totalAmount) * 100, 2) : 0;

        return [
            'total_amount' => $totalAmount,
            'paid_amount' => $paidAmount,
            'pending_amount' => $pendingAmount,
            'overdue_amount' => $overdueAmount,
            'total_payments' => $totalPayments,
            'paid_payments' => $paidPayments,
            'collection_rate' => $collectionRate,
        ];
    }

    /**
     * Get student statistics for the month
     */
    protected function getStudentStats($instituteId): array
    {
        $startDate = Carbon::createFromDate($this->year, $this->month, 1)->startOfDay();
        $endDate = $startDate->copy()->endOfMonth();

        $totalStudents = DB::table('students')
            ->where('institute_id', $instituteId)
            ->where('status', 'active')
            ->count();

        $newStudents = DB::table('students')
            ->where('institute_id', $instituteId)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->count();

        $inactiveStudents = DB::table('students')
            ->where('institute_id', $instituteId)
            ->where('status', 'inactive')
            ->whereBetween('updated_at', [$startDate, $endDate])
            ->count();

        return [
            'total_active' => $totalStudents,
            'new_enrollments' => $newStudents,
            'inactive' => $inactiveStudents,
        ];
    }

    /**
     * Get teacher statistics for the month
     */
    protected function getTeacherStats($instituteId): array
    {
        $totalTeachers = DB::table('teachers')
            ->where('institute_id', $instituteId)
            ->where('status', 'active')
            ->count();

        return [
            'total_active' => $totalTeachers,
        ];
    }

    /**
     * Get grade/performance statistics for the month
     */
    protected function getGradeStats($instituteId): array
    {
        $startDate = Carbon::createFromDate($this->year, $this->month, 1)->startOfDay();
        $endDate = $startDate->copy()->endOfMonth();

        $totalGrades = Grade::where('institute_id', $instituteId)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->count();

        $averageGrade = Grade::where('institute_id', $instituteId)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->avg('grade');

        $topPerformers = Grade::where('institute_id', $instituteId)
            ->whereBetween('created_at', [$startDate, $endDate])
            ->where('grade', '>=', 75)
            ->distinct('student_id')
            ->count('student_id');

        return [
            'total_grades' => $totalGrades,
            'average_grade' => $averageGrade ? round($averageGrade, 2) : 0,
            'top_performers' => $topPerformers,
        ];
    }

    /**
     * Send monthly report email to institute admins
     */
    protected function sendReportEmail(Institute $institute, array $reportData): void
    {
        $owner = $institute->owner;

        if (!$owner || !$owner->email) {
            Log::warning("No owner or email found for institute {$institute->id}");
            return;
        }

        Mail::to($owner->email)->send(new MonthlyReportMail($institute, $reportData));

        Log::info("Monthly report email sent to {$owner->email}");
    }
}
