<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class AnnouncementController extends Controller
{
    public function index(Request $request)
    {
        try {
            $query = Announcement::where('institute_id', auth()->user()->institute_id);

            // Filter by target audience if provided
            if ($request->has('target_audience')) {
                $query->forAudience($request->target_audience);
            }

            // Filter by priority if provided
            if ($request->has('priority')) {
                $query->where('priority', $request->priority);
            }

            // Sort by latest
            $query->latest('created_at');

            $announcements = $query->paginate(min($request->input('per_page', 20), 100));

            return response()->json([
                'success' => true,
                'data' => $announcements
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch announcements',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:255',
                'message' => 'required|string',
                'type' => 'sometimes|string|in:info,success,warning,error',
                'target_audience' => 'sometimes|string|in:all,students,teachers',
                'class_id' => 'sometimes|exists:classes,id',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Map frontend 'type' to database 'priority' values
            $typeToPriority = [
                'info' => 'low',
                'success' => 'low',
                'warning' => 'medium',
                'error' => 'high',
            ];
            $type = $request->input('type', 'info');
            $priority = $typeToPriority[$type] ?? 'medium';

            // Map 'message' to 'content' and 'type' to 'priority'
            $data = [
                'institute_id' => auth()->user()->institute_id,
                'title' => $request->title,
                'content' => $request->message,
                'priority' => $priority,
                'target_audience' => $request->input('target_audience', 'all'),
            ];

            if ($request->has('class_id')) {
                $data['class_id'] = $request->class_id;
            }

            $announcement = Announcement::create($data);

            return response()->json([
                'success' => true,
                'message' => 'Announcement created successfully',
                'data' => $announcement
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create announcement',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show(string $id)
    {
        try {
            $announcement = Announcement::where('institute_id', auth()->user()->institute_id)
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $announcement
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Announcement not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    public function update(Request $request, string $id)
    {
        try {
            $announcement = Announcement::where('institute_id', auth()->user()->institute_id)
                ->findOrFail($id);

            $validator = Validator::make($request->all(), [
                'title' => 'sometimes|string|max:255',
                'message' => 'sometimes|string',
                'type' => 'sometimes|string|in:info,success,warning,error',
                'target_audience' => 'sometimes|string|in:all,students,teachers',
                'class_id' => 'sometimes|exists:classes,id',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Map frontend 'type' to database 'priority' values
            $typeToPriority = [
                'info' => 'low',
                'success' => 'low',
                'warning' => 'medium',
                'error' => 'high',
            ];

            $data = [];
            if ($request->has('title')) {
                $data['title'] = $request->title;
            }
            if ($request->has('message')) {
                $data['content'] = $request->message;
            }
            if ($request->has('type')) {
                $type = $request->type;
                $data['priority'] = $typeToPriority[$type] ?? 'medium';
            }
            if ($request->has('target_audience')) {
                $data['target_audience'] = $request->target_audience;
            }
            if ($request->has('class_id')) {
                $data['class_id'] = $request->class_id;
            }

            $announcement->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Announcement updated successfully',
                'data' => $announcement
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update announcement',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy(string $id)
    {
        try {
            $announcement = Announcement::where('institute_id', auth()->user()->institute_id)
                ->findOrFail($id);

            $announcement->delete();

            return response()->json([
                'success' => true,
                'message' => 'Announcement deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete announcement',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Send announcement to target audience
     * Creates notifications for all users matching the target audience
     */
    public function send(Request $request, string $id)
    {
        DB::beginTransaction();
        try {
            // Get announcement
            $announcement = Announcement::where('institute_id', auth()->user()->institute_id)
                ->with('classModel.students.user')
                ->findOrFail($id);

            // Determine target users based on target_audience
            $targetUsers = collect();

            switch ($announcement->target_audience) {
                case 'all':
                    // All users in the institute
                    $targetUsers = User::where('institute_id', auth()->user()->institute_id)
                        ->where('is_active', true)
                        ->get();
                    break;

                case 'students':
                    // All students in the institute
                    $targetUsers = User::where('institute_id', auth()->user()->institute_id)
                        ->where('role', 'student')
                        ->where('is_active', true)
                        ->get();
                    break;

                case 'teachers':
                    // All teachers in the institute
                    $targetUsers = User::where('institute_id', auth()->user()->institute_id)
                        ->where('role', 'teacher')
                        ->where('is_active', true)
                        ->get();
                    break;

                case 'class':
                    // Students in specific class
                    if ($announcement->class_id && $announcement->classModel) {
                        $targetUsers = $announcement->classModel->students->map(function ($student) {
                            return $student->user;
                        })->filter();
                    }
                    break;

                default:
                    return response()->json([
                        'success' => false,
                        'message' => 'Invalid target audience'
                    ], 422);
            }

            // Create notifications for all target users
            $notificationsCreated = 0;
            foreach ($targetUsers as $user) {
                Notification::create([
                    'user_id' => $user->id,
                    'type' => 'announcement',
                    'title' => $announcement->title,
                    'message' => $announcement->content,
                    'data' => [
                        'announcement_id' => $announcement->id,
                        'priority' => $announcement->priority,
                        'target_audience' => $announcement->target_audience,
                    ],
                ]);
                $notificationsCreated++;
            }

            // Mark announcement as sent (optional: add 'sent_at' field to announcements table)
            // $announcement->update(['sent_at' => now()]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => "Announcement sent successfully to {$notificationsCreated} user(s)",
                'data' => [
                    'announcement' => $announcement,
                    'notifications_created' => $notificationsCreated,
                    'target_audience' => $announcement->target_audience,
                ]
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to send announcement',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
