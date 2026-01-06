<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ValidatePaginationMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Validate and limit per_page parameter
        if ($request->has('per_page')) {
            $perPage = $request->input('per_page');

            // Ensure it's a positive integer
            if (!is_numeric($perPage) || $perPage < 1) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid per_page parameter. Must be a positive integer.'
                ], 400);
            }

            // Enforce maximum limit of 100
            if ($perPage > 100) {
                $request->merge(['per_page' => 100]);
            }
        }

        // Validate limit parameter (for non-paginated queries)
        if ($request->has('limit')) {
            $limit = $request->input('limit');

            if (!is_numeric($limit) || $limit < 1) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid limit parameter. Must be a positive integer.'
                ], 400);
            }

            // Enforce maximum limit of 100
            if ($limit > 100) {
                $request->merge(['limit' => 100]);
            }
        }

        return $next($request);
    }
}
