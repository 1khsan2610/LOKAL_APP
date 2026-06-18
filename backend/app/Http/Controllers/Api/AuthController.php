<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Http\Requests\Auth\RequestOtpRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Http\Requests\Auth\UpdatePasswordRequest;
use App\Http\Resources\UserResource;
use App\Models\OtpCode;
use App\Models\User;
use App\Models\LokalCoinBalance;
use App\Models\LoginAttempt;
use App\Models\EmailVerification;
use App\Models\UmkmProfile;
use App\Services\AuthService;
use App\Services\JwtService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Exception;
use App\Models\PasswordResetToken;
use Illuminate\Support\Facades\Hash as HashFacade;

class AuthController extends Controller
{
    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Login dengan email dan password (JWT RS256)
     */
    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            $email = $validated['email'];
            $password = $validated['password'];
            $ipAddress = $request->ip();

            // Check if email is blocked from too many attempts
            $loginAttempt = LoginAttempt::getOrCreate($email, $ipAddress);

            if ($loginAttempt->isBlocked()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akun Anda terkunci. Coba lagi dalam beberapa menit.',
                    'blocked_until' => $loginAttempt->blocked_until,
                ], 429);
            }

            // Find user by email
            $user = User::where('email', $email)->first();

            if (!$user || !Hash::check($password, $user->password)) {
                // Increment failed attempts
                $loginAttempt->incrementAttempts();

                return response()->json([
                    'success' => false,
                    'message' => 'Email atau password salah.',
                    'attempts_remaining' => LoginAttempt::MAX_ATTEMPTS - $loginAttempt->attempts,
                ], 401);
            }

            // Successful login - reset attempts
            $loginAttempt->resetAttempts();

            // Generate JWT tokens
            $tokenPair = JwtService::generateTokenPair($user);

            // Log audit trail
            \Log::info('User login successful', [
                'user_id' => $user->id,
                'email' => $email,
                'ip_address' => $ipAddress,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'phone_number' => $user->phone_number,
                        'role' => $user->role,
                    ],
                    'tokens' => $tokenPair,
                ],
            ], 200);
        } catch (Exception $e) {
            \Log::error('Login error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat login: ' . $e->getMessage(),
            ], 500);
        }
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
     * Refresh Access Token
     */
    public function refresh(Request $request): JsonResponse
    {
        try {
            $refreshToken = $request->bearerToken();

            if (!$refreshToken) {
                return response()->json([
                    'success' => false,
                    'message' => 'Refresh token diperlukan.',
                ], 401);
            }

            // Verify refresh token
            $decoded = JwtService::verifyToken($refreshToken);

            // Check if token is refresh token type
            if (!isset($decoded->type) || $decoded->type !== 'refresh') {
                return response()->json([
                    'success' => false,
                    'message' => 'Token tidak valid untuk refresh.',
                ], 401);
            }

            // Get user
            $user = User::find($decoded->userId);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan.',
                ], 404);
            }

            // Generate new token pair
            $tokenPair = JwtService::generateTokenPair($user);

            return response()->json([
                'success' => true,
                'message' => 'Token berhasil di-refresh',
                'data' => $tokenPair,
            ], 200);
        } catch (Exception $e) {
            \Log::error('Refresh token error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Refresh token gagal: ' . $e->getMessage(),
            ], 401);
        }
    }

    /**
     * Logout
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            $token = $request->bearerToken();

            if (!$token) {
                return response()->json([
                    'success' => false,
                    'message' => 'Token diperlukan untuk logout.',
                ], 401);
            }

            // Verify token
            $decoded = JwtService::verifyToken($token);

            $user = User::find($decoded->userId);

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak ditemukan.',
                ], 404);
            }

            // Log audit trail
            \Log::info('User logout successful', [
                'user_id' => $user->id,
                'email' => $user->email,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Logout berhasil',
            ], 200);
        } catch (Exception $e) {
            \Log::error('Logout error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Logout gagal: ' . $e->getMessage(),
            ], 401);
        }
    }

    /**
     * Get authenticated user profile
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => new UserResource($user),
        ], 200);
    }

    /**
     * Update authenticated user profile
     */
    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        try {
            $user = $request->user();
            $user->update($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Profil berhasil diperbarui.',
                'data' => new UserResource($user->refresh()),
            ], 200);
        } catch (Exception $e) {
            \Log::error('Update profile error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui profil: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update authenticated user password
     */
    public function updatePassword(UpdatePasswordRequest $request): JsonResponse
    {
        $user = $request->user();

        if (!Hash::check($request->input('current_password'), $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama tidak cocok.',
            ], 422);
        }

        $user->update([
            'password' => Hash::make($request->input('new_password'), ['rounds' => 12]),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah.',
        ], 200);
    }

    /**
     * Register Account (Email & Password)
     * Support role: consumer (direct active) & umkm (pending verification)
     */
    public function registerAccount(RegisterRequest $request): JsonResponse
    {
        try {
            $validated = $request->validated();
            $email = $validated['email'];
            $name = $validated['name'];
            $password = $validated['password'];
            $phoneNumber = $validated['phone_number'];
            $role = $validated['role'];
            $ipAddress = $request->ip();

            // Rate limiting: 5 requests per minute per IP
            $rateKey = "register_attempts_{$ipAddress}";
            $attempts = cache()->get($rateKey, 0);
            
            if ($attempts >= 5) {
                return response()->json([
                    'success' => false,
                    'message' => 'Terlalu banyak percobaan registrasi. Silakan coba lagi dalam 1 menit.',
                ], 429);
            }

            // Increment attempt counter
            cache()->put($rateKey, $attempts + 1, now()->addMinute());

            // Check if email already exists
            if (User::where('email', $email)->exists()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email sudah terdaftar.',
                ], 422);
            }

            // Hash password with bcrypt cost factor 12
            $hashedPassword = Hash::make($password, [
                'rounds' => 12,
            ]);

            // Create user
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => $hashedPassword,
                'phone_number' => $phoneNumber,
                'role' => $role,
                'email_verified_at' => null, // Pending email verification
            ]);

            // Create Lokal Coin balance (50 coins on registration)
            LokalCoinBalance::create([
                'user_id' => $user->id,
                'balance' => 50,
                'currency' => 'IDR',
            ]);

            // For UMKM role: create UmkmProfile with pending_verification status
            if ($role === 'umkm') {
                UmkmProfile::create([
                    'user_id' => $user->id,
                    'business_name' => $name,
                    'status' => 'pending_verification',
                    'is_verified' => false,
                    'location' => null,
                    'coordinates' => null,
                ]);
            }

            // Generate email verification token (24 hours)
            $verificationToken = Str::random(64);
            EmailVerification::create([
                'email' => $email,
                'token' => $verificationToken,
                'expires_at' => now()->addHours(EmailVerification::EXPIRATION_HOURS),
            ]);

            // Send verification email (via AuthService)
            try {
                $this->authService->sendVerificationEmail(
                    $email,
                    $name,
                    $verificationToken
                );
            } catch (\Exception $e) {
                \Log::warning('Failed to send verification email: ' . $e->getMessage());
                // Don't fail the registration if email fails
            }

            // Log audit trail
            \Log::info('User registration successful', [
                'user_id' => $user->id,
                'email' => $email,
                'role' => $role,
                'ip_address' => $ipAddress,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil. Silakan verifikasi email Anda.',
                'data' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'phone_number' => $user->phone_number,
                        'role' => $user->role,
                    ],
                    'verification' => [
                        'required' => true,
                        'expires_in_hours' => EmailVerification::EXPIRATION_HOURS,
                        'message' => 'Token verifikasi telah dikirim ke email Anda. Berlaku 24 jam.',
                    ],
                ],
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);
        } catch (Exception $e) {
            \Log::error('Registration error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat registrasi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Verify email using token (POST /auth/verify-email)
     */
    public function verifyEmail(Request $request): JsonResponse
    {
        try {
            $token = $request->input('token');

            if (!$token) {
                return response()->json(['success' => false, 'message' => 'Token diperlukan.'], 422);
            }

            $ev = EmailVerification::where('token', $token)->first();

            if (!$ev) {
                return response()->json(['success' => false, 'message' => 'Token verifikasi tidak ditemukan.'], 404);
            }

            if ($ev->isExpired()) {
                return response()->json(['success' => false, 'message' => 'Token verifikasi sudah kadaluarsa.'], 410);
            }

            if ($ev->isVerified()) {
                return response()->json(['success' => true, 'message' => 'Email sudah terverifikasi.'], 200);
            }

            // Mark as verified
            $ev->verify();

            // Update user's email_verified_at if user exists
            $user = User::where('email', $ev->email)->first();
            if ($user && !$user->email_verified_at) {
                $user->update(['email_verified_at' => now()]);

                // Ensure LokalCoinBalance exists (award 50 if missing)
                if (!$user->lokalCoinBalance) {
                    \App\Models\LokalCoinBalance::create([
                        'user_id' => $user->id,
                        'balance' => 50,
                        'currency' => 'IDR',
                    ]);
                }
            }

            return response()->json(['success' => true, 'message' => 'Verifikasi email berhasil.'], 200);
        } catch (Exception $e) {
            \Log::error('Verify email error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Gagal memverifikasi email: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Forgot password - create reset token and send email
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        try {
            $email = $request->input('email');

            if (!$email) {
                return response()->json(['success' => false, 'message' => 'Email diperlukan.'], 422);
            }

            $user = User::where('email', $email)->first();

            if (!$user) {
                // For security, do not reveal whether email exists
                return response()->json(['success' => true, 'message' => 'Jika email terdaftar, link reset akan dikirimkan.'], 200);
            }

            // Rate limiting: throttle per email
            $rateKey = "forgot_password_{$email}";
            $attempts = cache()->get($rateKey, 0);
            if ($attempts >= 3) {
                return response()->json(['success' => false, 'message' => 'Terlalu banyak permintaan. Silakan coba nanti.'], 429);
            }
            cache()->put($rateKey, $attempts + 1, now()->addMinutes(10));

            $token = Str::random(64);

            PasswordResetToken::create([
                'email' => $email,
                'token' => $token,
                'expires_at' => now()->addHour(),
            ]);

            try {
                $this->authService->sendResetPasswordEmail($email, $user->name ?? 'User', $token);
            } catch (\Exception $e) {
                \Log::warning('Failed to send reset password email: ' . $e->getMessage());
            }

            return response()->json(['success' => true, 'message' => 'Jika email terdaftar, link reset akan dikirimkan.'], 200);
        } catch (Exception $e) {
            \Log::error('Forgot password error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Gagal memproses permintaan: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Reset password using token
     */
    public function resetPassword(Request $request): JsonResponse
    {
        try {
            $token = $request->input('token');
            $password = $request->input('password');

            if (!$token || !$password) {
                return response()->json(['success' => false, 'message' => 'Token dan password diperlukan.'], 422);
            }

            $prt = PasswordResetToken::where('token', $token)->first();

            if (!$prt) {
                return response()->json(['success' => false, 'message' => 'Token reset tidak ditemukan.'], 404);
            }

            if ($prt->isExpired()) {
                return response()->json(['success' => false, 'message' => 'Token reset sudah kadaluarsa.'], 410);
            }

            if ($prt->used_at) {
                return response()->json(['success' => false, 'message' => 'Token sudah digunakan.'], 410);
            }

            $user = User::where('email', $prt->email)->first();
            if (!$user) {
                return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
            }

            // Update password
            $user->update(['password' => HashFacade::make($password, ['rounds' => 12])]);

            // Mark token used
            $prt->markUsed();

            try {
                $this->authService->sendPasswordChangedNotification($user->email, $user->name ?? 'User');
            } catch (\Exception $e) {
                \Log::warning('Failed to send password changed email: ' . $e->getMessage());
            }

            return response()->json(['success' => true, 'message' => 'Password berhasil diubah.'], 200);
        } catch (Exception $e) {
            \Log::error('Reset password error: ' . $e->getMessage());
            return response()->json(['success' => false, 'message' => 'Gagal mengubah password: ' . $e->getMessage()], 500);
        }
    }
}