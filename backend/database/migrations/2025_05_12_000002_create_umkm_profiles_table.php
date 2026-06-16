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
            // Kategori usaha sesuai desain
            $table->string('business_category')->nullable();
            // Alamat UMKM (disarankan dienkripsi di level aplikasi)
            $table->text('address')->nullable();
            $table->string('nib')->unique(); // Nomor Induk Berusaha
            $table->string('siup')->nullable(); // Surat Izin Usaha Perdagangan
            $table->string('nib_document_url');
            $table->string('siup_document_url')->nullable();
            // Path gabungan untuk nib/siup bila diperlukan
            $table->string('nib_siup_path')->nullable();
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
            // Status verifikasi UMKM sesuai desain: pending/verified/rejected
            $table->enum('verification_status', ['pending', 'verified', 'rejected'])->default('pending');
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
