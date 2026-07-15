<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Umkm;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class AdminProductController extends Controller
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

        $products = Product::with('umkm')->orderBy('created_at', 'desc')->paginate(20);
        return view('admin.products.index', compact('products'));
    }

    public function create()
    {
        $umkms = Umkm::orderBy('name')->pluck('name', 'id');
        return view('admin.products.form', ['product' => new Product(), 'umkms' => $umkms, 'mode' => 'create']);
    }

    public function store(Request $request)
    {
        $this->validate($request, [
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
            'category' => 'nullable|string|max:120',
            'umkm_id' => 'nullable|exists:umkms,id',
            'description' => 'nullable|string',
        ]);

        $data = $request->only(['name','price','stock','category','umkm_id','description']);
        $data['slug'] = Str::slug($data['name']) . '-' . Str::random(6);
        $data['is_active'] = $request->boolean('is_active', true);

        Product::create($data);

        return redirect()->route('admin.products.index')->with('success', 'Produk berhasil dibuat.');
    }

    public function edit($id)
    {
        $product = Product::findOrFail($id);
        $umkms = Umkm::orderBy('name')->pluck('name', 'id');
        return view('admin.products.form', ['product' => $product, 'umkms' => $umkms, 'mode' => 'edit']);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $this->validate($request, [
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
            'category' => 'nullable|string|max:120',
            'umkm_id' => 'nullable|exists:umkms,id',
            'description' => 'nullable|string',
        ]);

        $data = $request->only(['name','price','stock','category','umkm_id','description']);
        $data['is_active'] = $request->boolean('is_active', true);

        $product->update($data);

        return redirect()->route('admin.products.index')->with('success', 'Produk berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
        return redirect()->route('admin.products.index')->with('success', 'Produk berhasil dihapus.');
    }
}

