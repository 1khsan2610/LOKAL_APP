<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware ChatAccess
 * 
 * Memastikan hanya user yang terlibat dalam percakapan (pengirim/penerima)
 * yang bisa mengakses data chat. Juga memastikan konsumen hanya bisa
 * mengirim pesan ke UMKM (pemilik produk), bukan ke sesama konsumen.
 */
class ChatAccessMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        
        // Jika request mengandung parameter 'chat' (route binding)
        $chat = $request->route('chat');
        
        if ($chat) {
            // Pastikan user adalah sender ATAU receiver dari chat ini
            if ($chat->sender_id !== $user->id && $chat->receiver_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki akses ke percakapan ini.',
                ], 403);
            }
        }
        
        // Jika request mengandung parameter 'message' (route binding)
        $message = $request->route('message');
        if ($message) {
            $chat = $message->chat;
            if ($chat->sender_id !== $user->id && $chat->receiver_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki akses ke pesan ini.',
                ], 403);
            }
        }

        // Untuk request POST /send (membuat chat baru / mengirim pesan)
        if ($request->is('api/chat/send*')) {
            $receiverId = $request->input('receiver_id');
            
            // Validasi: receiver harus ada
            $receiver = \App\Models\User::find($receiverId);
            if (!$receiver) {
                return response()->json([
                    'success' => false,
                    'message' => 'Penerima tidak ditemukan.',
                ], 404);
            }
            
            // Konsumen hanya boleh chat ke UMKM
            if ($user->isKonsumen() && !$receiver->isUmkm()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Konsumen hanya dapat mengirim pesan ke UMKM.',
                ], 403);
            }
            
            // UMKM boleh chat ke konsumen (balasan)
            if ($user->isUmkm() && !$receiver->isKonsumen()) {
                return response()->json([
                    'success' => false,
                    'message' => 'UMKM hanya dapat membalas pesan dari konsumen.',
                ], 403);
            }
        }

        return $next($request);
    }
}