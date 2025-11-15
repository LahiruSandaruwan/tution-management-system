<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'phone' => 'required|string|max:20',
            'role' => 'required|in:admin,teacher,student',
            'institute_id' => 'required|exists:institutes,id',

            // Student specific fields
            'student_id_number' => 'required_if:role,student|unique:students,student_id_number',
            'grade' => 'required_if:role,student|string|max:50',
            'parent_name' => 'nullable|string|max:255',
            'parent_phone' => 'nullable|string|max:20',

            // Teacher specific fields
            'subject_specialization' => 'required_if:role,teacher|string|max:255',
            'qualification' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Create user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'phone' => $request->phone,
                'role' => $request->role,
                'institute_id' => $request->institute_id,
            ]);

            // Create role-specific profile
            if ($request->role === 'student') {
                Student::create([
                    'user_id' => $user->id,
                    'institute_id' => $request->institute_id,
                    'student_id_number' => $request->student_id_number,
                    'grade' => $request->grade,
                    'parent_name' => $request->parent_name,
                    'parent_phone' => $request->parent_phone,
                    'is_active' => true,
                ]);
            } elseif ($request->role === 'teacher') {
                Teacher::create([
                    'user_id' => $user->id,
                    'institute_id' => $request->institute_id,
                    'subject_specialization' => $request->subject_specialization,
                    'qualification' => $request->qualification,
                    'is_active' => true,
                ]);
            }

            // Create token
            $token = $user->createToken('auth-token')->plainTextToken;

            // Log activity
            ActivityLog::logActivity('user_registered', User::class, $user->id);

            return response()->json([
                'success' => true,
                'message' => 'User registered successfully',
                'data' => [
                    'user' => $user->load($request->role === 'student' ? 'student' : ($request->role === 'teacher' ? 'teacher' : null)),
                    'token' => $token,
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Login user
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials'
            ], 401);
        }

        // Check if user's institute is active
        if ($user->institute && !$user->institute->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Your institute account is inactive. Please contact support.'
            ], 403);
        }

        // Check if student/teacher is active
        if ($user->role === 'student' && $user->student && !$user->student->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Your student account is inactive. Please contact your institute.'
            ], 403);
        }

        if ($user->role === 'teacher' && $user->teacher && !$user->teacher->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Your teacher account is inactive. Please contact your institute.'
            ], 403);
        }

        // Create token
        $token = $user->createToken('auth-token')->plainTextToken;

        // Log activity
        ActivityLog::logActivity('user_login', User::class, $user->id);

        // Load relationships
        $user->load([
            'institute',
            $user->role === 'student' ? 'student.classes' : null,
            $user->role === 'teacher' ? 'teacher.classes' : null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user,
                'token' => $token,
            ]
        ], 200);
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        // Log activity before logout
        ActivityLog::logActivity('user_logout', User::class, $request->user()->id);

        // Revoke current token
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ], 200);
    }

    /**
     * Get authenticated user
     */
    public function me(Request $request)
    {
        $user = $request->user()->load([
            'institute',
            $request->user()->role === 'student' ? 'student.classes' : null,
            $request->user()->role === 'teacher' ? 'teacher.classes' : null,
        ]);

        return response()->json([
            'success' => true,
            'data' => $user
        ], 200);
    }
}
