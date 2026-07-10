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
        Schema::create('order_tracks', function (Blueprint $table) {
            $table->id();
            // Menghubungkan tracking dengan ID Pesanan (Order)
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            
            // Kolom untuk status singkat (contoh: 'Paket sedang disiapkan', 'Kurir sedang menuju lokasi')
            $table->string('status'); 
            
            // Kolom opsional untuk detail informasi lokasi atau keterangan tambahan
            $table->string('description')->nullable(); 
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_tracks');
    }
};