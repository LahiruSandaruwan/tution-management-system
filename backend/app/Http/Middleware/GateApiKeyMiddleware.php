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
        $apiKey = $request->header('X-API-Key') ?? $request->header('X-Gate-API-Key');

        if (!$apiKey) {
            return response()->json([
                'success' => false,
                'message' => 'API key is required in X-API-Key header.',
            ], 401);
        }

        // In testing environment, allow simple config-based API key
        if (app()->environment('testing') && $apiKey === config('app.gate_api_key', env('GATE_API_KEY'))) {
            return $next($request);
        }

        $device = GateDevice::where('api_key', $apiKey)
            ->where('is_active', true)
            ->first();

        if (!$device) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or inactive API key.',
            ], 401);
        }

        // Update last_seen timestamp
        $device->update(['last_seen' => now()]);

        // Attach device to request for later use
        $request->merge(['gate_device' => $device]);

        return $next($request);
    }
}
