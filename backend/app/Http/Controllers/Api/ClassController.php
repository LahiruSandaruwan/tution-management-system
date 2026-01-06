<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClassModel;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ClassController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $query = ClassModel::with(['teacher.user', 'subject', 'students.user'])
            ->where('institute_id', $request->user()->institute_id);

        // Filter by subject
        if ($request->has('subject_id')) {
            $query->where('subject_id', $request->subject_id);
        }

        // Filter by grade
        if ($request->has('grade')) {
            $query->where('grade', $request->grade);
        }

        // Filter by teacher
        if ($request->has('teacher_id')) {
            $query->where('teacher_id', $request->teacher_id);
        }

        // Filter by active status
        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('grade', 'like', "%{$search}%");
            });
        }

        $classes = $query->orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data' => $classes,
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'subject_id' => 'required|exists:subjects,id',
            'grade' => 'required|string|max:50',
            'teacher_id' => 'nullable|exists:teachers,id',
            'day_of_week' => 'required|in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'monthly_fee' => 'required|numeric|min:0',
            'capacity' => 'required|integer|min:1',
            'description' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $class = ClassModel::create([
            'institute_id' => $request->user()->institute_id,
            'name' => $request->name,
            'subject_id' => $request->subject_id,
            'grade' => $request->grade,
            'teacher_id' => $request->teacher_id,
            'day_of_week' => $request->day_of_week,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'monthly_fee' => $request->monthly_fee,
            'capacity' => $request->capacity,
            'description' => $request->description,
            'is_active' => $request->boolean('is_active', true),
        ]);

        $class->load(['teacher.user', 'subject']);

        return response()->json([
            'success' => true,
            'message' => 'Class created successfully',
            'data' => $class,
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, string $id)
    {
        $class = ClassModel::with(['teacher.user', 'subject', 'students.user'])
            ->findOrFail($id);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $class,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        $class = ClassModel::findOrFail($id);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'subject_id' => 'exists:subjects,id',
            'grade' => 'string|max:50',
            'teacher_id' => 'nullable|exists:teachers,id',
            'day_of_week' => 'in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'date_format:H:i',
            'end_time' => 'date_format:H:i|after:start_time',
            'monthly_fee' => 'numeric|min:0',
            'capacity' => 'integer|min:1',
            'description' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $class->update($request->only([
            'name',
            'subject_id',
            'grade',
            'teacher_id',
            'day_of_week',
            'start_time',
            'end_time',
            'monthly_fee',
            'capacity',
            'description',
            'is_active',
        ]));

        $class->load(['teacher.user', 'subject']);

        return response()->json([
            'success' => true,
            'message' => 'Class updated successfully',
            'data' => $class,
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        $class = ClassModel::findOrFail($id);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        $class->delete();

        return response()->json([
            'success' => true,
            'message' => 'Class deleted successfully',
        ]);
    }

    /**
     * Get students enrolled in a class
     */
    public function students(Request $request, string $id)
    {
        $class = ClassModel::with('students.user')->findOrFail($id);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $class->students,
        ]);
    }

    /**
     * Enroll a student in a class
     */
    public function enrollStudent(Request $request, string $id)
    {
        $class = ClassModel::findOrFail($id);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'student_id' => 'required|exists:students,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $student = Student::findOrFail($request->student_id);

        // Verify student belongs to the same institute
        if ($student->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        // Check if already enrolled
        if ($class->students()->where('student_id', $student->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Student is already enrolled in this class',
            ], 400);
        }

        // Check if class is full
        if ($class->students()->count() >= $class->capacity) {
            return response()->json([
                'success' => false,
                'message' => 'Class is full',
            ], 400);
        }

        $class->students()->attach($student->id, [
            'enrolled_date' => now()->format('Y-m-d'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Student enrolled successfully',
        ]);
    }

    /**
     * Unenroll a student from a class
     */
    public function unenrollStudent(Request $request, string $id)
    {
        $class = ClassModel::findOrFail($id);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'student_id' => 'required|exists:students,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $class->students()->detach($request->student_id);

        return response()->json([
            'success' => true,
            'message' => 'Student unenrolled successfully',
        ]);
    }

    /**
     * Remove a student from a class (alias for unenrollStudent)
     */
    public function removeStudent(Request $request, string $classId, string $studentId)
    {
        $class = ClassModel::findOrFail($classId);

        // Verify class belongs to the same institute
        if ($class->institute_id !== $request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized access',
            ], 403);
        }

        $class->students()->detach($studentId);

        return response()->json([
            'success' => true,
            'message' => 'Student removed successfully',
        ]);
    }
}
