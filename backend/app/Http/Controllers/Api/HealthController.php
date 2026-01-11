<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class HealthController extends Controller
{
    /**
     * Basic health check endpoint
     * Used by load balancers and uptime monitoring services
     */
    public function index(): JsonResponse
    {
        return response()->json([
            'status' => 'ok',
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Detailed health check with component status
     * Checks database, cache, and storage connectivity
     */
    public function detailed(): JsonResponse
    {
        $health = [
            'status' => 'healthy',
            'timestamp' => now()->toIso8601String(),
            'checks' => [],
        ];

        // Check database connectivity
        try {
            DB::connection()->getPdo();
            $health['checks']['database'] = [
                'status' => 'up',
                'message' => 'Database connection successful',
            ];
        } catch (\Exception $e) {
            $health['status'] = 'unhealthy';
            $health['checks']['database'] = [
                'status' => 'down',
                'message' => 'Database connection failed',
                'error' => config('app.debug') ? $e->getMessage() : 'Connection error',
            ];
        }

        // Check cache connectivity (Redis/File)
        try {
            Cache::put('health_check', true, 10);
            $cached = Cache::get('health_check');

            $health['checks']['cache'] = [
                'status' => $cached ? 'up' : 'degraded',
                'message' => $cached ? 'Cache working correctly' : 'Cache read failed',
                'driver' => config('cache.default'),
            ];
        } catch (\Exception $e) {
            $health['status'] = 'degraded';
            $health['checks']['cache'] = [
                'status' => 'down',
                'message' => 'Cache connection failed',
                'error' => config('app.debug') ? $e->getMessage() : 'Connection error',
            ];
        }

        // Check storage accessibility
        try {
            $testFile = 'health_check_' . time() . '.txt';
            \Storage::disk('local')->put($testFile, 'health check');
            $exists = \Storage::disk('local')->exists($testFile);
            \Storage::disk('local')->delete($testFile);

            $health['checks']['storage'] = [
                'status' => $exists ? 'up' : 'degraded',
                'message' => $exists ? 'Storage read/write successful' : 'Storage write failed',
            ];
        } catch (\Exception $e) {
            $health['status'] = 'degraded';
            $health['checks']['storage'] = [
                'status' => 'down',
                'message' => 'Storage access failed',
                'error' => config('app.debug') ? $e->getMessage() : 'Access error',
            ];
        }

        // Application info
        $health['application'] = [
            'name' => config('app.name'),
            'environment' => config('app.env'),
            'version' => '1.0.0', // Update this with actual version
        ];

        // System resources (basic)
        $health['system'] = [
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
        ];

        // Determine HTTP status code
        $statusCode = match($health['status']) {
            'healthy' => 200,
            'degraded' => 200, // Still operational but with warnings
            'unhealthy' => 503, // Service unavailable
            default => 200,
        };

        return response()->json($health, $statusCode);
    }

    /**
     * Database-specific health check
     */
    public function database(): JsonResponse
    {
        try {
            $pdo = DB::connection()->getPdo();
            $databaseName = DB::connection()->getDatabaseName();

            // Test query
            $result = DB::select('SELECT 1 as test');

            return response()->json([
                'status' => 'up',
                'database' => $databaseName,
                'connection' => 'successful',
                'test_query' => $result[0]->test === 1 ? 'passed' : 'failed',
                'timestamp' => now()->toIso8601String(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'down',
                'message' => 'Database connection failed',
                'error' => config('app.debug') ? $e->getMessage() : 'Connection error',
                'timestamp' => now()->toIso8601String(),
            ], 503);
        }
    }

    /**
     * Cache-specific health check
     */
    public function cache(): JsonResponse
    {
        try {
            $key = 'health_check_' . time();
            $value = 'test_value_' . uniqid();

            // Write test
            Cache::put($key, $value, 10);

            // Read test
            $retrieved = Cache::get($key);

            // Cleanup
            Cache::forget($key);

            $status = ($retrieved === $value) ? 'up' : 'degraded';

            return response()->json([
                'status' => $status,
                'driver' => config('cache.default'),
                'write' => 'successful',
                'read' => ($retrieved === $value) ? 'successful' : 'failed',
                'timestamp' => now()->toIso8601String(),
            ], $status === 'up' ? 200 : 503);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'down',
                'driver' => config('cache.default'),
                'message' => 'Cache operation failed',
                'error' => config('app.debug') ? $e->getMessage() : 'Operation error',
                'timestamp' => now()->toIso8601String(),
            ], 503);
        }
    }
}
