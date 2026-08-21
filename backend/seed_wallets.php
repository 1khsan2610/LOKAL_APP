<?php
/**
 * Script satu kali untuk membuat wallet admin & user yang belum punya wallet.
 * Jalankan: php seed_wallets.php
 */
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;

echo "Memeriksa dan membuat wallet yang hilang...\n";

// 1. Admin wallet
$adminUser = User::where('role', 'admin')->first();
if ($adminUser) {
    $wallet = Wallet::where('user_id', $adminUser->id)->first();
    if (!$wallet) {
        Wallet::create([
            'user_id'           => $adminUser->id,
            'coin_balance'      => 0,
            'cash_balance'      => 0,
            'commission_balance' => 0,
        ]);
        echo "✅ Admin wallet created for {$adminUser->name}\n";
    } else {
        echo "✅ Admin wallet already exists: commission_balance={$wallet->commission_balance}\n";
    }
} else {
    echo "⚠️  Admin user not found. Create admin user first.\n";
}

// 2. Users without wallets
$usersWithoutWallet = User::whereDoesntHave('wallet')->get();
$count = 0;
foreach ($usersWithoutWallet as $user) {
    Wallet::create([
        'user_id'           => $user->id,
        'coin_balance'      => 0,
        'cash_balance'      => 0,
        'commission_balance' => 0,
    ]);
    $count++;
}
echo "✅ Created {$count} missing wallets\n";

echo "\nSelesai! Semua wallet sudah tersedia.\n";