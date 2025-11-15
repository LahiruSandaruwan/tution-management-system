<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Student;
use App\Models\User;
use App\Models\ActivityLog;
use App\Services\AttendanceService;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class StudentController extends Controller
{
    protected $attendanceService;
    protected $paymentService;

    public function __construct(AttendanceService $attendanceService, PaymentService $paymentService)
    {
        $this->attendanceService = $attendanceService;
        $this->paymentService = $paymentService;
    }

    /**
     * Display a listing of students
     */
    public function index(Request $request)
    {
        try {
            $query = Student::with(['user', 'classes'])
                ->where('institute_id', $request->institute_id);

            // Filter by active status
            if ($request->has('is_active')) {
                $query->where('is_active', $request->is_active);
            }

            // Filter by grade
            if ($request->has('grade')) {
                $query->where('grade', $request->grade);
            }

            // Search by name or student ID
            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function ($q) use ($search) {
                    $q->where('student_id_number', 'like', "%{$search}%")
                      ->orWhereHas('user', function ($userQuery) use ($search) {
                          $userQuery->where('name', 'like', "%{$search}%");
                      });
                });
            }

            $students = $query->paginate($request->input('per_page', 15));

            return response()->json([
                'success' => true,
                'data' => $students
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch students',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created student
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'phone' => 'required|string|max:20',
            'student_id_number' => 'required|string|unique:students,student_id_number',
            'grade' => 'required|string|max:50',
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'parent_name' => 'nullable|string|max:255',
            'parent_phone' => 'nullable|string|max:20',
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
                'role' => 'student',
                'institute_id' => $request->institute_id,
            ]);

            // Create student profile
            $student = Student::create([
                'user_id' => $user->id,
                'institute_id' => $request->institute_id,
                'student_id_number' => $request->student_id_number,
                'grade' => $request->grade,
                'date_of_birth' => $request->date_of_birth,
                'address' => $request->address,
                'parent_name' => $request->parent_name,
                'parent_phone' => $request->parent_phone,
                'photo' => $request->photo,
                'is_active' => true,
            ]);

            DB::commit();

            ActivityLog::logActivity('student_created', Student::class, $student->id);

            return response()->json([
                'success' => true,
                'message' => 'Student created successfully',
                'data' => $student->load('user')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create student',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified student
     */
    public function show(Student $student)
    {
        try {
            $student->load(['user', 'classes', 'rfidCard']);

            return response()->json([
                'success' => true,
                'data' => $student
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch student',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified student
     */
    public function update(Request $request, Student $student)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $student->user_id,
            'phone' => 'sometimes|string|max:20',
            'grade' => 'sometimes|string|max:50',
            'date_of_birth' => 'nullable|date',
            'address' => 'nullable|string',
            'parent_name' => 'nullable|string|max:255',
            'parent_phone' => 'nullable|string|max:20',
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
            $student->user->update($request->only(['name', 'email', 'phone']));

            // Update student profile
            $student->update($request->only([
                'grade',
                'date_of_birth',
                'address',
                'parent_name',
                'parent_phone',
                'photo'
            ]));

            DB::commit();

            ActivityLog::logActivity('student_updated', Student::class, $student->id);

            return response()->json([
                'success' => true,
                'message' => 'Student updated successfully',
                'data' => $student->load('user')
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update student',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified student
     */
    public function destroy(Student $student)
    {
        DB::beginTransaction();
        try {
            ActivityLog::logActivity('student_deleted', Student::class, $student->id);

            $student->user->delete(); // This will cascade delete student due to foreign key

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Student deleted successfully'
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete student',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Toggle student active status
     */
    public function toggleStatus(Student $student)
    {
        try {
            $student->update(['is_active' => !$student->is_active]);

            ActivityLog::logActivity(
                $student->is_active ? 'student_activated' : 'student_deactivated',
                Student::class,
                $student->id
            );

            return response()->json([
                'success' => true,
                'message' => 'Student status updated successfully',
                'data' => $student
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update student status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get student attendance summary
     */
    public function attendanceSummary(Request $request, Student $student)
    {
        try {
            $month = $request->input('month');
            $year = $request->input('year');

            $summary = $this->attendanceService->getStudentAttendanceSummary(
                $student->id,
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
                'message' => 'Failed to fetch attendance summary',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get student payment summary
     */
    public function paymentSummary(Student $student)
    {
        try {
            $summary = $this->paymentService->getStudentPaymentSummary($student->id);

            return response()->json([
                'success' => true,
                'data' => $summary
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch payment summary',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
