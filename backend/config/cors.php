<?php

return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost',
        'http://localhost:8000',
        'http://127.0.0.1',
        'http://127.0.0.1:8000',
        'http://ekonomi_lokal.test',
        'http://ekonomi_lokal.1.test',
        'http://ekonomi_lokal.1.test:8000',
        'https://localhost',
        'https://127.0.0.1',
        'http://10.0.2.2:8000', // Android emulator
        'http://10.0.3.2:8000', // Genymotion emulator
    ],
    'allowed_origins_patterns' => [
        '#^http://localhost(:\d+)?$#',
        '#^http://127\.0\.0\.1(:\d+)?$#',
        '#^http://0\.0\.0\.0(:\d+)?$#',
        '#^http://ekonomi_lokal(\.\d+)?\.test(:\d+)?$#',
        '#^https://localhost(:\d+)?$#',
        '#^https://127\.0\.0\.1(:\d+)?$#',
        '#^capacitor://localhost$#',   // Ionic/Capacitor
        '#^http://localhost(:\d+)?$#',  // Flutter web dev
    ],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
