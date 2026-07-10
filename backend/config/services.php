<?php

return [
    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],
    'ses' => [
        'key'    => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],
    'resend' => [
        'key' => env('RESEND_KEY'),
    ],
    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel'              => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    // ── Midtrans ──────────────────────────────────────────────────
    'midtrans' => [
        'server_key'    => env('MIDTRANS_SERVER_KEY', ''),
        'client_key'    => env('MIDTRANS_CLIENT_KEY', ''),
        'is_production' => env('MIDTRANS_IS_PRODUCTION', false),
    ],

    // ── Google Gemini AI ──────────────────────────────────────────
    'gemini' => [
        'api_key'  => env('GEMINI_API_KEY', ''),
        'base_url' => env('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'),
    ],

    // ── Firebase Cloud Messaging ──────────────────────────────────
    'fcm' => [
        'server_key' => env('FCM_SERVER_KEY', ''),
    ],

    // ── MinIO / S3 ────────────────────────────────────────────────
    'minio' => [
        'endpoint' => env('MINIO_ENDPOINT', 'http://minio:9000'),
        'key'      => env('MINIO_KEY',      'minioadmin'),
        'secret'   => env('MINIO_SECRET',   'minioadmin'),
        'region'   => env('MINIO_REGION',   'us-east-1'),
        'bucket'   => env('MINIO_BUCKET',   'ekonomi-lokal'),
    ],
];
