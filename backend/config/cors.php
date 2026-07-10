<?php

return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost',
        'http://127.0.0.1',
        'http://ekonomi_lokal.test',
        'http://ekonomi_lokal.1.test',
        'https://localhost',
        'https://127.0.0.1',
    ],
    'allowed_origins_patterns' => [
        '#^http://localhost(:\d+)?$#',
        '#^http://127\.0\.0\.1(:\d+)?$#',
        '#^http://0\.0\.0\.0(:\d+)?$#',
        '#^http://ekonomi_lokal(\.\d+)?\.test(:\d+)?$#',
        '#^https://localhost(:\d+)?$#',
        '#^https://127\.0\.0\.1(:\d+)?$#',
    ],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
