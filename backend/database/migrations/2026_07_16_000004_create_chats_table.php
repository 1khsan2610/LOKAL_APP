<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // ── Tabel Chats (percakapan antara 2 user) ──────────────────
        Schema::create('chats', function (Blueprint $table) {
            $table->id();
            // Pengirim & penerima chat
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('receiver_id')->constrained('users')->cascadeOnDelete();
            // Opsional: jika chat berasal dari halaman produk tertentu
            $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
            // Pesan terakhir untuk preview di daftar chat
            $table->text('last_message')->nullable();
            // Waktu pesan terakhir (untuk sorting)
            $table->timestamp('last_message_at')->nullable();
            // Counter unread untuk receiver
            $table->integer('unread_count')->default(0);
            $table->timestamps();

            // Unique constraint agar tidak ada duplikat percakapan
            $table->unique(['sender_id', 'receiver_id', 'product_id'], 'chat_unique');
        });

        // ── Tabel Messages (isi pesan) ──────────────────────────────
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('chat_id')->constrained()->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->text('message_content');
            // Status pesan: sent, delivered, read
            $table->enum('status', ['sent', 'delivered', 'read'])->default('sent');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('messages');
        Schema::dropIfExists('chats');
    }
};