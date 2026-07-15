<?php

namespace App\Http\Controllers;

use App\Models\UmkmBankAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminBankVerificationController extends Controller
{
    public function __construct()
    {
        $this->middleware(function ($request, $next) {
            if (!Auth::check() || Auth::user()->role !== 'admin') {
                return redirect()->route('login');
            }
            return $next($request);
        });
    }

    /**
     * GET /admin/verifikasi-bank — Daftar rekening bank UMKM yang menunggu verifikasi.
     */
    public function index()
    {
        $pendingAccounts = UmkmBankAccount::with(['umkm', 'verifier'])
            ->pending()
            ->latest()
            ->paginate(20);

        $approvedAccounts = UmkmBankAccount::with(['umkm', 'verifier'])
            ->approved()
            ->latest()
            ->paginate(20, ['*'], 'approved_page');

        return view('admin.bank-verification.index', compact('pendingAccounts', 'approvedAccounts'));
    }

    /**
     * POST /admin/verifikasi-bank/{id}/approve — Setujui rekening bank.
     */
    public function approve($id)
    {
        $account = UmkmBankAccount::findOrFail($id);

        $account->update([
            'status'       => 'approved',
            'verified_at'  => now(),
            'verified_by'  => Auth::id(),
        ]);

        return redirect()->route('admin.bank-verification.index')
            ->with('success', "Rekening bank {$account->bank_name} a/n {$account->account_holder} berhasil disetujui.");
    }

    /**
     * POST /admin/verifikasi-bank/{id}/reject — Tolak rekening bank.
     */
    public function reject(Request $request, $id)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        $account = UmkmBankAccount::findOrFail($id);

        $account->update([
            'status'           => 'rejected',
            'rejection_reason' => $request->rejection_reason,
            'verified_by'      => Auth::id(),
        ]);

        return redirect()->route('admin.bank-verification.index')
            ->with('success', "Rekening bank {$account->bank_name} a/n {$account->account_holder} ditolak.");
    }
}