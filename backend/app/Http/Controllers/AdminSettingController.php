<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminSettingController extends Controller
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
     * GET /admin/settings — Tampilkan daftar semua pengaturan.
     */
    public function index()
    {
        $settings = Setting::orderBy('group')->orderBy('key')->paginate(20);
        return view('admin.settings.index', compact('settings'));
    }

    /**
     * GET /admin/settings/create — Form tambah pengaturan baru.
     */
    public function create()
    {
        return view('admin.settings.form');
    }

    /**
     * POST /admin/settings — Simpan pengaturan baru.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'key'   => 'required|string|max:255|unique:settings,key',
            'value' => 'required|string|max:255',
            'group' => 'required|string|max:100',
            'label' => 'nullable|string|max:255',
        ]);

        Setting::create($validated);
        Setting::clearCache();

        $settingLabel = $validated['label'] ?: $validated['key'];
        return redirect()->route('admin.settings.index')
            ->with('success', "Pengaturan '{$settingLabel}' berhasil ditambahkan.");
    }

    /**
     * GET /admin/settings/{id}/edit — Form edit pengaturan.
     */
    public function edit($id)
    {
        $setting = Setting::findOrFail($id);
        return view('admin.settings.form', compact('setting'));
    }

    /**
     * PUT /admin/settings/{id} — Update pengaturan.
     */
    public function update(Request $request, $id)
    {
        $setting = Setting::findOrFail($id);

        $validated = $request->validate([
            'key'   => 'required|string|max:255|unique:settings,key,' . $id,
            'value' => 'required|string|max:255',
            'group' => 'required|string|max:100',
            'label' => 'nullable|string|max:255',
        ]);

        $setting->update($validated);
        Setting::clearCache();

        $settingLabel = $validated['label'] ?: $validated['key'];
        return redirect()->route('admin.settings.index')
            ->with('success', "Pengaturan '{$settingLabel}' berhasil diperbarui.");
    }

    /**
     * DELETE /admin/settings/{id} — Hapus pengaturan.
     */
    public function destroy($id)
    {
        $setting = Setting::findOrFail($id);
        $setting->delete();
        Setting::clearCache();

        $settingLabel = $setting->label ?: $setting->key;
        return redirect()->route('admin.settings.index')
            ->with('success', "Pengaturan '{$settingLabel}' berhasil dihapus.");
    }
}