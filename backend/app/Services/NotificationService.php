<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;

class NotificationService
{
    /**
     * Create a notification for a user
     *
     * @param int $userId
     * @param string $type
     * @param string $title
     * @param string $message
     * @param array|null $data
     * @return Notification
     */
    public function create(int $userId, string $type, string $title, string $message, ?array $data = null): Notification
    {
        return Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'data' => $data,
        ]);
    }

    /**
     * Send notification to multiple users
     *
     * @param array $userIds
     * @param string $type
     * @param string $title
     * @param string $message
     * @param array|null $data
     * @return int
     */
    public function sendToMultiple(array $userIds, string $type, string $title, string $message, ?array $data = null): int
    {
        $count = 0;

        foreach ($userIds as $userId) {
            $this->create($userId, $type, $title, $message, $data);
            $count++;
        }

        return $count;
    }

    /**
     * Send payment reminder
     *
     * @param int $studentId
     * @param float $amount
     * @param string $month
     * @return void
     */
    public function sendPaymentReminder(int $studentId, float $amount, string $month): void
    {
        $student = \App\Models\Student::find($studentId);

        if (!$student || !$student->user_id) {
            return;
        }

        $this->create(
            $student->user_id,
            'payment_reminder',
            'Payment Reminder',
            "Your payment of Rs. {$amount} for {$month} is overdue. Please make payment to avoid access restrictions.",
            [
                'amount' => $amount,
                'month' => $month,
                'student_id' => $studentId,
            ]
        );
    }

    /**
     * Send announcement notification
     *
     * @param int $instituteId
     * @param string $targetAudience
     * @param string $title
     * @param string $content
     * @param int|null $classId
     * @return int
     */
    public function sendAnnouncement(int $instituteId, string $targetAudience, string $title, string $content, ?int $classId = null): int
    {
        $query = User::where('institute_id', $instituteId);

        if ($targetAudience === 'students') {
            $query->where('role', 'student');
        } elseif ($targetAudience === 'teachers') {
            $query->where('role', 'teacher');
        } elseif ($targetAudience === 'specific_class' && $classId) {
            $query->where('role', 'student')
                ->whereHas('student.classes', function ($q) use ($classId) {
                    $q->where('classes.id', $classId);
                });
        }

        $userIds = $query->pluck('id')->toArray();

        return $this->sendToMultiple(
            $userIds,
            'announcement',
            $title,
            $content,
            ['class_id' => $classId]
        );
    }

    /**
     * Mark notification as read
     *
     * @param int $notificationId
     * @return bool
     */
    public function markAsRead(int $notificationId): bool
    {
        $notification = Notification::find($notificationId);

        if (!$notification) {
            return false;
        }

        $notification->markAsRead();

        return true;
    }

    /**
     * Get unread count for user
     *
     * @param int $userId
     * @return int
     */
    public function getUnreadCount(int $userId): int
    {
        return Notification::where('user_id', $userId)->unread()->count();
    }
}
