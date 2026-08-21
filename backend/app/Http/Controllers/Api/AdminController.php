<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\{User, Umkm, Order, Product, CoinTransaction, Wallet, WalletHistory, Setting};
use App\Models\UmkmBankAccount;
use App\Services\CoinService;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

// ─── AdminController ────────────────────────────────────────────────
class AdminController extends Controller
{
    public function __construct(
        private NotificationService $notifService
    ) {}

    /**
     * GET /api/admin/dashboard
     * Dashboard utama admin dengan data real-time dari database
     */
    public function dashboard()
    {
        // Hitung total revenue dari order yang sudah delivered (selesai)
        $totalRevenue = Order::whereIn('status', ['delivered', 'processing', 'shipped'])->sum('total');
        $revenueThisMonth = Order::whereIn('status', ['delivered', 'processing', 'shipped'])
            ->whereMonth('created_at', now()->month)
            ->sum('total');

        // Wallet admin untuk statistik saldo komisi
        $adminWallet = Wallet::whereHas('user', fn($q) => $q->where('role', 'admin'))->first();
        $commissionBalance = $adminWallet ? $adminWallet->commission_balance : 0;
        $adminCashBalance = $adminWallet ? $adminWallet->cash_balance : 0;

        // Total saldo tunai seluruh UMKM
        $totalUmkmCash = Wallet::whereHas('user.umkm')->sum('cash_balance');

        // Mutasi hari ini (total transaksi yang masuk ke wallet)
        $todayMutations = WalletHistory::whereDate('created_at', now()->toDateString())
            ->where('type', 'credit')
            ->sum('amount');

        // Coin beredar
        $totalCoinCirculation = Wallet::sum('coin_balance');
        $totalCoinValue = $totalCoinCirculation * CoinService::COIN_TO_RUPIAH;

        // Order stats
        $totalOrders = Order::count();
        $pendingOrders = Order::where('status', 'pending')->count();
        $processingOrders = Order::where('status', 'processing')->count();
        $deliveredOrders = Order::where('status', 'delivered')->count();

        return response()->json(['success' => true, 'data' => [
            'total_users'           => User::count(),
            'total_umkm'            => Umkm::count(),
            'total_orders'          => $totalOrders,
            'pending_orders'        => $pendingOrders,
            'processing_orders'     => $processingOrders,
            'delivered_orders'      => $deliveredOrders,
            'total_products'        => Product::where('is_active', true)->count(),
            'total_revenue'         => $totalRevenue,
            'revenue_this_month'    => $revenueThisMonth,
            'active_users'          => User::where('is_active', true)->count(),
            'unverified_umkm'       => Umkm::where('is_verified', false)->count(),
            // Financial data
            'commission_balance'    => $commissionBalance,
            'admin_cash_balance'    => $adminCashBalance,
            'total_umkm_cash'       => $totalUmkmCash,
            'total_coin_circulation' => $totalCoinCirculation,
            'total_coin_value'      => $totalCoinValue,
            'today_mutations'       => $todayMutations,
        ]]);
    }

    /**
     * GET /api/admin/finance
     * Overview keuangan & sirkulasi dana platform
     */
    public function finance()
    {
        $adminWallet = Wallet::whereHas('user', fn($q) => $q->where('role', 'admin'))->first();

        // Total komisi admin
        $totalCommission = $adminWallet ? $adminWallet->commission_balance : 0;

        // Total saldo UMKM
        $totalUmkmCash = Wallet::whereHas('user.umkm')->sum('cash_balance');

        // Total uang yang sudah ditarik UMKM
        $totalWithdrawn = WalletHistory::where('type', 'debit')
            ->where('balance_type', 'cash')
            ->where('reference_type', 'withdrawal')
            ->sum('amount');

        // Komisi yang sudah terkumpul bulan ini
        $monthlyCommission = WalletHistory::where('type', 'credit')
            ->where('balance_type', 'commission')
            ->whereMonth('created_at', now()->month)
            ->sum('amount');

        // Total pemasukan platform dari komisi
        $totalPlatformIncome = WalletHistory::where('type', 'credit')
            ->where('balance_type', 'commission')
            ->sum('amount');

        // Total cashback coin yang sudah diberikan
        $totalCashbackCoin = WalletHistory::where('type', 'debit')
            ->where('balance_type', 'commission')
            ->where('description', 'like', '%Cashback%')
            ->sum('amount');

        return response()->json(['success' => true, 'data' => [
            'total_commission'      => $totalCommission,
            'total_umkm_cash'       => $totalUmkmCash,
            'total_withdrawn'       => $totalWithdrawn,
            'monthly_commission'    => $monthlyCommission,
            'total_platform_income' => $totalPlatformIncome,
            'total_cashback_coin'   => $totalCashbackCoin,
        ]]);
    }

    public function users(Request $request)
    {
        $users = User::with('wallet')
            ->when($request->role,   fn($q, $r) => $q->where('role', $r))
            ->when($request->search, fn($q, $s) => $q->where('name','like',"%$s%")->orWhere('email','like',"%$s%"))
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $users]);
    }

    public function toggleUserStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);
        if ($user->id === auth()->id()) return response()->json(['success' => false, 'message' => 'Tidak bisa menonaktifkan diri sendiri.'], 422);
        $user->update(['is_active' => !$user->is_active]);
        return response()->json(['success' => true, 'message' => 'Status pengguna diperbarui.']);
    }

    public function umkmList(Request $request)
    {
        $umkms = Umkm::with('user')
            ->when($request->verified, fn($q, $v) => $q->where('is_verified', $v === 'true'))
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $umkms]);
    }

    public function verifyUmkm($id)
    {
        $umkm = Umkm::findOrFail($id);
        $umkm->update(['is_verified' => true]);
        return response()->json(['success' => true, 'message' => "UMKM {$umkm->name} berhasil diverifikasi."]);
    }

    /**
     * GET /api/admin/orders
     * Monitoring seluruh transaksi order
     */
    public function orders(Request $request)
    {
        $orders = Order::with(['user', 'items.product', 'payment'])
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->when($request->search, fn($q, $s) => $q->where('order_number','like',"%$s%"))
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $orders]);
    }

    /**
     * GET /api/admin/transactions
     * Riwayat transaksi koin & mutasi wallet
     */
    public function transactions()
    {
        // Gabungkan coin transactions dan wallet histories
        $coinTxns = CoinTransaction::with('user')
            ->select('id', 'user_id', 'type as txn_type', 'amount', 'description as txn_description', 'created_at')
            ->get()
            ->map(fn($t) => [
                'id'          => "coin_{$t->id}",
                'user_id'     => $t->user_id,
                'type'        => $t->txn_type,
                'balance_type'=> 'coin',
                'amount'      => $t->amount,
                'description' => $t->txn_description,
                'created_at'  => $t->created_at,
            ]);

        $walletHistories = WalletHistory::with('wallet.user')
            ->orderBy('created_at','desc')
            ->limit(50)
            ->get()
            ->map(fn($h) => [
                'id'          => "wallet_{$h->id}",
                'user_id'     => $h->wallet->user_id ?? null,
                'type'        => $h->type,
                'balance_type'=> $h->balance_type,
                'amount'      => $h->amount,
                'description' => $h->description,
                'created_at'  => $h->created_at,
            ]);

        $merged = $coinTxns->merge($walletHistories)
            ->sortByDesc('created_at')
            ->values()
            ->take(50);

        return response()->json(['success' => true, 'data' => $merged]);
    }

    /**
     * GET /api/admin/wallet-mutations
     * Riwayat mutasi saldo (uang & koin) - untuk tab Riwayat Mutasi
     */
    public function walletMutations(Request $request)
    {
        $query = WalletHistory::with('wallet.user')
            ->when($request->balance_type, fn($q, $t) => $q->where('balance_type', $t))
            ->when($request->type, fn($q, $t) => $q->where('type', $t));

        return response()->json(['success' => true, 'data' => $query->orderBy('created_at','desc')->paginate(30)]);
    }

    public function approveProduct($id)
    {
        $product = Product::findOrFail($id);
        $product->update(['is_active' => true]);
        return response()->json(['success' => true, 'message' => 'Produk diaktifkan.']);
    }

    public function deleteProduct($id)
    {
        Product::findOrFail($id)->update(['is_active' => false]);
        return response()->json(['success' => true, 'message' => 'Produk dinonaktifkan.']);
    }

    // ── F-11: Verifikasi Bank UMKM ──────────────────────────────────

    /**
     * GET /api/admin/bank-accounts — Daftar rekening bank UMKM
     */
    public function bankAccounts(Request $request)
    {
        $accounts = UmkmBankAccount::with(['umkm.user'])
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $accounts]);
    }

    /**
     * PATCH /api/admin/bank-accounts/{id}/approve — Setujui rekening bank
     */
    public function approveBankAccount($id)
    {
        $account = UmkmBankAccount::with('umkm')->findOrFail($id);

        if ($account->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Rekening sudah diproses sebelumnya.',
            ], 422);
        }

        $account->update([
            'status'         => 'approved',
            'verified_at'    => now(),
            'verified_by'    => auth()->id(),
            'rejection_reason' => null,
        ]);

        // Trigger n8n event: verifikasi bank
        if ($account->umkm) {
            $this->notifService->triggerEvent('bank.verified', [
                'umkm_id'        => $account->umkm_id,
                'umkm_name'      => $account->umkm->name,
                'bank_name'      => $account->bank_name,
                'account_number' => $account->account_number,
                'user_id'        => $account->umkm->user_id,
                'status'         => 'approved',
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Rekening bank berhasil diverifikasi.',
            'data'    => $account->fresh(),
        ]);
    }

    /**
     * PATCH /api/admin/bank-accounts/{id}/reject — Tolak rekening bank
     */
    public function rejectBankAccount(Request $request, $id)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:255',
        ]);

        $account = UmkmBankAccount::with('umkm')->findOrFail($id);

        if ($account->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Rekening sudah diproses sebelumnya.',
            ], 422);
        }

        $account->update([
            'status'           => 'rejected',
            'verified_at'      => now(),
            'verified_by'      => auth()->id(),
            'rejection_reason' => $request->rejection_reason,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Rekening bank ditolak.',
            'data'    => $account->fresh(),
        ]);
    }

    // ── Manajemen Penarikan Dana UMKM ───────────────────────────────

    /**
     * GET /api/admin/withdrawals — Daftar permintaan penarikan dana
     */
    public function withdrawals(Request $request)
    {
        $withdrawals = WalletHistory::with('wallet.user.umkm')
            ->where('reference_type', 'withdrawal')
            ->when($request->status, fn($q, $s) => $q->where('description', 'like', "%[{$s}]%"))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $withdrawals]);
    }

    /**
     * GET /api/admin/products — Daftar produk untuk moderasi
     */
    public function productList(Request $request)
    {
        $products = Product::with(['umkm.user', 'images'])
            ->when($request->is_active !== null, fn($q) => $q->where('is_active', $request->is_active === 'true'))
            ->when($request->search, fn($q, $s) => $q->where('name', 'like', "%{$s}%"))
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $products]);
    }
}