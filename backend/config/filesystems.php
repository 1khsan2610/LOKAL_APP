<?php

return [
    'default' => env('FILESYSTEM_DISK', 'local'),
    'disks'   => [
        'local'  => ['driver' => 'local', 'root' => storage_path('app'), 'throw' => false],
        'public' => ['driver' => 'local', 'root' => storage_path('app/public'), 'url' => env('APP_URL').'/storage', 'visibility' => 'public', 'throw' => false],
        's3'     => [
            'driver'   => 's3',
            'key'      => env('MINIO_KEY', 'minioadmin'),
            'secret'   => env('MINIO_SECRET', 'minioadmin'),
            'region'   => env('MINIO_REGION', 'us-east-1'),
            'bucket'   => env('MINIO_BUCKET', 'ekonomi-lokal'),
            'url'      => env('MINIO_ENDPOINT', 'http://minio:9000'),
            'endpoint' => env('MINIO_ENDPOINT', 'http://minio:9000'),
            'use_path_style_endpoint' => true,
            'visibility' => 'public',
            'throw'    => false,
        ],
    ],
    'links' => [
        public_path('storage') => storage_path('app/public'),
    ],
];
