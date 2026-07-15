<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\OrderTrack;
use App\Models\Payment;
use App\Models\WalletHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AdminOrderController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index(Request $request)
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        // Query orders with relations
        $orders = Order::with(['user', 'payment', 'items.product.umkm'])
            ->when($request->search, function ($q, $search) {
                $q->where(function ($q) use ($search) {
                    $q->where('order_number', 'like', "%{$search}%")
                      ->orWhereHas('user', fn($uq) => $uq->where('name', 'like', "%{$search}%"))
                      ->orWhereHas('user', fn($uq) => $uq->where('email', 'like', "%{$search}%"));
                });
            })
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->when($request->payment_status, function ($q, $ps) {
                $q->whereHas('payment', fn($pq) => $pq->where('status', $ps));
            })
            ->when($request->date_from, fn($q, $d) => $q->whereDate('created_at', '>=', $d))
            ->when($request->date_to, fn($q, $d) => $q->whereDate('created_at', '<=', $d))
            ->orderBy('created_at', 'desc')
            ->paginate(20)
            ->withQueryString();

        // Statistik
        $stats = [
            'total_orders'       => Order::count(),
            'pending'            => Order::where('status', 'pending')->count(),
            'awaiting_payment'   => Order::where('status', 'awaiting_payment')->count(),
            'processing'         => Order::where('status', 'processing')->count(),
            'shipped'            => Order::where('status', 'shipped')->count(),
            'delivered'          => Order::where('status', 'delivered')->count(),
            'cancelled'          => Order::where('status', 'cancelled')->count(),
            'total_revenue'      => Order::where('status', 'delivered')->sum('total'),
            'total_commission'   => WalletHistory::where('balance_type', 'commission')
                                    ->where('type', 'credit')->sum('amount'),
            'total_cashback_coin' => WalletHistory::where('balance_type', 'coin')
                                    ->where('type', 'credit')->sum('amount'),
        ];

        // Status filter options
        $statuses = ['pending', 'awaiting_payment', 'processing', 'shipped', 'delivered', 'cancelled'];

        return view('admin.orders.index', compact('orders', 'stats', 'statuses'));
    }

    /**
     * Detail order
     */
    public function show($id)
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        $order = Order::with(['user', 'address', 'payment', 'items.product.umkm', 'items.product.images'])
            ->findOrFail($id);

        // Ambil riwayat wallet histories terkait order ini
        $walletHistories = WalletHistory::where('reference_type', 'order')
            ->where('reference_id', $order->id)
            ->with('wallet.user')
            ->orderBy('created_at', 'desc')
            ->get();

        return view('admin.orders.show', compact('order', 'walletHistories'));
    }

    /**
     * Form Edit Order (hanya status & notes)
     */
    public function edit($id)
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        $order = Order::with(['user', 'payment', 'items.product'])->findOrFail($id);
        $statuses = ['pending', 'awaiting_payment', 'processing', 'shipped', 'delivered', 'cancelled'];

        return view('admin.orders.edit', compact('order', 'statuses'));
    }

    /**
     * Update Order
     */
    public function update(Request $request, $id)
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        $request->validate([
            'status'      => 'required|in:pending,awaiting_payment,processing,shipped,delivered,cancelled',
            'notes'       => 'nullable|string|max:500',
            'seller_notes' => 'nullable|string|max:500',
            'tracking_number' => 'nullable|string|max:100',
            'total'       => 'nullable|integer|min:0',
        ]);

        $order = Order::findOrFail($id);

        $updateData = [
            'status'          => $request->status,
            'notes'           => $request->notes,
            'seller_notes'    => $request->seller_notes,
            'tracking_number' => $request->tracking_number,
        ];

        // Jika status diubah ke delivered, set delivered_at
        if ($request->status === 'delivered' && !$order->delivered_at) {
            $updateData['delivered_at'] = now();
        }

        // Jika admin mengubah total
        if ($request->filled('total')) {
            $updateData['total'] = $request->total;
        }

        $order->update($updateData);

        return redirect()->route('admin.orders.show', $order->id)
            ->with('success', "Pesanan {$order->order_number} berhasil diperbarui.");
    }

    /**
     * Hapus Order (soft delete / force hapus item & payment terkait)
     */
    public function destroy($id)
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        $order = Order::findOrFail($id);

        DB::transaction(function () use ($order) {
            // Hapus terkait
            $order->items()->delete();
            $order->payment()->delete();
            OrderTrack::where('order_id', $order->id)->delete();
            WalletHistory::where('reference_type', 'order')
                ->where('reference_id', $order->id)
                ->delete();

            $order->delete();
        });

        return redirect()->route('admin.orders.index')
            ->with('success', "Pesanan {$order->order_number} berhasil dihapus.");
    }
}
