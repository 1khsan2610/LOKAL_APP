<?php

namespace App\Http\Controllers;

use App\Models\CoinTransaction;
use App\Models\Wallet;
use App\Models\WalletHistory;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class AdminCoinController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        // Transaksi koin terbaru
        $coinTransactions = CoinTransaction::with('user')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        // Statistik koin
        $totalCoinInCirculation = Wallet::whereHas('user', fn($q) => $q->where('role', 'konsumen'))->sum('coin_balance');
        $totalCoinCredit = CoinTransaction::where('type', 'credit')->sum('amount');
        $totalCoinDebit  = CoinTransaction::where('type', 'debit')->sum('amount');

        // Grafik 7 hari
        $coinChart = collect(range(6, 0))->map(function ($daysAgo) {
            $date = now()->subDays($daysAgo)->format('Y-m-d');
            $credit = CoinTransaction::where('type', 'credit')->whereDate('created_at', $date)->sum('amount');
            $debit  = CoinTransaction::where('type', 'debit')->whereDate('created_at', $date)->sum('amount');
            return ['date' => $date, 'credit' => $credit, 'debit' => $debit];
        });

        return view('admin.coins.index', compact(
            'coinTransactions',
            'totalCoinInCirculation',
            'totalCoinCredit',
            'totalCoinDebit',
            'coinChart'
        ));
    }
}
