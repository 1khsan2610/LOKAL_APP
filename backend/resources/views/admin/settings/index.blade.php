@extends('layouts.admin')

@section('title', 'Pengaturan — LOKAL Admin')

@section('content')
<div class="flex items-center justify-between mb-8">
    <div>
        <h1 class="text-2xl lg:text-3xl font-extrabold text-gray-900">⚙️ Pengaturan Global</h1>
        <p class="text-gray-500 mt-1">Kelola semua parameter konfigurasi platform.</p>
    </div>
    <a href="{{ route('admin.settings.create') }}"
        class="px-4 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl transition text-sm flex items-center gap-2">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
        Tambah Pengaturan
    </a>
</div>

@if (session('success'))
<div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-xl">
    <p class="text-sm font-medium text-emerald-700">{{ session('success') }}</p>
</div>
@endif

@if ($errors->any())
<div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
    <ul class="list-disc list-inside text-sm text-red-700">
        @foreach ($errors->all() as $error)
            <li>{{ $error }}</li>
        @endforeach
    </ul>
</div>
@endif

<div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-sm">
            <thead>
                <tr class="bg-gray-50 border-b border-gray-100">
                    <th class="text-left px-5 py-3.5 font-semibold text-gray-600">Key</th>
                    <th class="text-left px-5 py-3.5 font-semibold text-gray-600">Label</th>
                    <th class="text-left px-5 py-3.5 font-semibold text-gray-600">Value</th>
                    <th class="text-left px-5 py-3.5 font-semibold text-gray-600">Group</th>
                    <th class="text-center px-5 py-3.5 font-semibold text-gray-600">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-50">
                @forelse ($settings as $setting)
                <tr class="hover:bg-gray-50/50">
                    <td class="px-5 py-3.5 font-mono text-xs text-gray-700">{{ $setting->key }}</td>
                    <td class="px-5 py-3.5 font-medium text-gray-900">{{ $setting->label ?? '-' }}</td>
                    <td class="px-5 py-3.5">
                        <span class="px-2.5 py-1 bg-blue-50 text-blue-700 font-semibold rounded-lg">{{ $setting->value }}</span>
                    </td>
                    <td class="px-5 py-3.5">
                        <span class="px-2 py-0.5 bg-gray-100 text-gray-600 text-xs rounded-full">{{ $setting->group }}</span>
                    </td>
                    <td class="px-5 py-3.5">
                        <div class="flex items-center justify-center gap-2">
                            <a href="{{ route('admin.settings.edit', $setting->id) }}"
                                class="px-3 py-1.5 bg-amber-50 hover:bg-amber-100 text-amber-700 text-xs font-medium rounded-lg transition">
                                Edit
                            </a>
                            <form method="POST" action="{{ route('admin.settings.destroy', $setting->id) }}"
                                onsubmit="return confirm('Hapus pengaturan {{ $setting->label ?: $setting->key }}?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit"
                                    class="px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-700 text-xs font-medium rounded-lg transition">
                                    Hapus
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" class="px-5 py-12 text-center text-gray-400">
                        Belum ada pengaturan. Klik "Tambah Pengaturan" untuk memulai.
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

<div class="mt-4">
    {{ $settings->links() }}
</div>

<p class="mt-8 text-center text-xs text-gray-400">
    &copy; {{ date('Y') }} LOKAL App — Panel Admin v2.0
</p>
@endsection