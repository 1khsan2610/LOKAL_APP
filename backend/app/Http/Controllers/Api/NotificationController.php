<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index() {
        $notifications = Notification::where('user_id', auth()->id())->latest()->get();
        return response()->json(['success' => true, 'data' => $notifications]);
    }

    public function markRead($id) {
        Notification::where('id', $id)->where('user_id', auth()->id())->update(['is_read' => true]);
        return response()->json(['success' => true]);
    }

    public function markAllRead() {
        Notification::where('user_id', auth()->id())->update(['is_read' => true]);
        return response()->json(['success' => true]);
    }
    
    public function registerDevice(Request $request) {
        $request->validate(['token' => 'required']);
        auth()->user()->deviceTokens()->updateOrCreate(['token' => $request->token]);
        return response()->json(['success' => true]);
    }

    /**
     * POST /api/admin/notifications/broadcast
     * Admin mengirim notifikasi ke semua pengguna atau berdasarkan role
     */
    public function broadcast(Request $request) {
        $request->validate([
            'title' => 'required|string|max:150',
            'body'  => 'required|string|max:500',
            'role'  => 'nullable|in:konsumen,umkm,admin',
        ]);

        $query = \App\Models\User::query();
        if ($request->role) {
            $query->where('role', $request->role);
        }

        $userIds = $query->pluck('id');
        $now = now();

        $rows = $userIds->map(fn($id) => [
            'user_id'    => $id,
            'title'      => $request->title,
            'body'       => $request->body,
            'type'       => 'broadcast',
            'data'       => json_encode([]),
            'is_read'    => false,
            'created_at' => $now,
            'updated_at' => $now,
        ])->toArray();

        foreach (array_chunk($rows, 500) as $chunk) {
            Notification::insert($chunk);
        }

        return response()->json([
            'success' => true,
            'message' => "Notifikasi berhasil dikirim ke {$userIds->count()} pengguna.",
        ]);
    }
}