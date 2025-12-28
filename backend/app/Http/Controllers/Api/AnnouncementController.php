<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

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

            $announcements = $query->paginate($request->input('per_page', 20));

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
}
