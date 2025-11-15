<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AttendanceService;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AttendanceController extends Controller
{
    protected $attendanceService;

    public function __construct(AttendanceService $attendanceService)
    {
        $this->attendanceService = $attendanceService;
    }

    /**
     * Mark attendance for a single student
     */
    public function mark(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'class_id' => 'required|exists:classes,id',
            'student_id' => 'required|exists:students,id',
            'date' => 'required|date',
            'status' => 'required|in:present,absent,late',
            'check_in_time' => 'nullable|date_format:H:i',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $attendance = $this->attendanceService->markAttendance([
                'institute_id' => $request->institute_id,
                'class_id' => $request->class_id,
                'student_id' => $request->student_id,
                'date' => $request->date,
                'status' => $request->status,
                'check_in_time' => $request->check_in_time,
                'marked_by' => auth()->id(),
                'notes' => $request->notes,
            ]);

            ActivityLog::logActivity('attendance_marked', 'Attendance', $attendance->id);

            return response()->json([
                'success' => true,
                'message' => 'Attendance marked successfully',
                'data' => $attendance
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark attendance',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark attendance for multiple students at once
     */
    public function markBulk(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'class_id' => 'required|exists:classes,id',
            'date' => 'required|date',
            'attendances' => 'required|array',
            'attendances.*.student_id' => 'required|exists:students,id',
            'attendances.*.status' => 'required|in:present,absent,late',
            'attendances.*.check_in_time' => 'nullable|date_format:H:i',
            'attendances.*.notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $count = $this->attendanceService->markBulkAttendance(
                $request->class_id,
                $request->attendances,
                $request->date,
                auth()->id()
            );

            ActivityLog::logActivity('bulk_attendance_marked', 'Attendance', null);

            return response()->json([
                'success' => true,
                'message' => "Attendance marked for {$count} students",
                'data' => ['count' => $count]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark bulk attendance',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get attendance for a specific class and date
     */
    public function getClassAttendance(Request $request, $classId)
    {
        $validator = Validator::make($request->all(), [
            'date' => 'sometimes|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            if ($request->has('date')) {
                $attendances = \App\Models\Attendance::where('class_id', $classId)
                    ->where('date', $request->date)
                    ->with('student.user')
                    ->get();
            } else {
                $attendances = $this->attendanceService->getTodayAttendance($classId);
            }

            return response()->json([
                'success' => true,
                'data' => $attendances
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch class attendance',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get attendance report for a class
     */
    public function classReport(Request $request, $classId)
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $report = $this->attendanceService->getClassAttendanceReport(
                $classId,
                $request->start_date,
                $request->end_date
            );

            return response()->json([
                'success' => true,
                'data' => $report
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
     * Get attendance summary for a student
     */
    public function studentSummary(Request $request, $studentId)
    {
        try {
            $month = $request->input('month');
            $year = $request->input('year');

            $summary = $this->attendanceService->getStudentAttendanceSummary(
                $studentId,
                $month,
                $year
            );

            return response()->json([
                'success' => true,
                'data' => $summary
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch student attendance summary',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
