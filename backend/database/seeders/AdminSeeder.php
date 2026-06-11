<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\LokalCoinBalance;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create default admin user
        $adminUser = User::firstOrCreate(
            ['email' => 'admin@lokal.id'],
            [
                'name' => 'Admin LOKAL',
                'email' => 'admin@lokal.id',
                'password' => Hash::make('Admin@123', [
                    'rounds' => 12,
                ]),
                'phone_number' => '081234567890',
                'role' => 'admin',
                'is_verified' => true,
                'verified_at' => now(),
            ]
        );

        // Create admin with default credentials (change after first login)
        $superAdmin = User::firstOrCreate(
            ['email' => 'superadmin@lokal.id'],
            [
                'name' => 'Super Admin LOKAL',
                'email' => 'superadmin@lokal.id',
                'password' => Hash::make('SuperAdmin@123', [
                    'rounds' => 12,
                ]),
                'phone_number' => '089876543210',
                'role' => 'admin',
                'is_verified' => true,
                'verified_at' => now(),
            ]
        );

        // Ensure admin users have Lokal Coin balance
        if (!$adminUser->lokalCoinBalance) {
            LokalCoinBalance::create([
                'user_id' => $adminUser->id,
                'balance' => 0,
                'currency' => 'IDR',
            ]);
        }

        if (!$superAdmin->lokalCoinBalance) {
            LokalCoinBalance::create([
                'user_id' => $superAdmin->id,
                'balance' => 0,
                'currency' => 'IDR',
            ]);
        }

        // Log created accounts
        $this->command->info('Admin accounts created successfully!');
        $this->command->line('');
        $this->command->line('Admin Credentials:');
        $this->command->line('─────────────────────────────────────────');
        $this->command->line('Email: admin@lokal.id');
        $this->command->line('Password: Admin@123');
        $this->command->line('');
        $this->command->line('Super Admin Credentials:');
        $this->command->line('─────────────────────────────────────────');
        $this->command->line('Email: superadmin@lokal.id');
        $this->command->line('Password: SuperAdmin@123');
        $this->command->line('');
        $this->command->warn('⚠️  IMPORTANT: Change these passwords immediately after first login!');
    }
}
