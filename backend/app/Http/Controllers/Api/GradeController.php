<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Grade;
use App\Models\Student;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    /**
     * Store a newly created grade
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'student_id' => 'required|exists:students,id',
            'class_id' => 'required|exists:classes,id',
            'subject_id' => 'nullable|exists:subjects,id',
            'exam_id' => 'nullable|exists:exams,id',
            'marks_obtained' => 'required|numeric|min:0',
            'total_marks' => 'required|numeric|min:0',
            'grade' => 'nullable|string|max:2',
            'remarks' => 'nullable|string',
        ]);

        try {
            $validated['institute_id'] = $request->institute_id;
            $percentage = ($validated['marks_obtained'] / $validated['total_marks']) * 100;
            $validated['is_pass'] = $percentage >= 35;

            $grade = Grade::create($validated);

            return response()->json([
                'success' => true,
                'message' => 'Grade added successfully',
                'data' => $grade->load(['student.user', 'class', 'subject', 'exam'])
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to add grade',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update an existing grade
     */
    public function update(Request $request, Grade $grade)
    {
        $validated = $request->validate([
            'marks_obtained' => 'sometimes|numeric|min:0',
            'total_marks' => 'sometimes|numeric|min:0',
            'grade' => 'nullable|string|max:2',
            'remarks' => 'nullable|string',
        ]);

        try {
            if (isset($validated['marks_obtained']) || isset($validated['total_marks'])) {
                $marksObtained = $validated['marks_obtained'] ?? $grade->marks_obtained;
                $totalMarks = $validated['total_marks'] ?? $grade->total_marks;
                $percentage = ($marksObtained / $totalMarks) * 100;
                $validated['is_pass'] = $percentage >= 35;
            }

            $grade->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Grade updated successfully',
                'data' => $grade->load(['student.user', 'class', 'subject', 'exam'])
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update grade',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete a grade
     */
    public function destroy(Grade $grade)
    {
        try {
            $grade->delete();
            return response()->json([
                'success' => true,
                'message' => 'Grade deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete grade',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all grades for a specific student
     */
    public function studentGrades(Student $student)
    {
        try {
            $grades = Grade::where('student_id', $student->id)
                ->with(['class', 'subject', 'exam'])
                ->latest('created_at')
                ->get();

            // Group grades by subject
            $subjectSummaries = $grades->groupBy('subject_id')->map(function ($subjectGrades) {
                $subject = $subjectGrades->first()->subject;
                $class = $subjectGrades->first()->class;

                return [
                    'subject_name' => $subject ? $subject->name : 'General',
                    'class_name' => $class ? $class->name : 'N/A',
                    'total_exams' => $subjectGrades->count(),
                    'average' => round($subjectGrades->avg(fn($g) => ($g->marks_obtained / $g->total_marks) * 100), 2),
                    'highest_marks' => round($subjectGrades->max(fn($g) => ($g->marks_obtained / $g->total_marks) * 100), 2),
                    'lowest_marks' => round($subjectGrades->min(fn($g) => ($g->marks_obtained / $g->total_marks) * 100), 2),
                    'grades' => $subjectGrades->map(function ($grade) {
                        $percentage = ($grade->marks_obtained / $grade->total_marks) * 100;
                        return [
                            'id' => $grade->id,
                            'exam_name' => $grade->exam ? $grade->exam->name : 'Exam',
                            'exam_date' => $grade->created_at->format('Y-m-d'),
                            'marks' => $grade->marks_obtained,
                            'max_marks' => $grade->total_marks,
                            'percentage' => round($percentage, 2),
                            'grade' => $grade->grade ?? $this->calculateGrade($percentage),
                            'remarks' => $grade->remarks,
                        ];
                    })->values()
                ];
            })->values();

            // Overall statistics
            $overallStats = [
                'overall_average' => round($grades->avg(fn($g) => ($g->marks_obtained / $g->total_marks) * 100), 2),
                'highest' => round($grades->max(fn($g) => ($g->marks_obtained / $g->total_marks) * 100), 2),
                'lowest' => round($grades->min(fn($g) => ($g->marks_obtained / $g->total_marks) * 100), 2),
                'total_exams' => $grades->count(),
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'overall_stats' => $overallStats,
                    'subject_summaries' => $subjectSummaries,
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch student grades',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get grades for a specific class and exam
     */
    public function classExamGrades($classId, $examId)
    {
        try {
            $grades = Grade::where('class_id', $classId)
                ->where('exam_id', $examId)
                ->with(['student.user'])
                ->get();

            return response()->json([
                'success' => true,
                'data' => $grades
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch class exam grades',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Calculate grade based on percentage
     */
    private function calculateGrade($percentage)
    {
        if ($percentage >= 75) return 'A';
        if ($percentage >= 65) return 'B';
        if ($percentage >= 55) return 'C';
        if ($percentage >= 35) return 'S';
        return 'F';
    }
}
