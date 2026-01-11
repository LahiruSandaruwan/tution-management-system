<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\RfidCard;
use App\Models\Student;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class RfidCardController extends Controller
{
    /**
     * Display a listing of RFID cards
     */
    public function index(Request $request)
    {
        try {
            $query = RfidCard::with(['student.user', 'institute'])
                ->where('institute_id', $request->institute_id);

            // Filter by status
            if ($request->has('status')) {
                $query->where('status', $request->status);
            }

            // Filter by student
            if ($request->has('student_id')) {
                $query->where('student_id', $request->student_id);
            }

            // Search by card UID or student name
            if ($request->has('search')) {
                $search = $request->search;
                $query->where(function ($q) use ($search) {
                    $q->where('card_uid', 'like', "%{$search}%")
                      ->orWhereHas('student.user', function ($userQuery) use ($search) {
                          $userQuery->where('name', 'like', "%{$search}%");
                      });
                });
            }

            $cards = $query->paginate(min($request->input('per_page', 15), 100));

            return response()->json([
                'success' => true,
                'data' => $cards,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch RFID cards',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Store a newly created RFID card
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'card_uid' => 'required|string|unique:rfid_cards,card_uid',
            'student_id' => 'nullable|exists:students,id',
            'issued_date' => 'nullable|date',
            'status' => 'nullable|in:active,inactive,lost,blocked',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        DB::beginTransaction();

        try {
            // Verify student belongs to same institute if provided
            if ($request->student_id) {
                $student = Student::where('id', $request->student_id)
                    ->where('institute_id', $request->institute_id)
                    ->first();

                if (!$student) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Student not found in your institute',
                    ], 404);
                }

                // Check if student already has an active RFID card
                $existingCard = RfidCard::where('student_id', $request->student_id)
                    ->where('status', 'active')
                    ->first();

                if ($existingCard) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Student already has an active RFID card',
                    ], 422);
                }
            }

            $card = RfidCard::create([
                'card_uid' => $request->card_uid,
                'student_id' => $request->student_id,
                'institute_id' => $request->institute_id,
                'issued_date' => $request->issued_date ?? now(),
                'status' => $request->status ?? 'active',
            ]);

            // Log activity
            ActivityLog::create([
                'user_id' => $request->user()->id,
                'institute_id' => $request->institute_id,
                'action' => 'create',
                'model_type' => 'RfidCard',
                'model_id' => $card->id,
                'description' => "Created RFID card {$card->card_uid}",
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'RFID card created successfully',
                'data' => $card->load(['student.user', 'institute']),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified RFID card
     */
    public function show(Request $request, string $id)
    {
        try {
            $card = RfidCard::with(['student.user', 'institute', 'gateLogs' => function ($query) {
                $query->latest()->limit(10);
            }])
                ->where('id', $id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$card) {
                return response()->json([
                    'success' => false,
                    'message' => 'RFID card not found',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $card,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update the specified RFID card
     */
    public function update(Request $request, string $id)
    {
        $validator = Validator::make($request->all(), [
            'card_uid' => 'sometimes|string|unique:rfid_cards,card_uid,' . $id,
            'student_id' => 'nullable|exists:students,id',
            'issued_date' => 'nullable|date',
            'status' => 'nullable|in:active,inactive,lost,blocked',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        DB::beginTransaction();

        try {
            $card = RfidCard::where('id', $id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$card) {
                return response()->json([
                    'success' => false,
                    'message' => 'RFID card not found',
                ], 404);
            }

            // Verify student belongs to same institute if changing assignment
            if ($request->has('student_id') && $request->student_id) {
                $student = Student::where('id', $request->student_id)
                    ->where('institute_id', $request->institute_id)
                    ->first();

                if (!$student) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Student not found in your institute',
                    ], 404);
                }

                // Check if student already has another active RFID card
                $existingCard = RfidCard::where('student_id', $request->student_id)
                    ->where('status', 'active')
                    ->where('id', '!=', $id)
                    ->first();

                if ($existingCard) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Student already has another active RFID card',
                    ], 422);
                }
            }

            $card->update($request->only(['card_uid', 'student_id', 'issued_date', 'status']));

            // Log activity
            ActivityLog::create([
                'user_id' => $request->user()->id,
                'institute_id' => $request->institute_id,
                'action' => 'update',
                'model_type' => 'RfidCard',
                'model_id' => $card->id,
                'description' => "Updated RFID card {$card->card_uid}",
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'RFID card updated successfully',
                'data' => $card->load(['student.user', 'institute']),
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to update RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified RFID card
     */
    public function destroy(Request $request, string $id)
    {
        DB::beginTransaction();

        try {
            $card = RfidCard::where('id', $id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$card) {
                return response()->json([
                    'success' => false,
                    'message' => 'RFID card not found',
                ], 404);
            }

            $cardUid = $card->card_uid;

            // Log activity before deletion
            ActivityLog::create([
                'user_id' => $request->user()->id,
                'institute_id' => $request->institute_id,
                'action' => 'delete',
                'model_type' => 'RfidCard',
                'model_id' => $card->id,
                'description' => "Deleted RFID card {$cardUid}",
            ]);

            $card->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'RFID card deleted successfully',
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Assign RFID card to a student
     */
    public function assignToStudent(Request $request, string $id)
    {
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

        DB::beginTransaction();

        try {
            $card = RfidCard::where('id', $id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$card) {
                return response()->json([
                    'success' => false,
                    'message' => 'RFID card not found',
                ], 404);
            }

            // Verify student belongs to same institute
            $student = Student::where('id', $request->student_id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$student) {
                return response()->json([
                    'success' => false,
                    'message' => 'Student not found in your institute',
                ], 404);
            }

            // Check if student already has an active RFID card
            $existingCard = RfidCard::where('student_id', $request->student_id)
                ->where('status', 'active')
                ->where('id', '!=', $id)
                ->first();

            if ($existingCard) {
                return response()->json([
                    'success' => false,
                    'message' => 'Student already has an active RFID card. Please deactivate or block the existing card first.',
                ], 422);
            }

            // Check if card is already assigned to another student
            if ($card->student_id && $card->student_id != $request->student_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Card is already assigned to another student. Please unassign it first.',
                ], 422);
            }

            // Assign card to student and activate it
            $card->update([
                'student_id' => $request->student_id,
                'status' => 'active',
                'issued_date' => now(),
            ]);

            // Log activity
            ActivityLog::create([
                'user_id' => $request->user()->id,
                'institute_id' => $request->institute_id,
                'action' => 'assign',
                'model_type' => 'RfidCard',
                'model_id' => $card->id,
                'description' => "Assigned RFID card {$card->card_uid} to student {$student->user->name}",
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'RFID card assigned to student successfully',
                'data' => $card->load(['student.user', 'institute']),
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to assign RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Block an RFID card
     */
    public function block(Request $request, string $id)
    {
        $validator = Validator::make($request->all(), [
            'reason' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        DB::beginTransaction();

        try {
            $card = RfidCard::where('id', $id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$card) {
                return response()->json([
                    'success' => false,
                    'message' => 'RFID card not found',
                ], 404);
            }

            if ($card->status === 'blocked') {
                return response()->json([
                    'success' => false,
                    'message' => 'Card is already blocked',
                ], 422);
            }

            $previousStatus = $card->status;
            $card->update(['status' => 'blocked']);

            // Log activity
            $description = "Blocked RFID card {$card->card_uid}";
            if ($request->reason) {
                $description .= ". Reason: {$request->reason}";
            }

            ActivityLog::create([
                'user_id' => $request->user()->id,
                'institute_id' => $request->institute_id,
                'action' => 'block',
                'model_type' => 'RfidCard',
                'model_id' => $card->id,
                'description' => $description,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'RFID card blocked successfully',
                'data' => $card->load(['student.user', 'institute']),
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to block RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Unblock an RFID card
     */
    public function unblock(Request $request, string $id)
    {
        DB::beginTransaction();

        try {
            $card = RfidCard::where('id', $id)
                ->where('institute_id', $request->institute_id)
                ->first();

            if (!$card) {
                return response()->json([
                    'success' => false,
                    'message' => 'RFID card not found',
                ], 404);
            }

            if ($card->status !== 'blocked') {
                return response()->json([
                    'success' => false,
                    'message' => 'Card is not currently blocked',
                ], 422);
            }

            $card->update(['status' => 'active']);

            // Log activity
            ActivityLog::create([
                'user_id' => $request->user()->id,
                'institute_id' => $request->institute_id,
                'action' => 'unblock',
                'model_type' => 'RfidCard',
                'model_id' => $card->id,
                'description' => "Unblocked RFID card {$card->card_uid}",
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'RFID card unblocked successfully',
                'data' => $card->load(['student.user', 'institute']),
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to unblock RFID card',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
