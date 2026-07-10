<?php

namespace Tests\Feature;

use Tests\TestCase;

class CorsConfigTest extends TestCase
{
    public function test_flutter_web_localhost_origins_are_allowed(): void
    {
        $patterns = config('cors.allowed_origins_patterns');

        $this->assertContains('^http://localhost(:\\d+)?$', $patterns);
        $this->assertContains('^http://127\\.0\\.0\\.1(:\\d+)?$', $patterns);
    }
}
