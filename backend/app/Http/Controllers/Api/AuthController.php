<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Http\Requests\Auth\RequestOtpRequest;
use App\Models\OtpCode;
use App\Models\User;
use App\Models\LokalCoinBalance;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Request OTP
     */
    public function requestOtp(RequestOtpRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            $phone = $validated['phone_number'];

            // Format phone number
            if (!str_starts_with($phone, '+62') && !str_starts_with($phone, '62')) {
                $phone = str_starts_with($phone, '0') 
                    ? '62' . substr($phone, 1) 
                    : '62' . $phone;
            }

            // Generate OTP
            $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            // Delete old OTP records
            OtpCode::where('phone_number', $phone)->delete();

            // Save new OTP
            OtpCode::create([
                'phone_number' => $phone,
                'code' => $otp,
                'attempts' => 0,
                'expires_at' => now()->addMinutes(5),
                'is_verified' => 0,
            ]);

            // Try to send SMS
            try {
                $this->authService->sendOtpSms($phone, $otp);
            } catch (\Exception $e) {
                \Log::warning('SMS sending failed: ' . $e->getMessage());
            }

            return response()->json([
                'success' => true,
                'message' => 'OTP berhasil dikirim. Berlaku 5 menit.',
                'phone_number' => $phone,
                'debug_otp' => $otp,
            ], 200);
        } catch (\Exception $e) {
            \Log::error('Request OTP error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim OTP: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Verify OTP
     */
    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            $phone = $validated['phone_number'];
            $code = $validated['code'];
            $name = $validated['name'] ?? 'User';
            $role = $validated['role'] ?? 'consumer';

            // Format phone
            if (!str_starts_with($phone, '+62') && !str_starts_with($phone, '62')) {
                $phone = str_starts_with($phone, '0') 
                    ? '62' . substr($phone, 1) 
                    : '62' . $phone;
            }

            // Check OTP
            $otpCode = OtpCode::where('phone_number', $phone)
                ->where('is_verified', 0)
                ->first();

            if (!$otpCode) {
                return response()->json([
                    'success' => false,
                    'message' => 'OTP tidak ditemukan atau sudah digunakan',
                ], 422);
            }

            if (now() > $otpCode->expires_at) {
                return response()->json([
                    'success' => false,
                    'message' => 'OTP sudah kadaluarsa',
                ], 422);
            }

            if ($otpCode->code !== $code) {
                $otpCode->increment('attempts');
                if ($otpCode->attempts >= 5) {
                    $otpCode->update(['is_verified' => 0]);
                }
                return response()->json([
                    'success' => false,
                    'message' => 'Kode OTP salah',
                ], 422);
            }

            // Mark OTP as verified
            $otpCode->update(['is_verified' => 1]);

            // Find or create user
            $user = User::firstOrCreate(
                ['phone_number' => $phone],
                [
                    'name' => $name,
                    'email' => 'user_' . time() . '@lokal.id',
                    'password' => Hash::make(Str::random(16)),
                    'role' => $role,
                    'email_verified_at' => now(),
                ]
            );

            // Create Lokal Coin balance jika belum ada
            if (!$user->lokalCoinBalance) {
                LokalCoinBalance::create([
                    'user_id' => $user->id,
                    'balance' => 50,
                    'currency' => 'IDR',
                ]);
            }

            // Generate token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Verifikasi berhasil',
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'phone_number' => $user->phone_number,
                    'role' => $user->role,
                    'email' => $user->email,
                ],
            ], 200);
        } catch (\Exception $e) {
            \Log::error('Verify OTP error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error verifikasi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Refresh token
     */
    public function refresh(): JsonResponse
    {
        $user = Auth::guard('sanctum')->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $token = $this->authService->generateToken($user);

        return response()->json([
            'success' => true,
            'token' => $token,
        ], 200);
    }

    /**
     * Logout
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil',
        ], 200);
    }
}