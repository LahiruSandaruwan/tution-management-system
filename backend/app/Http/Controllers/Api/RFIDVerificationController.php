<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\RFIDService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RFIDVerificationController extends Controller
{
    protected $rfidService;

    public function __construct(RFIDService $rfidService)
    {
        $this->rfidService = $rfidService;
    }

    /**
     * Verify RFID card access
     * Called by ESP32 gate device
     */
    public function verify(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'card_uid' => 'required|string',
            'device_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $result = $this->rfidService->verifyCardAccess(
                $request->card_uid,
                $request->device_id
            );

            return response()->json([
                'success' => true,
                'data' => $result,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Verification failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Log gate entry/exit action
     * Called by ESP32 after successful verification
     */
    public function logAccess(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'card_uid' => 'required|string',
            'action' => 'required|in:entry,exit',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            // Get institute_id from gate device
            $instituteId = $request->gate_device->institute_id;

            $result = $this->rfidService->logGateAction(
                $request->card_uid,
                $request->action,
                $instituteId
            );

            return response()->json([
                'success' => true,
                'data' => $result,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logging failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get live gate feed for admin dashboard
     * Real-time monitoring of gate activity
     */
    public function liveFeed(Request $request)
    {
        try {
            $limit = $request->input('limit', 50);
            $instituteId = $request->gate_device->institute_id;

            $feed = $this->rfidService->getLiveGateFeed($instituteId, $limit);
            $statistics = $this->rfidService->getGateStatistics($instituteId);

            return response()->json([
                'success' => true,
                'data' => [
                    'logs' => $feed,
                    'statistics' => $statistics,
                ],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch live feed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
