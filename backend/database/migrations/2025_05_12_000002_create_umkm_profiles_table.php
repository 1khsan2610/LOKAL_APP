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
        Schema::create('umkm_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->onDelete('cascade');
            $table->string('business_name');
            $table->text('business_description')->nullable();
            $table->string('nib')->unique(); // Nomor Induk Berusaha
            $table->string('siup')->nullable(); // Surat Izin Usaha Perdagangan
            $table->string('nib_document_url');
            $table->string('siup_document_url')->nullable();
            $table->string('owner_name');
            $table->string('owner_phone_number');
            $table->string('bank_name')->nullable();
            $table->string('bank_account_number')->nullable();
            $table->string('bank_account_holder_name')->nullable();
            $table->decimal('rating', 3, 2)->default(5.00); // Rating dari ulasan
            $table->integer('total_reviews')->default(0);
            $table->integer('total_products')->default(0);
            $table->integer('total_orders')->default(0);
            $table->point('coordinates')->nullable(); // POINT type for geospatial queries (latitude, longitude)
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            $table->index('nib');
            $table->index('user_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('umkm_profiles');
    }
};
