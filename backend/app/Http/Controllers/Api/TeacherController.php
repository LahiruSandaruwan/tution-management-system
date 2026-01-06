<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use App\Models\User;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class TeacherController extends Controller
{
    /**
     * Display a listing of teachers
     */
    public function index(Request $request)
    {
        try {
            $query = Teacher::with(['user', 'classes'])
                ->where('institute_id', $request->institute_id);

            // Filter by active status
            if ($request->has('is_active')) {
                $query->where('is_active', $request->is_active);
            }

            // Search by name
            if ($request->has('search')) {
                $search = $request->search;
                $query->whereHas('user', function ($userQuery) use ($search) {
                    $userQuery->where('name', 'like', "%{$search}%");
                });
            }

            $teachers = $query->paginate(min($request->input('per_page', 15), 100));

            return response()->json([
                'success' => true,
                'data' => $teachers
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch teachers'
            ], 500);
        }
    }

    /**
     * Store a newly created teacher
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:12',
            'phone' => 'required|string|max:20',
            'subject_specialization' => 'required|string|max:255',
            'qualification' => 'nullable|string',
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();
        try {
            // Create user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'role' => 'teacher',
                'institute_id' => $request->institute_id,
            ]);

            // Create teacher profile
            $teacher = Teacher::create([
                'user_id' => $user->id,
                'institute_id' => $request->institute_id,
                'subject_specialization' => $request->subject_specialization,
                'qualification' => $request->qualification,
                'date_of_birth' => $request->date_of_birth,
                'address' => $request->address,
                'photo' => $request->photo,
                'is_active' => true,
            ]);

            DB::commit();

            ActivityLog::logActivity('teacher_created', Teacher::class, $teacher->id);

            return response()->json([
                'success' => true,
                'message' => 'Teacher created successfully',
                'data' => $teacher->load('user')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create teacher'
            ], 500);
        }
    }

    /**
     * Display the specified teacher
     */
    public function show(Request $request, Teacher $teacher)
    {
        // Verify teacher belongs to the same institute
        if ($teacher->institute_id !== $request->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        try {
            $teacher->load(['user', 'classes', 'schedules']);

            return response()->json([
                'success' => true,
                'data' => $teacher
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch teacher'
            ], 500);
        }
    }

    /**
     * Update the specified teacher
     */
    public function update(Request $request, Teacher $teacher)
    {
        // Verify teacher belongs to the same institute
        if ($teacher->institute_id !== $request->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $teacher->user_id,
            'phone' => 'sometimes|string|max:20',
            'subject_specialization' => 'sometimes|string|max:255',
            'qualification' => 'nullable|string',
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();
        try {
            // Update user info
            $teacher->user->update($request->only(['name', 'email', 'phone']));

            // Update teacher profile
            $teacher->update($request->only([
                'subject_specialization',
                'qualification',
                'date_of_birth',
                'address',
                'photo'
            ]));

            DB::commit();

            ActivityLog::logActivity('teacher_updated', Teacher::class, $teacher->id);

            return response()->json([
                'success' => true,
                'message' => 'Teacher updated successfully',
                'data' => $teacher->load('user')
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update teacher'
            ], 500);
        }
    }

    /**
     * Remove the specified teacher
     */
    public function destroy(Request $request, Teacher $teacher)
    {
        // Verify teacher belongs to the same institute
        if ($teacher->institute_id !== $request->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        DB::beginTransaction();
        try {
            ActivityLog::logActivity('teacher_deleted', Teacher::class, $teacher->id);

            $teacher->user->delete(); // This will cascade delete teacher

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Teacher deleted successfully'
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete teacher'
            ], 500);
        }
    }

    /**
     * Toggle teacher active status
     */
    public function toggleStatus(Request $request, Teacher $teacher)
    {
        // Verify teacher belongs to the same institute
        if ($teacher->institute_id !== $request->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access'
            ], 403);
        }

        try {
            $teacher->update(['is_active' => !$teacher->is_active]);

            ActivityLog::logActivity(
                $teacher->is_active ? 'teacher_activated' : 'teacher_deactivated',
                Teacher::class,
                $teacher->id
            );

            return response()->json([
                'success' => true,
                'message' => 'Teacher status updated successfully',
                'data' => $teacher
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update teacher status'
            ], 500);
        }
    }
}
