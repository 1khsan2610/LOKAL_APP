@extends('layouts.admin')

@section('title', 'Kelola Produk — LOKAL Admin')

@section('content')
<div class="p-6">
    <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-4">
            <a href="{{ route('admin.dashboard') }}" class="text-gray-400 hover:text-gray-600 transition">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
            </a>
            <h2 class="text-xl font-bold">Kelola Produk</h2>
        </div>
        <a href="{{ route('admin.products.create') }}" class="px-4 py-2 bg-blue-600 text-white rounded-lg">Tambah Produk</a>
    </div>

    @if(session('success'))
    <div class="mb-4 p-3 bg-emerald-50 border border-emerald-200 rounded">{{ session('success') }}</div>
    @endif

    <div class="bg-white rounded-xl shadow-sm border p-4">
        <table class="w-full text-left">
            <thead>
                <tr class="text-sm text-gray-600">
                    <th>Nama</th>
                    <th>UMKM</th>
                    <th>Harga</th>
                    <th>Stok</th>
                    <th>Status</th>
                    <th class="text-right">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @foreach($products as $p)
                <tr class="border-t">
                    <td class="py-3">{{ $p->name }}</td>
                    <td>{{ $p->umkm?->name ?? '-' }}</td>
                    <td>Rp {{ number_format($p->price,0,',','.') }}</td>
                    <td>{{ $p->stock }}</td>
                    <td>{{ $p->is_active ? 'Aktif' : 'Nonaktif' }}</td>
                    <td class="text-right">
                        <a href="{{ route('admin.products.edit', $p->id) }}" class="text-blue-600 mr-3">Edit</a>
                        <form method="POST" action="{{ route('admin.products.destroy', $p->id) }}" style="display:inline">@csrf @method('DELETE')
                            <button type="submit" class="text-red-600" onclick="return confirm('Hapus produk ini?')">Hapus</button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>

        <div class="mt-4">{{ $products->links() }}</div>
    </div>
</div>
@endsection
