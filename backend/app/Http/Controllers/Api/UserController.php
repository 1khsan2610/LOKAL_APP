<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function profile() {
        return response()->json(['success' => true, 'data' => auth()->user()]);
    }

    public function update(Request $request) {
        $request->validate(['name' => 'required|string|max:255', 'phone' => 'nullable|string|max:20']);
        auth()->user()->update($request->only('name', 'phone'));
        return response()->json(['success' => true, 'message' => 'Profil berhasil diupdate.']);
    }

    public function uploadAvatar(Request $request) {
        $request->validate(['avatar' => 'required|image|max:2048']);
        $path = $request->file('avatar')->store('avatars', 'public');
        auth()->user()->update(['avatar' => $path]);
        return response()->json(['success' => true, 'data' => $path]);
    }

    public function changePassword(Request $request) {
        $request->validate([
            'current_password'      => 'required|string',
            'password'               => 'required|string|min:8|confirmed',
        ]);

        $user = auth()->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json(['success' => false, 'message' => 'Password saat ini salah.'], 422);
        }

        $user->update(['password' => Hash::make($request->password)]);

        return response()->json(['success' => true, 'message' => 'Password berhasil diubah.']);
    }
}