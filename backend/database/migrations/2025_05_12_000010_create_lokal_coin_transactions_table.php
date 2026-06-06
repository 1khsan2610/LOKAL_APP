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
        Schema::create('lokal_coin_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->enum('type', ['earn', 'spend', 'expire'])->default('earn');
            $table->enum('source', ['transaction_reward', 'review_reward', 'initial', 'discount', 'admin_adjustment', 'expired'])->default('transaction_reward');
            $table->decimal('amount', 10, 2);
            $table->foreignId('order_id')->nullable()->constrained('orders')->onDelete('set null');
            $table->timestamp('expires_at')->nullable();
            $table->text('description')->nullable();
            $table->timestamps();
            
            $table->index('user_id');
            $table->index('type');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('lokal_coin_transactions');
    }
};
