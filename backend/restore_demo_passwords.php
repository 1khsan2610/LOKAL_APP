<?php
require __DIR__ . '/vendor/autoload.php';
$app = require __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$emails = ['admin@ekonomilokal.id', 'busari@test.com', 'budi@test.com'];
foreach ($emails as $email) {
    $user = User::where('email', $email)->first();
    if ($user) {
        $user->password = Hash::make('password123');
        $user->save();
        echo $email . ' => restored' . PHP_EOL;
    } else {
        echo $email . ' => not found' . PHP_EOL;
    }
}
