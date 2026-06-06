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
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->onDelete('cascade');
            $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
            $table->foreignId('consumer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('umkm_id')->constrained('umkm_profiles')->onDelete('cascade');
            $table->unsignedTinyInteger('rating')->between(1, 5);
            $table->text('comment')->nullable();
            $table->boolean('is_verified_purchase')->default(true);
            $table->timestamps();
            $table->softDeletes();
            
            $table->index('product_id');
            $table->index('consumer_id');
            $table->index('umkm_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
