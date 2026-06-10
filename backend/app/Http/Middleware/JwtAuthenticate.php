<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Services\JwtService;
use App\Models\User;
use Exception;

class JwtAuthenticate
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $token = $this->getToken($request);

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Token tidak ditemukan',
            ], 401);
        }

        try {
            // Verify token
            $decoded = JwtService::verifyToken($token);

            // Check if it's not a refresh token
            if (isset($decoded->type) && $decoded->type === 'refresh') {
                return response()->json([
                    'success' => false,
                    'message' => 'Gunakan access token, bukan refresh token',
                ], 401);
            }

            // Get user
            $user = User::find($decoded->userId);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan',
                ], 404);
            }

            // Set authenticated user
            $request->setUserResolver(function () use ($user) {
                return $user;
            });

            return $next($request);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token tidak valid: ' . $e->getMessage(),
            ], 401);
        }
    }

    /**
     * Get token from request
     */
    private function getToken(Request $request): ?string
    {
        $token = $request->bearerToken();

        if ($token) {
            return $token;
        }

        // Try to get token from Authorization header
        $authHeader = $request->header('Authorization');
        if ($authHeader && str_starts_with($authHeader, 'Bearer ')) {
            return substr($authHeader, 7);
        }

        return null;
    }
}
