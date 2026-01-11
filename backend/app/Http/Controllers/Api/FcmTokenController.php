<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FcmToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class FcmTokenController extends Controller
{
    /**
     * Store or update FCM token for the authenticated user
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'device_type' => 'nullable|string|in:android,ios,web',
            'device_id' => 'nullable|string|max:255',
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
            $user = $request->user();

            // Check if token already exists for this user
            $existingToken = FcmToken::where('token', $request->token)->first();

            if ($existingToken) {
                // Update existing token
                $existingToken->update([
                    'user_id' => $user->id, // In case token was reassigned to new user
                    'device_type' => $request->device_type ?? $existingToken->device_type,
                    'device_id' => $request->device_id ?? $existingToken->device_id,
                    'is_active' => true,
                    'last_used_at' => now(),
                ]);

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'FCM token updated successfully',
                    'data' => $existingToken
                ], 200);
            }

            // If device_id provided, deactivate other tokens for same device
            if ($request->device_id) {
                FcmToken::where('user_id', $user->id)
                    ->where('device_id', $request->device_id)
                    ->update(['is_active' => false]);
            }

            // Create new token
            $fcmToken = FcmToken::create([
                'user_id' => $user->id,
                'token' => $request->token,
                'device_type' => $request->device_type ?? 'unknown',
                'device_id' => $request->device_id,
                'is_active' => true,
                'last_used_at' => now(),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'FCM token registered successfully',
                'data' => $fcmToken
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to register FCM token',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all FCM tokens for the authenticated user
     */
    public function index(Request $request)
    {
        try {
            $tokens = FcmToken::where('user_id', $request->user()->id)
                ->orderBy('last_used_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $tokens
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch FCM tokens',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete a specific FCM token (logout from device)
     */
    public function destroy(Request $request, string $id)
    {
        try {
            $token = FcmToken::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$token) {
                return response()->json([
                    'success' => false,
                    'message' => 'FCM token not found'
                ], 404);
            }

            $token->delete();

            return response()->json([
                'success' => true,
                'message' => 'FCM token deleted successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete FCM token',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Deactivate a specific FCM token (don't delete, just disable)
     */
    public function deactivate(Request $request, string $id)
    {
        try {
            $token = FcmToken::where('id', $id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$token) {
                return response()->json([
                    'success' => false,
                    'message' => 'FCM token not found'
                ], 404);
            }

            $token->deactivate();

            return response()->json([
                'success' => true,
                'message' => 'FCM token deactivated successfully',
                'data' => $token
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to deactivate FCM token',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete all FCM tokens for the authenticated user (logout from all devices)
     */
    public function destroyAll(Request $request)
    {
        try {
            $deletedCount = FcmToken::where('user_id', $request->user()->id)->delete();

            return response()->json([
                'success' => true,
                'message' => "Deleted {$deletedCount} FCM token(s) successfully"
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete FCM tokens',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
