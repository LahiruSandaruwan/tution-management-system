<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Schedule;
use App\Models\Student;
use App\Models\Teacher;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    /**
     * Display a listing of schedules
     */
    public function index(Request $request)
    {
        try {
            $query = Schedule::where('institute_id', $request->institute_id)
                ->with(['classModel']);

            if ($request->has('day_of_week')) {
                $query->where('day_of_week', $request->day_of_week);
            }

            $schedules = $query->get();

            return response()->json([
                'success' => true,
                'data' => $schedules
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch schedules',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created schedule
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'class_id' => 'required|exists:classes,id',
            'day_of_week' => 'required|string|in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'room_number' => 'nullable|string|max:50',
        ]);

        try {
            $validated['institute_id'] = $request->institute_id;
            $schedule = Schedule::create($validated);

            return response()->json([
                'success' => true,
                'message' => 'Schedule created successfully',
                'data' => $schedule->load('classModel')
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified schedule
     */
    public function show(Schedule $schedule)
    {
        try {
            return response()->json([
                'success' => true,
                'data' => $schedule->load('classModel')
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified schedule
     */
    public function update(Request $request, Schedule $schedule)
    {
        $validated = $request->validate([
            'class_id' => 'sometimes|exists:classes,id',
            'day_of_week' => 'sometimes|string|in:Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
            'start_time' => 'sometimes|date_format:H:i',
            'end_time' => 'sometimes|date_format:H:i|after:start_time',
            'room_number' => 'nullable|string|max:50',
        ]);

        try {
            $schedule->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Schedule updated successfully',
                'data' => $schedule->load('classModel')
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified schedule
     */
    public function destroy(Schedule $schedule)
    {
        try {
            $schedule->delete();

            return response()->json([
                'success' => true,
                'message' => 'Schedule deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get schedules for a specific teacher
     */
    public function teacherSchedule(Teacher $teacher)
    {
        try {
            $schedules = Schedule::where('institute_id', $teacher->institute_id)
                ->whereHas('classModel', function ($query) use ($teacher) {
                    $query->where('teacher_id', $teacher->id);
                })
                ->with(['classModel'])
                ->get()
                ->groupBy('day_of_week');

            return response()->json([
                'success' => true,
                'data' => $schedules
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch teacher schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get schedules for a specific student
     */
    public function studentSchedule(Student $student)
    {
        try {
            // Get all class IDs the student is enrolled in
            $classIds = $student->classes()->pluck('classes.id');

            $schedules = Schedule::where('institute_id', $student->institute_id)
                ->whereIn('class_id', $classIds)
                ->with(['classModel.teacher.user', 'classModel.subject'])
                ->get()
                ->groupBy('day_of_week');

            return response()->json([
                'success' => true,
                'data' => $schedules
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch student schedule',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
