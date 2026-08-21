@extends('layouts.admin')

@section('title', 'Form UMKM — LOKAL Admin')

@section('content')
<div class="p-6 max-w-2xl">
    <div class="flex items-center gap-4 mb-4">
        <a href="{{ route('admin.dashboard') }}" class="text-gray-400 hover:text-gray-600 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
        </a>
        <h2 class="text-xl font-bold">{{ $mode === 'edit' ? 'Edit' : 'Tambah' }} UMKM</h2>
    </div>

    @if($errors->any())
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded">{{ $errors->first() }}</div>
    @endif

    <form method="POST" action="{{ $mode === 'edit' ? route('admin.umkm.update', $umkm->id) : route('admin.umkm.store') }}">
        @csrf
        @if($mode === 'edit') @method('PUT') @endif

        <div class="mb-3">
            <label class="block text-sm font-medium mb-1">Nama</label>
            <input name="name" value="{{ old('name', $umkm->name) }}" class="w-full px-3 py-2 border rounded" />
        </div>

        <div class="grid grid-cols-2 gap-3">
            <div>
                <label class="block text-sm font-medium mb-1">Kota</label>
                <input name="city" value="{{ old('city', $umkm->city) }}" class="w-full px-3 py-2 border rounded" />
            </div>
            <div>
                <label class="block text-sm font-medium mb-1">Kategori</label>
                <input name="category" value="{{ old('category', $umkm->category) }}" class="w-full px-3 py-2 border rounded" />
            </div>
        </div>

        <div class="mb-3 mt-3">
            <label class="block text-sm font-medium mb-1">Deskripsi</label>
            <textarea name="description" class="w-full px-3 py-2 border rounded">{{ old('description', $umkm->description) }}</textarea>
        </div>

        <div class="flex items-center gap-4 mt-3">
            <label><input type="checkbox" name="is_verified" value="1" {{ old('is_verified', $umkm->is_verified) ? 'checked' : '' }}> Verified</label>
            <label><input type="checkbox" name="is_active" value="1" {{ old('is_active', $umkm->is_active ?? 1) ? 'checked' : '' }}> Active</label>
        </div>

        <div class="mt-4">
            <button class="px-4 py-2 bg-blue-600 text-white rounded">{{ $mode === 'edit' ? 'Simpan' : 'Buat' }}</button>
            <a href="{{ route('admin.umkm.index') }}" class="ml-3 text-gray-600">Batal</a>
        </div>
    </form>
</div>
@endsection
