<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        // For API requests, return null (will result in 401 Unauthorized)
        // For web requests, redirect to login (though /login doesn't exist in this API-only app)
        if ($request->expectsJson() || $request->is('api/*')) {
            return null;
        }
        
        // For web requests, there's no login route, so return null anyway
        return null;
    }
}
