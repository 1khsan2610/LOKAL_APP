<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index()
    {
        $items = Cart::with(['product.images', 'product.umkm', 'variant'])
            ->where('user_id', auth()->id())
            ->get();
        return response()->json(['success' => true, 'data' => $items]);
    }

    public function addItem(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity'   => 'required|integer|min:1',
            'variant_id' => 'nullable|exists:product_variants,id',
        ]);

        $product = Product::findOrFail($request->product_id);
        if ($product->stock < $request->quantity) {
            return response()->json(['success' => false, 'message' => 'Stok tidak mencukupi.'], 422);
        }

        $cartItem = Cart::updateOrCreate(
            ['user_id' => auth()->id(), 'product_id' => $request->product_id, 'variant_id' => $request->variant_id],
            ['quantity' => \DB::raw("quantity + {$request->quantity}")]
        );

        return response()->json(['success' => true, 'message' => 'Produk ditambahkan ke keranjang.', 'data' => $cartItem->load('product.images')]);
    }

    public function updateItem(Request $request, $itemId)
    {
        $request->validate(['quantity' => 'required|integer|min:1']);
        $item = Cart::where('user_id', auth()->id())->findOrFail($itemId);
        $item->update(['quantity' => $request->quantity]);
        return response()->json(['success' => true, 'data' => $item]);
    }

    public function removeItem($itemId)
    {
        Cart::where('user_id', auth()->id())->findOrFail($itemId)->delete();
        return response()->json(['success' => true, 'message' => 'Item dihapus dari keranjang.']);
    }

    public function clear()
    {
        Cart::where('user_id', auth()->id())->delete();
        return response()->json(['success' => true, 'message' => 'Keranjang dikosongkan.']);
    }
}
