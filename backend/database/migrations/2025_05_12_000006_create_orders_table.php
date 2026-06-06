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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('consumer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('umkm_id')->constrained('umkm_profiles')->onDelete('cascade');
            $table->decimal('subtotal', 12, 2);
            $table->decimal('lokal_coin_discount', 12, 2)->default(0);
            $table->decimal('lokal_coin_amount', 12, 2)->default(0); // Jumlah coin yang digunakan
            $table->decimal('total_amount', 12, 2);
            $table->enum('status', ['pending', 'confirmed', 'processing', 'completed', 'cancelled', 'refunded'])->default('pending');
            $table->text('delivery_address')->nullable();
            $table->point('delivery_location')->nullable();
            $table->text('notes')->nullable();
            $table->timestamp('confirmed_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index('consumer_id');
            $table->index('umkm_id');
            $table->index('status');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
