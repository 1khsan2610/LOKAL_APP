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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->unique()->constrained('orders')->onDelete('cascade');
            $table->string('midtrans_transaction_id')->unique();
            $table->string('midtrans_order_id')->unique();
            $table->enum('payment_method', ['gopay', 'ovo', 'dana', 'va_bank', 'qris', 'lokal_coin'])->nullable();
            $table->string('va_number')->nullable(); // For virtual account
            $table->string('qr_string')->nullable(); // For QRIS
            $table->string('payment_url')->nullable(); // Midtrans payment URL
            $table->enum('status', ['pending', 'success', 'failed', 'expired', 'cancelled'])->default('pending');
            $table->decimal('amount', 12, 2);
            $table->json('midtrans_response')->nullable(); // Store full response from Midtrans
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('expired_at')->nullable();
            $table->timestamps();
            
            $table->index('order_id');
            $table->index('midtrans_transaction_id');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
