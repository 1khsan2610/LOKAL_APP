<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletHistory;
use App\Models\CoinTransaction;
use App\Models\Umkm;
use App\Models\UmkmBankAccount;
use App\Services\CoinService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    /**
     * GET /api/wallet — Saldo wallet user
     */
    public function index()
    {
        $wallet = Wallet::where('user_id', auth()->id())->firstOrFail();
        
        $data = [
            'coin_balance' => $wallet->coin_balance,
            'cash_balance' => $wallet->cash_balance ?? 0,
            'commission_balance' => $wallet->commission_balance ?? 0,
            'rupiah_value' => $wallet->coin_balance * CoinService::COIN_TO_RUPIAH,
        ];

        // Jika UMKM, tambahkan status bank
        if (auth()->user()->isUmkm()) {
            $umkm = Umkm::where('user_id', auth()->id())->first();
            if ($umkm) {
                $bankAccount = UmkmBankAccount::where('umkm_id', $umkm->id)->first();
                $data['bank_account'] = $bankAccount ? [
                    'id'             => $bankAccount->id,
                    'bank_name'      => $bankAccount->bank_name,
                    'account_number' => $bankAccount->account_number,
                    'account_holder' => $bankAccount->account_holder,
                    'status'         => $bankAccount->status,
                ] : null;
            }
        }

        return response()->json(['success' => true, 'data' => $data]);
    }

    /**
     * GET /api/wallet/transactions — Riwayat transaksi koin
     */
    public function transactions(Request $request)
    {
        $txns = CoinTransaction::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $txns]);
    }

    /**
     * GET /api/wallet/history — Riwayat mutasi wallet (cash & commission)
     */
    public function history(Request $request)
    {
        $wallet = Wallet::where('user_id', auth()->id())->firstOrFail();
        $histories = WalletHistory::where('wallet_id', $wallet->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $histories]);
    }

    /**
     * POST /api/wallet/redeem — Gunakan koin sebagai diskon
     */
    public function redeem(Request $request)
    {
        $request->validate(['amount' => 'required|integer|min:1']);
        $wallet = Wallet::where('user_id', auth()->id())->firstOrFail();
        if ($wallet->coin_balance < $request->amount) {
            return response()->json(['success' => false, 'message' => 'Saldo Coin tidak mencukupi.'], 422);
        }
        return response()->json(['success' => true, 'message' => 'Coin berhasil digunakan.']);
    }

    /**
     * POST /api/wallet/withdraw — Tarik dana tunai (khusus UMKM)
     * F-11: Validasi bank approved, saldo min Rp 50.000
     */
    public function withdraw(Request $request)
    {
        $user = auth()->user();

        // Hanya UMKM yang bisa tarik dana
        if (!$user->isUmkm()) {
            return response()->json([
                'success' => false,
                'message' => 'Fitur tarik dana hanya untuk pelaku UMKM.',
            ], 403);
        }

        $request->validate([
            'amount' => 'required|integer|min:50000',
        ]);

        $umkm = Umkm::where('user_id', $user->id)->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM tidak ditemukan.',
            ], 403);
        }

        // Validasi bank account WAJIB approved
        $bankAccount = UmkmBankAccount::where('umkm_id', $umkm->id)->first();
        if (!$bankAccount || $bankAccount->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Rekening bank Anda belum diverifikasi. Silakan daftar rekening dan tunggu verifikasi admin.',
            ], 422);
        }

        DB::beginTransaction();
        try {
            $wallet = Wallet::where('user_id', $user->id)->lockForUpdate()->firstOrFail();

            if ($wallet->cash_balance < $request->amount) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Saldo tunai tidak mencukupi.',
                ], 422);
            }

            $wallet->decrement('cash_balance', $request->amount);

            WalletHistory::create([
                'wallet_id'      => $wallet->id,
                'type'           => 'debit',
                'balance_type'   => 'cash',
                'amount'         => $request->amount,
                'balance_before' => $wallet->cash_balance + $request->amount,
                'balance_after'  => $wallet->cash_balance,
                'description'    => "Penarikan dana ke {$bankAccount->bank_name} a/n {$bankAccount->account_holder} ({$bankAccount->account_number})",
                'reference_type' => 'withdrawal',
                'reference_id'   => null,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Permintaan penarikan dana berhasil diproses. Dana akan ditransfer ke rekening terdaftar.',
                'data'    => [
                    'amount'       => $request->amount,
                    'bank_name'    => $bankAccount->bank_name,
                    'account_holder' => $bankAccount->account_holder,
                    'account_number' => $bankAccount->account_number,
                    'remaining_balance' => $wallet->fresh()->cash_balance,
                ],
            ]);
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal memproses penarikan: ' . $e->getMessage(),
            ], 500);
        }
    }
}