<?php

namespace App\Services;

use App\Models\User;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Exception;

class JwtService
{
    /**
     * Generate JWT token
     */
    public static function generateToken(User $user): string
    {
        $issuedAt = now();
        $expire = now()->addMinutes(config('jwt.ttl', 60));
        $serverName = config('app.url');

        $algorithm = config('jwt.algorithm', 'HS256');
        
        $data = [
            'iat' => $issuedAt->timestamp,
            'exp' => $expire->timestamp,
            'iss' => $serverName,
            'userId' => $user->id,
            'email' => $user->email,
            'role' => $user->role,
        ];

        // Choose key based on algorithm
        if ($algorithm === 'RS256') {
            $key = config('jwt.private_key');
        } else {
            $key = config('jwt.secret');
        }

        return JWT::encode($data, $key, $algorithm);
    }

    /**
     * Generate Refresh Token
     */
    public static function generateRefreshToken(User $user): string
    {
        $issuedAt = now();
        $expire = now()->addMinutes(config('jwt.refresh_ttl', 20160));
        $serverName = config('app.url');

        $algorithm = config('jwt.algorithm', 'HS256');
        
        $data = [
            'iat' => $issuedAt->timestamp,
            'exp' => $expire->timestamp,
            'iss' => $serverName,
            'userId' => $user->id,
            'type' => 'refresh',
        ];

        // Choose key based on algorithm
        if ($algorithm === 'RS256') {
            $key = config('jwt.private_key');
        } else {
            $key = config('jwt.secret');
        }

        return JWT::encode($data, $key, $algorithm);
    }

    /**
     * Verify and decode JWT token
     */
    public static function verifyToken(string $token)
    {
        try {
            $algorithm = config('jwt.algorithm', 'HS256');

            // Choose key based on algorithm
            if ($algorithm === 'RS256') {
                $key = new Key(config('jwt.public_key'), $algorithm);
            } else {
                $key = new Key(config('jwt.secret'), $algorithm);
            }

            $decoded = JWT::decode($token, $key);
            return $decoded;
        } catch (Exception $e) {
            throw new Exception('Token tidak valid: ' . $e->getMessage());
        }
    }

    /**
     * Generate access and refresh token pair
     */
    public static function generateTokenPair(User $user): array
    {
        return [
            'access_token' => self::generateToken($user),
            'refresh_token' => self::generateRefreshToken($user),
            'token_type' => 'Bearer',
            'expires_in' => config('jwt.ttl', 60) * 60, // in seconds
        ];
    }
}
