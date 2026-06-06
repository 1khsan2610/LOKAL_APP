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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('umkm_id')->constrained('umkm_profiles')->onDelete('cascade');
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('category');
            $table->decimal('price', 12, 2);
            $table->decimal('cost_price', 12, 2)->nullable(); // Harga pokok untuk analytics
            $table->integer('stock')->default(0);
            $table->integer('weight')->nullable(); // Dalam gram
            $table->json('attributes')->nullable(); // Atribut variabel produk
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->integer('total_reviews')->default(0);
            $table->integer('total_sold')->default(0);
            $table->boolean('is_active')->default(true);
            $table->point('coordinates')->nullable(); // POINT type for geospatial queries
            $table->timestamp('last_restocked_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index('umkm_id');
            $table->index('category');
            $table->index('is_active');
            $table->fullText(['name', 'description']); // Full text search
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
