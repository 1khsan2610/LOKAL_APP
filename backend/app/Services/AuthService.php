<?php

namespace App\Services;

use App\Models\OtpCode;
use App\Models\User;
use Illuminate\Support\Facades\Redis;
use Twilio\Exceptions\TwilioException;
use Twilio\Rest\Client as TwilioClient;

class AuthService
{
    protected ?TwilioClient $twilioClient = null;

    public function __construct()
    {
        // Initialize Twilio client only if credentials are valid
        try {
            if (config('services.twilio.account_sid') && 
                config('services.twilio.auth_token') &&
                !str_contains(config('services.twilio.account_sid'), 'dummy')) {
                
                $this->twilioClient = new TwilioClient(
                    config('services.twilio.account_sid'),
                    config('services.twilio.auth_token')
                );
            }
        } catch (\Exception $e) {
            \Log::warning('Twilio client initialization failed: ' . $e->getMessage());
            $this->twilioClient = null;
        }
    }

    /**
     * Generate and send OTP
     */
    public function requestOtp(string $phoneNumber): array
    {
        // Normalize phone number
        $phoneNumber = $this->normalizePhoneNumber($phoneNumber);

        // Check if phone is blocked
        $lastOtp = OtpCode::where('phone_number', $phoneNumber)
            ->latest()
            ->first();

        if ($lastOtp && $lastOtp->isLocked()) {
            return [
                'success' => false,
                'message' => 'Terlalu banyak percobaan. Coba lagi dalam beberapa menit.',
                'blocked_until' => $lastOtp->blocked_until,
            ];
        }

        // Generate 6-digit OTP
        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Store OTP in database
        OtpCode::create([
            'phone_number' => $phoneNumber,
            'code' => $code,
            'expires_at' => now()->addMinutes(OtpCode::EXPIRATION_MINUTES),
        ]);

        // Send OTP via SMS
        try {
            $this->sendOtpSms($phoneNumber, $code);
        } catch (TwilioException $e) {
            return [
                'success' => false,
                'message' => 'Gagal mengirim OTP. Silakan coba lagi.',
                'error' => $e->getMessage(),
            ];
        }

        $response = [
            'success' => true,
            'message' => 'OTP berhasil dikirim. Berlaku 5 menit.',
            'phone_number' => $this->maskPhoneNumber($phoneNumber),
        ];

        // DEBUG: Show OTP in development mode
        if (config('app.debug')) {
            $response['debug_otp'] = $code; // FOR DEVELOPMENT ONLY
        }

        return $response;
    }

    /**
     * Verify OTP and create/update user
     */
    public function verifyOtp(string $phoneNumber, string $code, string $name, string $role = 'consumer'): array
    {
        $phoneNumber = $this->normalizePhoneNumber($phoneNumber);

        // Get latest OTP
        $otpRecord = OtpCode::where('phone_number', $phoneNumber)
            ->latest()
            ->first();

        // Validate OTP exists and matches
        if (!$otpRecord) {
            return [
                'success' => false,
                'message' => 'OTP tidak ditemukan. Silakan minta OTP baru.',
            ];
        }

        if ($otpRecord->isExpired()) {
            return [
                'success' => false,
                'message' => 'OTP sudah kadaluarsa. Silakan minta OTP baru.',
            ];
        }

        if ($otpRecord->isLocked()) {
            return [
                'success' => false,
                'message' => 'Terlalu banyak percobaan. Coba lagi nanti.',
                'blocked_until' => $otpRecord->blocked_until,
            ];
        }

        if ($otpRecord->code !== $code) {
            $otpRecord->increment('attempts');

            if ($otpRecord->isMaxAttemptsExceeded()) {
                $otpRecord->update([
                    'blocked_until' => now()->addMinutes(OtpCode::BLOCK_DURATION_MINUTES),
                ]);

                return [
                    'success' => false,
                    'message' => 'Terlalu banyak percobaan. Coba lagi dalam 15 menit.',
                    'blocked_until' => $otpRecord->blocked_until,
                ];
            }

            return [
                'success' => false,
                'message' => 'Kode OTP salah. ' . (OtpCode::MAX_ATTEMPTS - $otpRecord->attempts) . ' percobaan tersisa.',
                'attempts_remaining' => OtpCode::MAX_ATTEMPTS - $otpRecord->attempts,
            ];
        }

        // Mark OTP as verified
        $otpRecord->update(['is_verified' => true]);

        // Find or create user
        $user = User::firstOrCreate(
            ['phone_number' => $phoneNumber],
            [
                'name' => $name,
                'role' => $role,
                'is_verified' => true,
                'verified_at' => now(),
            ]
        );

        // Update user info if it's a new registration
        if ($user->wasRecentlyCreated) {
            $user->update(['name' => $name, 'role' => $role]);

            // Create initial Lokal Coin balance with 50 coins
            \App\Models\LokalCoinBalance::create([
                'user_id' => $user->id,
                'balance' => 50,
                'total_earned' => 50,
            ]);

            // Log initial coin as transaction
            \App\Models\LokalCoinTransaction::create([
                'user_id' => $user->id,
                'type' => 'earn',
                'source' => 'initial',
                'amount' => 50,
                'description' => 'Welcome bonus',
                'expires_at' => now()->addMonths(6),
            ]);
        }

        return [
            'success' => true,
            'message' => 'Verifikasi berhasil.',
            'user' => $user,
        ];
    }

    /**
     * Generate JWT token for user
     */
    public function generateToken(User $user): string
    {
        return $user->createToken('API Token', ['*'])->plainTextToken;
    }

    /**
     * Normalize phone number
     */
    protected function normalizePhoneNumber(string $phoneNumber): string
    {
        // Remove non-numeric characters
        $phoneNumber = preg_replace('/[^0-9]/', '', $phoneNumber);

        // Convert +62 to 0 or 62
        if (substr($phoneNumber, 0, 2) === '62') {
            $phoneNumber = '0' . substr($phoneNumber, 2);
        }

        return $phoneNumber;
    }

    /**
     * Mask phone number for display
     */
    protected function maskPhoneNumber(string $phoneNumber): string
    {
        return substr_replace($phoneNumber, str_repeat('*', 4), 4, 4);
    }

    /**
     * Send OTP via SMS
     */
    public function sendOtpSms(string $phoneNumber, string $code): void
    {
        // Skip SMS in development mode or if Twilio client not initialized
        if (!$this->twilioClient || config('app.debug')) {
            \Log::info("SMS OTP for {$phoneNumber}: {$code}");
            return;
        }

        try {
            $this->twilioClient->messages->create(
                config('services.twilio.from_number'),
                [
                    'to' => '62' . substr($phoneNumber, 1),
                    'body' => "Kode verifikasi LOKAL Anda adalah: {$code}\n\nJangan bagikan kode ini kepada siapapun.",
                ]
            );
        } catch (\Exception $e) {
            \Log::error('Failed to send SMS: ' . $e->getMessage());
            throw $e;
        }
    }
}
