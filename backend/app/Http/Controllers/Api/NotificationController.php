<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Get notifications for authenticated user
     */
    public function index(Request $request)
    {
        try {
            $query = Notification::where('user_id', auth()->id());

            // Filter by read/unread
            if ($request->has('read')) {
                if ($request->read == 'true' || $request->read == 1) {
                    $query->read();
                } else {
                    $query->unread();
                }
            }

            // Filter by type
            if ($request->has('type')) {
                $query->where('type', $request->type);
            }

            $notifications = $query->latest('created_at')
                ->paginate($request->input('per_page', 20));

            return response()->json([
                'success' => true,
                'data' => $notifications
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch notifications',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Notification $notification)
    {
        try {
            // Check if notification belongs to authenticated user
            if ($notification->user_id !== auth()->id()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized access to notification'
                ], 403);
            }

            $this->notificationService->markAsRead($notification->id);

            return response()->json([
                'success' => true,
                'message' => 'Notification marked as read'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to mark notification as read',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get unread notification count
     */
    public function unreadCount()
    {
        try {
            $count = $this->notificationService->getUnreadCount(auth()->id());

            return response()->json([
                'success' => true,
                'data' => ['count' => $count]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch unread count',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
