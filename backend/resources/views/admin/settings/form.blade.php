@extends('layouts.admin')

@section('title', 'Form Pengaturan — LOKAL Admin')

@section('content')
<div class="max-w-2xl mx-auto">
    <div class="flex items-center gap-4 mb-6">
        <a href="{{ route('admin.settings.index') }}" class="text-gray-400 hover:text-gray-600 transition">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/></svg>
        </a>
        <h1 class="text-2xl font-bold text-gray-900">{{ $mode === 'edit' ? 'Edit' : 'Tambah' }} Pengaturan</h1>
    </div>

    @if($errors->any())
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded">{{ $errors->first() }}</div>
    @endif

    <form method="POST" action="{{ $mode === 'edit' ? route('admin.settings.update', $setting->id) : route('admin.settings.store') }}">
        @csrf
        @if($mode === 'edit') @method('PUT') @endif

        <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Key</label>
            <input name="key" value="{{ old('key', $setting->key) }}" class="w-full px-3 py-2 border rounded" required />
        </div>
        <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Label</label>
            <input name="label" value="{{ old('label', $setting->label) }}" class="w-full px-3 py-2 border rounded" />
        </div>
        <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Value</label>
            <input name="value" value="{{ old('value', $setting->value) }}" class="w-full px-3 py-2 border rounded" required />
        </div>
        <div class="mb-4">
            <label class="block text-sm font-medium mb-1">Group</label>
            <input name="group" value="{{ old('group', $setting->group) }}" class="w-full px-3 py-2 border rounded" />
        </div>

        <div class="mt-6">
            <button class="px-4 py-2 bg-blue-600 text-white rounded">{{ $mode === 'edit' ? 'Simpan' : 'Buat' }}</button>
            <a href="{{ route('admin.settings.index') }}" class="ml-3 text-gray-600">Batal</a>
        </div>
    </form>
</div>
@endsection