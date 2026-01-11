<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class InstituteMiddleware
{
    /**
     * Handle an incoming request.
     *
     * Ensures that the authenticated user belongs to an institute
     * and adds institute_id to the request for data isolation.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        if (!$request->user()->institute_id) {
            return response()->json([
                'success' => false,
                'message' => 'User is not associated with any institute.',
            ], 403);
        }

        // Add institute_id to request for easy access in controllers
        $request->merge(['institute_id' => $request->user()->institute_id]);

        return $next($request);
    }
}
