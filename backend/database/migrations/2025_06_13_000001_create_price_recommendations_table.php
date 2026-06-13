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
        Schema::create('price_recommendations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->onDelete('cascade');
            $table->foreignId('umkm_id')->constrained('umkm_profiles')->onDelete('cascade');
            
            // Request & Response Data
            $table->json('ml_request_data')->nullable(); // Full request data sent to ML
            $table->json('ml_response_data')->nullable(); // Full response from ML
            
            // Analysis Results
            $table->decimal('current_price', 12, 2);
            $table->decimal('recommended_price', 12, 2)->nullable();
            $table->decimal('confidence_score', 5, 4)->default(0); // 0.0000 to 1.0000
            $table->text('recommendation_reason')->nullable();
            
            // Market Analysis
            $table->json('market_analysis')->nullable(); // avg price, demand, competitors data
            $table->json('competitive_products')->nullable(); // List of similar products & prices
            
            // Status & Tracking
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->string('external_request_id')->nullable(); // For async tracking with ML service
            $table->text('error_message')->nullable();
            $table->timestamp('processed_at')->nullable();
            
            // Audit
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index('product_id');
            $table->index('umkm_id');
            $table->index('status');
            $table->index('created_at');
            $table->index(['product_id', 'status']); // For status check queries
            $table->index(['created_at', 'status']); // For recent recommendations
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('price_recommendations');
    }
};
