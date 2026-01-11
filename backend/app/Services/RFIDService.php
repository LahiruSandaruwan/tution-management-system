<?php

namespace App\Services;

use App\Models\GateLog;
use App\Models\Payment;
use App\Models\RfidCard;
use App\Models\Student;
use Carbon\Carbon;

class RFIDService
{
    /**
     * Verify RFID card access and return access decision
     *
     * @param string $cardUid
     * @param string $deviceId
     * @return array
     */
    public function verifyCardAccess(string $cardUid, string $deviceId): array
    {
        // 1. Find RFID card
        $rfidCard = RfidCard::where('card_uid', $cardUid)->first();

        if (!$rfidCard) {
            return $this->denyAccess($cardUid, null, 'RFID card not found in system');
        }

        // 2. Check if card is active
        if (!$rfidCard->isActive()) {
            return $this->denyAccess($cardUid, $rfidCard->student_id, "RFID card status: {$rfidCard->status}");
        }

        // 3. Get student details
        $student = $rfidCard->student()->with('user')->first();

        if (!$student) {
            return $this->denyAccess($cardUid, null, 'Student record not found');
        }

        // 4. Check if student is active
        if (!$student->is_active) {
            return $this->denyAccess($cardUid, $student->id, 'Student account is inactive');
        }

        // 5. Check payment status (current month)
        $hasOverduePayments = $this->checkPaymentStatus($student->id);

        if ($hasOverduePayments) {
            return $this->denyAccess($cardUid, $student->id, 'Outstanding payment dues');
        }

        // 6. Grant access
        return $this->grantAccess($rfidCard, $student);
    }

    /**
     * Log entry/exit action
     *
     * @param string $cardUid
     * @param string $action (entry|exit)
     * @param int $instituteId
     * @return array
     */
    public function logGateAction(string $cardUid, string $action, int $instituteId): array
    {
        $rfidCard = RfidCard::where('card_uid', $cardUid)->first();

        $gateLog = GateLog::create([
            'institute_id' => $instituteId,
            'rfid_card_id' => $rfidCard?->id,
            'student_id' => $rfidCard?->student_id,
            'action' => $action,
            'status' => 'success',
            'timestamp' => now(),
            'created_at' => now(),
        ]);

        return [
            'success' => true,
            'log_id' => $gateLog->id,
            'student' => $rfidCard?->student->user->name ?? 'Unknown',
        ];
    }

    /**
     * Check if student has overdue payments
     *
     * @param int $studentId
     * @return bool
     */
    private function checkPaymentStatus(int $studentId): bool
    {
        $currentMonth = Carbon::now()->format('F');
        $currentYear = Carbon::now()->year;

        // Check if there's a payment record for current month
        $payment = Payment::where('student_id', $studentId)
            ->where('month', $currentMonth)
            ->where('year', $currentYear)
            ->first();

        // If no payment record or status is overdue/pending
        if (!$payment || $payment->status === 'overdue') {
            return true;
        }

        // Check for any overdue payments from previous months
        $overdueCount = Payment::where('student_id', $studentId)
            ->where('status', 'overdue')
            ->count();

        return $overdueCount > 0;
    }

    /**
     * Grant access and return success response
     *
     * @param RfidCard $rfidCard
     * @param Student $student
     * @return array
     */
    private function grantAccess(RfidCard $rfidCard, Student $student): array
    {
        return [
            'allowed' => true,
            'message' => 'Access granted',
            'student_id' => $student->id,
            'student_name' => $student->user->name,
            'student_id_number' => $student->student_id_number,
            'grade' => $student->grade,
            'photo' => $student->photo,
        ];
    }

    /**
     * Deny access and return denial response
     *
     * @param string $cardUid
     * @param int|null $studentId
     * @param string $reason
     * @return array
     */
    private function denyAccess(string $cardUid, ?int $studentId, string $reason): array
    {
        return [
            'allowed' => false,
            'message' => 'Access denied',
            'reason' => $reason,
            'card_uid' => $cardUid,
            'student_id' => $studentId,
        ];
    }

    /**
     * Get live gate feed for admin dashboard
     *
     * @param int $instituteId
     * @param int $limit
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getLiveGateFeed(int $instituteId, int $limit = 50)
    {
        return GateLog::with(['student.user', 'rfidCard'])
            ->where('institute_id', $instituteId)
            ->latest('timestamp')
            ->limit($limit)
            ->get();
    }

    /**
     * Get gate statistics for dashboard
     *
     * @param int $instituteId
     * @return array
     */
    public function getGateStatistics(int $instituteId): array
    {
        $today = Carbon::today();

        return [
            'today_entries' => GateLog::where('institute_id', $instituteId)
                ->whereDate('timestamp', $today)
                ->where('action', 'entry')
                ->where('status', 'success')
                ->count(),
            'today_exits' => GateLog::where('institute_id', $instituteId)
                ->whereDate('timestamp', $today)
                ->where('action', 'exit')
                ->where('status', 'success')
                ->count(),
            'today_denied' => GateLog::where('institute_id', $instituteId)
                ->whereDate('timestamp', $today)
                ->where('status', 'denied')
                ->count(),
            'currently_inside' => $this->getCurrentlyInsideCount($instituteId),
        ];
    }

    /**
     * Calculate how many students are currently inside
     *
     * @param int $instituteId
     * @return int
     */
    private function getCurrentlyInsideCount(int $instituteId): int
    {
        $today = Carbon::today();

        // Get all successful entries today
        $entries = GateLog::where('institute_id', $instituteId)
            ->whereDate('timestamp', $today)
            ->where('action', 'entry')
            ->where('status', 'success')
            ->pluck('student_id')
            ->unique();

        // Get all exits today
        $exits = GateLog::where('institute_id', $instituteId)
            ->whereDate('timestamp', $today)
            ->where('action', 'exit')
            ->where('status', 'success')
            ->pluck('student_id')
            ->unique();

        // Students inside = entries - exits
        return $entries->diff($exits)->count();
    }
}
