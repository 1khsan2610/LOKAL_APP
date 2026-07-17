<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\Message;
use App\Models\Product;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ChatController extends Controller
{
    /**
     * Daftar chat milik user yang sedang login.
     * 
     * @group Chat
     */
    public function index(Request $request)
    {
        $user = $request->user();

        $chats = Chat::with([
            'sender' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
            'receiver' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
            'product' => fn($q) => $q->select('id', 'name', 'price', 'umkm_id'),
        ])
        ->involvingUser($user->id)
        ->orderBy('last_message_at', 'desc')
        ->paginate(20);

        // Transform: tambahkan other_user agar mudah di Flutter
        $chats->getCollection()->transform(function ($chat) use ($user) {
            $other = $chat->otherUser($user->id);
            $chat->other_user = [
                'id'     => $other->id,
                'name'   => $other->name,
                'avatar' => $other->avatar,
                'role'   => $other->role,
            ];
            return $chat;
        });

        return response()->json([
            'success' => true,
            'data'    => $chats->items(),
            'meta'    => [
                'current_page' => $chats->currentPage(),
                'last_page'    => $chats->lastPage(),
                'total'        => $chats->total(),
            ],
        ]);
    }

    /**
     * Ambil detail chat + seluruh pesan di dalamnya.
     * 
     * @group Chat
     */
    public function show(Request $request, Chat $chat)
    {
        $user = $request->user();

        // Middleware sudah memastikan akses, tapi kita double-check
        if ($chat->sender_id !== $user->id && $chat->receiver_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        // Ambil pesan, diurutkan dari terlama ke terbaru
        $messages = $chat->messages()
            ->with('sender:id,name,avatar,role')
            ->orderBy('created_at', 'asc')
            ->get();

        // Tandai semua pesan yang belum dibaca sebagai 'read'
        // (hanya jika user adalah receiver)
        if ($chat->receiver_id === $user->id) {
            $chat->messages()
                ->where('sender_id', '!=', $user->id)
                ->where('status', '!=', 'read')
                ->update(['status' => 'read']);

            // Reset unread_count
            $chat->update(['unread_count' => 0]);
        }

        $other = $chat->otherUser($user->id);

        return response()->json([
            'success' => true,
            'data'    => [
                'chat' => $chat->load([
                    'sender' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
                    'receiver' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
                    'product' => fn($q) => $q->select('id', 'name', 'price', 'umkm_id'),
                ]),
                'messages' => $messages,
                'other_user' => [
                    'id'     => $other->id,
                    'name'   => $other->name,
                    'avatar' => $other->avatar,
                    'role'   => $other->role,
                ],
            ],
        ]);
    }

    /**
     * Kirim pesan baru. Jika chat sudah ada, gunakan chat_id.
     * Jika belum ada, buat chat baru.
     * 
     * @group Chat
     */
    public function send(Request $request)
    {
        $request->validate([
            'receiver_id'  => 'required|exists:users,id',
            'message'      => 'required|string|max:5000',
            'product_id'   => 'nullable|exists:products,id',
            'chat_id'      => 'nullable|exists:chats,id',
        ]);

        $user = $request->user();
        $receiverId = $request->input('receiver_id');
        $productId = $request->input('product_id');
        $chatId = $request->input('chat_id');

        // Cari atau buat chat
        if ($chatId) {
            $chat = Chat::findOrFail($chatId);
            // Validasi akses
            if ($chat->sender_id !== $user->id && $chat->receiver_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akses ditolak.',
                ], 403);
            }
        } else {
            // Cari chat yang sudah ada antara kedua user (untuk product yang sama)
            $chat = Chat::where(function ($q) use ($user, $receiverId) {
                $q->where('sender_id', $user->id)
                  ->where('receiver_id', $receiverId);
            })->orWhere(function ($q) use ($user, $receiverId) {
                $q->where('sender_id', $receiverId)
                  ->where('receiver_id', $user->id);
            });

            // Jika ada product_id, filter juga berdasarkan product
            if ($productId) {
                $chat = $chat->where('product_id', $productId);
            }

            $chat = $chat->first();

            // Jika belum ada, buat baru
            if (!$chat) {
                $chat = Chat::create([
                    'sender_id'      => $user->id,
                    'receiver_id'    => $receiverId,
                    'product_id'     => $productId,
                    'last_message'   => $request->input('message'),
                    'last_message_at' => now(),
                    'unread_count'   => 1,
                ]);
            }
        }

        // Simpan pesan
        $message = Message::create([
            'chat_id'         => $chat->id,
            'sender_id'       => $user->id,
            'message_content' => $request->input('message'),
            'status'          => 'sent',
        ]);

        // Update last_message di chat
        $chat->update([
            'last_message'    => $request->input('message'),
            'last_message_at' => now(),
        ]);

        // Increment unread_count untuk receiver (jika pengirim bukan receiver)
        if ($chat->receiver_id === $receiverId) {
            $chat->increment('unread_count');
        }

        // Load relasi untuk response
        $message->load('sender:id,name,avatar,role');

        return response()->json([
            'success' => true,
            'message' => 'Pesan berhasil dikirim.',
            'data'    => [
                'message' => $message,
                'chat'    => $chat->load([
                    'sender' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
                    'receiver' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
                ]),
            ],
        ], 201);
    }

    /**
     * Tandai semua pesan dalam chat sebagai sudah dibaca.
     * 
     * @group Chat
     */
    public function markAsRead(Request $request, Chat $chat)
    {
        $user = $request->user();

        if ($chat->sender_id !== $user->id && $chat->receiver_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak.',
            ], 403);
        }

        // Update status pesan yang dikirim oleh lawan bicara
        $chat->messages()
            ->where('sender_id', '!=', $user->id)
            ->where('status', '!=', 'read')
            ->update(['status' => 'read']);

        // Reset unread_count
        $chat->update(['unread_count' => 0]);

        return response()->json([
            'success' => true,
            'message' => 'Semua pesan telah ditandai sudah dibaca.',
        ]);
    }

    /**
     * Hitung total unread messages untuk user yang login.
     * 
     * @group Chat
     */
    public function unreadCount(Request $request)
    {
        $user = $request->user();

        $totalUnread = Chat::where('receiver_id', $user->id)
            ->sum('unread_count');

        return response()->json([
            'success' => true,
            'data'    => [
                'total_unread' => (int) $totalUnread,
            ],
        ]);
    }

    /**
     * Cari atau buat chat dengan UMKM dari halaman produk.
     * 
     * @group Chat
     */
    public function startFromProduct(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
        ]);

        $user = $request->user();
        $product = Product::with('umkm.user')->findOrFail($request->input('product_id'));

        // Pastikan user adalah konsumen
        if (!$user->isKonsumen()) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya konsumen yang dapat memulai chat dari produk.',
            ], 403);
        }

        $umkmUser = $product->umkm->user;

        // Cari chat yang sudah ada
        $chat = Chat::where(function ($q) use ($user, $umkmUser) {
            $q->where('sender_id', $user->id)
              ->where('receiver_id', $umkmUser->id);
        })->orWhere(function ($q) use ($user, $umkmUser) {
            $q->where('sender_id', $umkmUser->id)
              ->where('receiver_id', $user->id);
        })->where('product_id', $product->id)->first();

        if (!$chat) {
            // Buat chat baru dengan pesan otomatis
            $chat = Chat::create([
                'sender_id'       => $user->id,
                'receiver_id'     => $umkmUser->id,
                'product_id'      => $product->id,
                'last_message'    => "Halo, saya tertarik dengan produk {$product->name}",
                'last_message_at' => now(),
                'unread_count'    => 1,
            ]);

            // Buat pesan otomatis
            Message::create([
                'chat_id'         => $chat->id,
                'sender_id'       => $user->id,
                'message_content' => "Halo, saya tertarik dengan produk {$product->name}",
                'status'          => 'sent',
            ]);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'chat' => $chat->load([
                    'sender' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
                    'receiver' => fn($q) => $q->select('id', 'name', 'avatar', 'role'),
                    'product' => fn($q) => $q->select('id', 'name', 'price', 'umkm_id'),
                ]),
            ],
        ]);
    }
}