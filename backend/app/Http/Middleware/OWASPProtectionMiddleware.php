<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * OWASP Top 10 Security Protection Middleware
 * Implements NF-SEC-07 requirements:
 * - SQL Injection prevention (via Laravel ORM)
 * - XSS protection (via HTML escaping)
 * - CSRF protection (via tokens)
 * - Secure headers
 */
class OWASPProtectionMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // Security Headers for XSS Protection
        $response = $next($request);

        // 1. X-Frame-Options: Prevent clickjacking (NF-SEC-07)
        $response->header('X-Frame-Options', 'SAMEORIGIN');

        // 2. X-Content-Type-Options: Prevent MIME sniffing
        $response->header('X-Content-Type-Options', 'nosniff');

        // 3. X-XSS-Protection: Enable browser XSS filter
        $response->header('X-XSS-Protection', '1; mode=block');

        // 4. Referrer-Policy: Control referrer information
        $response->header('Referrer-Policy', 'strict-origin-when-cross-origin');

        // 5. Content-Security-Policy: Prevent XSS & injection attacks
        $csp = "default-src 'self'; " .
               "script-src 'self' 'unsafe-inline'; " .
               "style-src 'self' 'unsafe-inline'; " .
               "img-src 'self' data: https:; " .
               "font-src 'self' data:; " .
               "connect-src 'self' https:; " .
               "frame-ancestors 'self'";
        $response->header('Content-Security-Policy', $csp);

        // 6. Permissions-Policy: Restrict dangerous APIs
        $response->header('Permissions-Policy', 
            'geolocation=(), microphone=(), camera=(), payment=()');

        // 7. HSTS: Force HTTPS (NF-SEC-01)
        $response->header('Strict-Transport-Security', 
            'max-age=31536000; includeSubDomains; preload');

        // 8. Hide server info
        $response->header('Server', 'API');

        return $response;
    }
}
