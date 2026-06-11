<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Cache\RateLimiter;
use Illuminate\Http\Request;

/**
 * Rate Limiting Middleware
 * Implements per-token rate limiting: 100 req/min per token
 * Ensures SRS Bab 3.4 compliance
 */
class RateLimitMiddleware
{
    public function __construct(protected RateLimiter $limiter)
    {
    }

    public function handle(Request $request, Closure $next)
    {
        // Extract API token from header
        $token = $request->header('X-API-Token') ?? 
                 $request->bearerToken() ?? 
                 $request->ip();

        $key = 'api_rate_limit:' . md5($token);
        
        // 100 requests per minute (100 / 60 = 1.67 per second)
        $maxAttempts = 100;
        $decayMinutes = 1;

        if ($this->limiter->tooManyAttempts($key, $maxAttempts, $decayMinutes)) {
            return response()->json([
                'status' => 'error',
                'code' => 429,
                'message' => 'Rate limit exceeded. Maximum 100 requests per minute.',
                'retry_after' => $this->limiter->availableIn($key),
            ], 429);
        }

        $this->limiter->hit($key, $decayMinutes * 60);

        $response = $next($request);

        return $response
            ->header('X-RateLimit-Limit', $maxAttempts)
            ->header('X-RateLimit-Remaining', $this->limiter->remaining($key, $maxAttempts))
            ->header('X-RateLimit-Reset', $this->limiter->resetAfter($key) ?? 0);
    }
}
