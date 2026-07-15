<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Umkm;
use App\Models\Order;
use App\Models\CoinTransaction;
use App\Models\Product;
use App\Models\Wallet;
use App\Models\WalletHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AdminWebController extends Controller
{
    /**
     * Tampilkan Landing Page publik + data Tim.
     */
    public function index()
    {
        $team = [
            ['name' => 'Ikhsan',                'role' => 'Project Manager',      'photo' => 'ikhsan.jpg'],
            ['name' => 'Linda Anjarini',        'role' => 'Backend Developer',    'photo' => 'linda.jpg'],
            ['name' => 'Najwa Alifah',          'role' => 'Backend Developer',    'photo' => 'najwa.jpg'],
            ['name' => 'Kiara Evi Nurdiati',    'role' => 'Frontend Developer',   'photo' => 'kiara.jpg'],
            ['name' => 'Naufal Al Farros',      'role' => 'Frontend Developer',   'photo' => 'naufal.jpg'],
            ['name' => 'Ikbal Maulana Aspahni', 'role' => 'QA',                   'photo' => 'ikbal.jpg'],
        ];

        return view('landing', compact('team'));
    }

    /**
     * Tampilkan halaman login admin.
     */
    public function showLogin()
    {
        // Jika sudah login sebagai admin, redirect ke dashboard
        if (Auth::check() && Auth::user()->role === 'admin') {
            return redirect()->route('admin.dashboard');
        }

        return view('auth.admin-login');
    }

    /**
     * Proses login admin (session-based).
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        // Cari user dengan role admin
        $user = User::where('email', $credentials['email'])
                    ->where('role', 'admin')
                    ->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return back()->withErrors([
                'email' => 'Email atau password admin salah.',
            ])->onlyInput('email');
        }

        // Login via session guard 'web'
        Auth::login($user, $request->boolean('remember'));

        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    /**
     * Dashboard admin — ambil statistik untuk view.
     */
    public function dashboard()
    {
        // Pastikan hanya admin yang bisa akses
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        // Ambil wallet admin untuk data komisi
        $adminWallet = Wallet::whereHas('user', fn($q) => $q->where('role', 'admin'))->first();
        $commissionBalance = $adminWallet ? $adminWallet->commission_balance : 0;

        // Total cash_balance seluruh UMKM (dana tersedia untuk ditarik)
        $totalUmkmCash = Wallet::whereHas('user', fn($q) => $q->where('role', 'umkm'))->sum('cash_balance');

        // Total cash_balance seluruh konsumen (koin)
        $totalConsumerCoin = Wallet::whereHas('user', fn($q) => $q->where('role', 'konsumen'))->sum('coin_balance');

        // Total mutasi wallet_histories hari ini
        $todayMutations = WalletHistory::whereDate('created_at', today())->count();

        // Data grafik sederhana: 7 hari terakhir total pemasukan komisi
        $commissionChart = collect(range(6, 0))->map(function ($daysAgo) {
            $date = now()->subDays($daysAgo)->format('Y-m-d');
            $total = WalletHistory::where('balance_type', 'commission')
                ->where('type', 'credit')
                ->whereDate('created_at', $date)
                ->sum('amount');
            return ['date' => $date, 'total' => $total];
        });

        $stats = [
            'total_umkm'              => Umkm::count(),
            'umkm_pending'            => Umkm::where('is_verified', false)->count(),
            'umkm_verified'           => Umkm::where('is_verified', true)->count(),
            'total_products'          => Product::where('is_active', true)->count(),
            'total_orders'            => Order::count(),
            'total_revenue'           => Order::where('status', 'delivered')->sum('total'),
            'total_coin_transactions' => CoinTransaction::count(),
            'total_users'             => User::count(),
            'commission_balance'      => $commissionBalance,
            'total_umkm_cash'         => $totalUmkmCash,
            'total_consumer_coin'     => $totalConsumerCoin,
            'today_mutations'         => $todayMutations,
            'commission_chart'        => $commissionChart,
        ];

        return view('admin.dashboard', compact('stats'));
    }

    /**
     * Verifikasi dokumen UMKM dari status pending → verified.
     */
    public function verifyUmkm($id)
    {
        $umkm = Umkm::findOrFail($id);
        $umkm->update(['is_verified' => true]);

        return redirect()->back()->with('success', "UMKM {$umkm->name} berhasil diverifikasi.");
    }

    /**
     * Logout admin dari session web.
     */
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/login');
    }
}