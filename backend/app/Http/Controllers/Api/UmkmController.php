<?php
// ═══════════════════════════════════════════════════════════════════
//  UmkmController.php
// ═══════════════════════════════════════════════════════════════════
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Umkm;
use Illuminate\Http\Request;

class UmkmController extends Controller
{
    public function index(Request $request)
    {
        $umkms = Umkm::with('user')
            ->where('is_active', true)
            ->when($request->category, fn($q, $c) => $q->where('category', $c))
            ->when($request->search,   fn($q, $s) => $q->where('name', 'like', "%$s%"))
            ->paginate(20);
        return response()->json(['success' => true, 'data' => $umkms]);
    }

    public function nearby(Request $request)
    {
        $request->validate(['lat' => 'required|numeric', 'lng' => 'required|numeric']);
        $lat    = $request->lat;
        $lng    = $request->lng;
        $radius = $request->radius ?? 5; // km

        $umkms = Umkm::with('user')
            ->where('is_active', true)
            ->whereNotNull('latitude')
            ->selectRaw("*, ( 6371 * acos( cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)) ) ) AS distance", [$lat, $lng, $lat])
            ->having('distance', '<=', $radius)
            ->orderBy('distance')
            ->limit(20)
            ->get();

        return response()->json(['success' => true, 'data' => $umkms]);
    }

    public function show($id)
    {
        $umkm = Umkm::with(['user', 'products' => fn($q) => $q->where('is_active', true)->limit(10)])->findOrFail($id);
        return response()->json(['success' => true, 'data' => $umkm]);
    }

    public function products($id)
    {
        $umkm     = Umkm::findOrFail($id);
        $products = $umkm->products()->with('images')->where('is_active', true)->paginate(20);
        return response()->json(['success' => true, 'data' => $products]);
    }

    public function myStore()
    {
        $umkm = Umkm::with('user')->where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar. Silakan hubungi administrator.',
            ], 403);
        }
        return response()->json(['success' => true, 'data' => $umkm]);
    }

    public function updateStore(Request $request)
    {
        $request->validate([
            'name'        => 'sometimes|string|max:100',
            'description' => 'sometimes|string',
            'phone'       => 'sometimes|string|max:20',
            'address'     => 'sometimes|string',
            'city'        => 'sometimes|string|max:50',
            'province'    => 'sometimes|string|max:50',
            'latitude'    => 'sometimes|numeric',
            'longitude'   => 'sometimes|numeric',
        ]);

        $umkm = Umkm::where('user_id', auth('api')->id())->first();
        if (!$umkm) {
            return response()->json([
                'success' => false,
                'message' => 'Toko UMKM Anda belum terdaftar. Silakan hubungi administrator.',
            ], 403);
        }

        $umkm->update($request->only(['name','description','phone','address','city','province','latitude','longitude']));

        return response()->json(['success' => true, 'message' => 'Toko berhasil diperbarui.', 'data' => $umkm]);
    }
}
