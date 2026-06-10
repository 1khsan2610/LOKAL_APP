<?php

return [

    /*
    |--------------------------------------------------------------------------
    | JWT Secret
    |--------------------------------------------------------------------------
    |
    | Don't forget to set this in your .env file, as it will be used to sign
    | your tokens. A helper command is provided for this:
    | `php artisan jwt:secret`
    |
    */

    'secret' => env('JWT_SECRET'),

    /*
    |--------------------------------------------------------------------------
    | JWT Public Key / Private Key
    |--------------------------------------------------------------------------
    |
    | The algorithm to use when signing tokens.
    | RS256 (RSA Signature with SHA-256)
    |
    */

    'algorithm' => env('JWT_ALGORITHM', 'HS256'),

    'public_key' => env('JWT_PUBLIC_KEY'),

    'private_key' => env('JWT_PRIVATE_KEY'),

    /*
    |--------------------------------------------------------------------------
    | JWT Time to live
    |--------------------------------------------------------------------------
    |
    | Specify the length of time (in minutes) that the token will be valid for.
    | Defaults to 1 hour.
    |
    */

    'ttl' => (int)env('JWT_TTL', 60),

    /*
    |--------------------------------------------------------------------------
    | Refresh time to live
    |--------------------------------------------------------------------------
    |
    | Specify the length of time (in minutes) that the token can be refreshed
    | within. I.E. The user can refresh their token within this time frame.
    | Defaults to 2 weeks.
    |
    */

    'refresh_ttl' => (int)env('JWT_REFRESH_TTL', 20160),

    /*
    |--------------------------------------------------------------------------
    | JWT hashing algorithm
    |--------------------------------------------------------------------------
    |
    | Specify the hashing algorithm that will be used to hash the token.
    |
    */

    'hash_algorithm' => env('JWT_HASH_ALGORITHM', 'sha256'),

];
