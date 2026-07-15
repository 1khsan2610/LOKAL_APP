<?php

namespace App\Http\Controllers;

use App\Models\Wallet;
use App\Models\WalletHistory;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class AdminWalletController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Manajemen Wallet — daftar semua wallet dengan saldo
     */
    public function index()
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        $wallets = Wallet::with('user')
            ->orderBy('cash_balance', 'desc')
            ->paginate(20);

        // Ringkasan
        $summary = [
            'total_wallets'        => Wallet::count(),
            'total_cash'           => Wallet::sum('cash_balance'),
            'total_commission'     => Wallet::sum('commission_balance'),
            'total_coin'           => Wallet::sum('coin_balance'),
            'total_cash_umkm'      => Wallet::whereHas('user', fn($q) => $q->where('role', 'umkm'))->sum('cash_balance'),
            'total_commission_admin' => Wallet::whereHas('user', fn($q) => $q->where('role', 'admin'))->sum('commission_balance'),
        ];

        return view('admin.wallets.index', compact('wallets', 'summary'));
    }

    /**
     * Riwayat Mutasi Dana — semua wallet_histories
     */
    public function histories()
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        $histories = WalletHistory::with('wallet.user')
            ->orderBy('created_at', 'desc')
            ->paginate(30);

        // Filter balance_type untuk ringkasan
        $summaryByType = WalletHistory::selectRaw("
            balance_type,
            SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as total_credit,
            SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as total_debit,
            COUNT(*) as count
        ")->groupBy('balance_type')->get();

        return view('admin.wallet-histories.index', compact('histories', 'summaryByType'));
    }
}