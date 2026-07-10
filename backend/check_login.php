<?php
require __DIR__.'/vendor/autoload.php';
$app = require __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$user = User::where('email', 'busari@test.com')->first();
if (!$user) {
    echo "USER_NOT_FOUND\n";
    exit;
}

echo "USER_FOUND\n";
echo "PASSWORD_HASH=" . $user->password . "\n";
echo "CHECK=" . (Hash::check('password123', $user->password) ? 'true' : 'false') . "\n";
echo "ROLE=" . $user->role . "\n";
echo "ACTIVE=" . ($user->is_active ? 'true' : 'false') . "\n";
