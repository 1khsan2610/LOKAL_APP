<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\{User, Umkm, Order, Product, CoinTransaction};
use Illuminate\Http\Request;

// ─── AdminController ────────────────────────────────────────────────
class AdminController extends Controller
{
    public function dashboard()
    {
        return response()->json(['success' => true, 'data' => [
            'total_users'       => User::count(),
            'total_umkm'        => Umkm::count(),
            'total_orders'      => Order::count(),
            'total_products'    => Product::where('is_active', true)->count(),
            'revenue_this_month'=> Order::where('status', 'delivered')->whereMonth('created_at', now()->month)->sum('total'),
            'active_users'      => User::where('is_active', true)->count(),
            'unverified_umkm'   => Umkm::where('is_verified', false)->count(),
            'pending_orders'    => Order::where('status', 'pending')->count(),
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

    public function orders(Request $request)
    {
        $orders = Order::with(['user', 'items.product'])
            ->when($request->status, fn($q, $s) => $q->where('status', $s))
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $orders]);
    }

    public function transactions()
    {
        $txns = CoinTransaction::with('user')->orderBy('created_at','desc')->paginate(30);
        return response()->json(['success' => true, 'data' => $txns]);
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
}
