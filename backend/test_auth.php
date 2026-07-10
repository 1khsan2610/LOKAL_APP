<?php
require __DIR__.'/vendor/autoload.php';
$app = require __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Tymon\JWTAuth\Facades\JWTAuth;
use App\Models\User;

$credentials = ['email' => 'busari@test.com', 'password' => 'password123'];
$token = JWTAuth::attempt($credentials);

echo 'TOKEN=' . ($token ? $token : 'NULL') . PHP_EOL;
if ($token) {
    $user = auth()->user();
    echo 'USER=' . ($user ? $user->email : 'NULL') . PHP_EOL;
} else {
    $user = User::where('email', 'busari@test.com')->first();
    echo 'USER_EXISTS=' . ($user ? 'YES' : 'NO') . PHP_EOL;
    echo 'HASH_CHECK=' . (Illuminate\Support\Facades\Hash::check('password123', $user->password) ? 'YES' : 'NO') . PHP_EOL;
}
