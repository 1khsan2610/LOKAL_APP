<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add SPATIAL index to coordinates column for geospatial queries optimization
     */
    public function up(): void
    {
        // Add SPATIAL index using raw SQL to support SPATIAL indexes
        DB::statement('ALTER TABLE umkm_profiles ADD SPATIAL INDEX spatial_coordinates (coordinates)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop SPATIAL index
        DB::statement('ALTER TABLE umkm_profiles DROP INDEX spatial_coordinates');
    }
};
