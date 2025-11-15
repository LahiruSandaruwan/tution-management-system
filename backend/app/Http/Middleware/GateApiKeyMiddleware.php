<?php

namespace App\Http\Middleware;

use App\Models\GateDevice;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class GateApiKeyMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $apiKey = $request->header('X-API-Key');

        if (!$apiKey) {
            return response()->json([
                'success' => false,
                'message' => 'API key is required in X-API-Key header.'
            ], 401);
        }

        $device = GateDevice::where('api_key', $apiKey)
            ->where('is_active', true)
            ->first();

        if (!$device) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or inactive API key.'
            ], 401);
        }

        // Update last_seen timestamp
        $device->update(['last_seen' => now()]);

        // Attach device to request for later use
        $request->merge(['gate_device' => $device]);

        return $next($request);
    }
}
