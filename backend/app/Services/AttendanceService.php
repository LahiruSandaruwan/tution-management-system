<?php

namespace App\Services;

use App\Models\Attendance;
use App\Models\ClassModel;
use Carbon\Carbon;

class AttendanceService
{
    /**
     * Mark attendance for a student
     * 
     * @param array $data
     * @return Attendance
     */
    public function markAttendance(array $data): Attendance
    {
        // Check if attendance already exists
        $existing = Attendance::where('class_id', $data['class_id'])
            ->where('student_id', $data['student_id'])
            ->where('date', $data['date'])
            ->first();

        if ($existing) {
            $existing->update($data);
            return $existing;
        }

        return Attendance::create($data);
    }

    /**
     * Mark attendance for multiple students
     * 
     * @param int $classId
     * @param array $studentAttendances
     * @param string $date
     * @param int $markedBy
     * @return int
     */
    public function markBulkAttendance(int $classId, array $studentAttendances, string $date, int $markedBy): int
    {
        $count = 0;

        foreach ($studentAttendances as $studentAttendance) {
            $this->markAttendance([
                'institute_id' => auth()->user()->institute_id,
                'class_id' => $classId,
                'student_id' => $studentAttendance['student_id'],
                'date' => $date,
                'status' => $studentAttendance['status'],
                'check_in_time' => $studentAttendance['check_in_time'] ?? null,
                'marked_by' => $markedBy,
                'notes' => $studentAttendance['notes'] ?? null,
            ]);

            $count++;
        }

        return $count;
    }

    /**
     * Get attendance report for a class
     * 
     * @param int $classId
     * @param string $startDate
     * @param string $endDate
     * @return array
     */
    public function getClassAttendanceReport(int $classId, string $startDate, string $endDate): array
    {
        $attendances = Attendance::where('class_id', $classId)
            ->whereBetween('date', [$startDate, $endDate])
            ->with('student.user')
            ->get();

        $report = [];

        foreach ($attendances->groupBy('student_id') as $studentId => $studentAttendances) {
            $total = $studentAttendances->count();
            $present = $studentAttendances->where('status', 'present')->count();
            $absent = $studentAttendances->where('status', 'absent')->count();
            $late = $studentAttendances->where('status', 'late')->count();

            $report[] = [
                'student_id' => $studentId,
                'student_name' => $studentAttendances->first()->student->user->name,
                'total_days' => $total,
                'present' => $present,
                'absent' => $absent,
                'late' => $late,
                'attendance_percentage' => $total > 0 ? round(($present / $total) * 100, 2) : 0,
            ];
        }

        return $report;
    }

    /**
     * Get student attendance summary
     * 
     * @param int $studentId
     * @param string|null $month
     * @param int|null $year
     * @return array
     */
    public function getStudentAttendanceSummary(int $studentId, ?string $month = null, ?int $year = null): array
    {
        $query = Attendance::where('student_id', $studentId);

        if ($month && $year) {
            $monthNumber = Carbon::parse($month)->month;
            $query->whereMonth('date', $monthNumber)->whereYear('date', $year);
        }

        $attendances = $query->get();

        return [
            'total_days' => $attendances->count(),
            'present' => $attendances->where('status', 'present')->count(),
            'absent' => $attendances->where('status', 'absent')->count(),
            'late' => $attendances->where('status', 'late')->count(),
            'attendance_percentage' => $attendances->count() > 0 
                ? round(($attendances->where('status', 'present')->count() / $attendances->count()) * 100, 2) 
                : 0,
        ];
    }

    /**
     * Get today's attendance for a class
     * 
     * @param int $classId
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getTodayAttendance(int $classId)
    {
        return Attendance::where('class_id', $classId)
            ->whereDate('date', today())
            ->with('student.user')
            ->get();
    }
}
