<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Umkm;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password as PasswordRule;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * POST /api/auth/register-account
     * Daftar akun baru (konsumen / umkm)
     */
    public function register(Request $request)
    {
        $request->validate([
            'name'       => 'required|string|max:100',
            'email'      => 'required|email|unique:users,email',
            'password'   => ['required', 'confirmed', PasswordRule::min(8)],
            'phone'      => 'required|string|max:20',
            'role'       => 'required|in:konsumen,umkm',
            // UMKM fields (required when role=umkm)
            'store_name' => 'required_if:role,umkm|string|max:100',
            'store_category' => 'required_if:role,umkm|string|max:50',
            'store_description' => 'nullable|string|max:500',
        ]);

        // Create user
        $user = User::create([
            'name'              => $request->name,
            'email'             => $request->email,
            'password'          => Hash::make($request->password),
            'phone'             => $request->phone,
            'role'              => $request->role,
            'email_verified_at' => null,
        ]);

        // Create wallet for every user
        Wallet::create([
            'user_id'     => $user->id,
            'coin_balance' => 0,
        ]);

        // Create UMKM store if role is umkm
        if ($request->role === 'umkm') {
            Umkm::create([
                'user_id'     => $user->id,
                'name'        => $request->store_name,
                'category'    => $request->store_category,
                'description' => $request->store_description,
                'is_verified' => false,
                'is_active'   => true,
            ]);
        }

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil dibuat. Silakan verifikasi email kamu.',
            'data'    => [
                'user'  => $user->load('wallet', 'umkm'),
                'token' => $token,
            ],
        ], 201);
    }

    /**
     * POST /api/auth/login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $credentials = $request->only('email', 'password');

        if (!$token = JWTAuth::attempt($credentials)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah.',
            ], 401);
        }

        $user = auth()->user();

        if (!$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Akun kamu telah dinonaktifkan. Hubungi admin.',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data'    => [
                'user'         => $user->load('wallet', 'umkm'),
                'token'        => $token,
                'token_type'   => 'bearer',
                'expires_in'   => config('jwt.ttl') * 60,
            ],
        ]);
    }

    /**
     * POST /api/auth/logout
     */
    public function logout()
    {
        JWTAuth::invalidate(JWTAuth::getToken());
        return response()->json(['success' => true, 'message' => 'Logout berhasil.']);
    }

    /**
     * GET /api/auth/me
     */
    public function me()
    {
        $user = auth()->user()->load('wallet', 'umkm', 'addresses');
        return response()->json(['success' => true, 'data' => $user]);
    }

    /**
     * POST /api/auth/refresh
     */
    public function refresh()
    {
        try {
            $token = JWTAuth::refresh(JWTAuth::getToken());
            return response()->json([
                'success'    => true,
                'token'      => $token,
                'expires_in' => config('jwt.ttl') * 60,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Token tidak valid.'], 401);
        }
    }

    /**
     * POST /api/auth/forgot-password
     */
    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email|exists:users,email']);

        $status = Password::sendResetLink($request->only('email'));

        return response()->json([
            'success' => $status === Password::RESET_LINK_SENT,
            'message' => $status === Password::RESET_LINK_SENT
                ? 'Link reset password sudah dikirim ke email kamu.'
                : 'Gagal mengirim email. Coba lagi.',
        ]);
    }

    /**
     * POST /api/auth/reset-password
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'token'    => 'required',
            'email'    => 'required|email',
            'password' => ['required', 'confirmed', PasswordRule::min(8)],
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->forceFill(['password' => Hash::make($password)])->save();
            }
        );

        return response()->json([
            'success' => $status === Password::PASSWORD_RESET,
            'message' => $status === Password::PASSWORD_RESET
                ? 'Password berhasil direset.'
                : 'Token tidak valid atau sudah kedaluwarsa.',
        ]);
    }

    /**
     * POST /api/auth/verify-email
     */
    public function verifyEmail(Request $request)
    {
        $request->validate([
            'id'   => 'required|integer',
            'hash' => 'required|string',
        ]);

        $user = User::findOrFail($request->id);

        if (!hash_equals(sha1($user->email), $request->hash)) {
            return response()->json(['success' => false, 'message' => 'Link verifikasi tidak valid.'], 400);
        }

        $user->markEmailAsVerified();

        return response()->json(['success' => true, 'message' => 'Email berhasil diverifikasi.']);
    }
}
