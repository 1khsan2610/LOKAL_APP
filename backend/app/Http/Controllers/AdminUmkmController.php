<?php

namespace App\Http\Controllers;

use App\Models\Umkm;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class AdminUmkmController extends Controller
{
    public function __construct()
    {
        // ensure only authenticated admins can access
        $this->middleware('auth');
        $this->middleware(function ($request, $next) {
            if (!Auth::check() || Auth::user()->role !== 'admin') {
                abort(403);
            }
            return $next($request);
        });
    }

    public function index()
    {
        $umkms = Umkm::orderBy('created_at', 'desc')->paginate(20);
        return view('admin.umkm.index', compact('umkms'));
    }

    public function create()
    {
        return view('admin.umkm.form', ['umkm' => new Umkm(), 'mode' => 'create']);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|max:120',
            'city' => 'nullable|string|max:120',
            'province' => 'nullable|string|max:120',
            'description' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_verified' => 'nullable|boolean',
            'is_active' => 'nullable|boolean',
        ]);

        $data['slug'] = Str::slug($data['name']) . '-' . Str::random(6);
        $data['avg_rating'] = $data['avg_rating'] ?? 0;
        $data['is_verified'] = $request->boolean('is_verified');
        $data['is_active'] = $request->boolean('is_active', true);

        $umkm = Umkm::create($data + ['name' => $data['name']]);

        // Ensure wallet exists for owner-less umkm placeholder
        Wallet::updateOrCreate(['user_id' => $umkm->user_id ?? 0], ['coin_balance' => 0]);

        return redirect()->route('admin.umkm.index')->with('success', 'UMKM berhasil dibuat.');
    }

    public function edit($id)
    {
        $umkm = Umkm::findOrFail($id);
        return view('admin.umkm.form', ['umkm' => $umkm, 'mode' => 'edit']);
    }

    public function update(Request $request, $id)
    {
        $umkm = Umkm::findOrFail($id);
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|max:120',
            'city' => 'nullable|string|max:120',
            'province' => 'nullable|string|max:120',
            'description' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_verified' => 'nullable|boolean',
            'is_active' => 'nullable|boolean',
        ]);

        $data['is_verified'] = $request->boolean('is_verified');
        $data['is_active'] = $request->boolean('is_active', true);

        $umkm->update($data);

        return redirect()->route('admin.umkm.index')->with('success', 'UMKM berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $umkm = Umkm::findOrFail($id);
        $umkm->delete();
        return redirect()->route('admin.umkm.index')->with('success', 'UMKM berhasil dihapus.');
    }
}
