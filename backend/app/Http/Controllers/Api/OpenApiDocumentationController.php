<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

/**
 * OpenAPI 3.0 Documentation Controller
 * Generates OpenAPI specification from Laravel routes
 * Accessible at: GET /api/docs (SRS Bab 5.4)
 */
class OpenApiDocumentationController extends Controller
{
    /**
     * Get OpenAPI JSON specification
     */
    public function specification()
    {
        $openapi = [
            'openapi' => '3.0.0',
            'info' => [
                'title' => 'LOKAL - Platform e-commerce Lokal',
                'description' => 'API untuk platform LOKAL yang menghubungkan UMKM lokal dengan pelanggan',
                'version' => '1.0.0',
                'contact' => [
                    'name' => 'LOKAL Team',
                    'email' => 'support@lokal.app',
                    'url' => 'https://lokal.app'
                ],
                'license' => [
                    'name' => 'Apache 2.0',
                    'url' => 'https://www.apache.org/licenses/LICENSE-2.0.html'
                ]
            ],
            'servers' => [
                [
                    'url' => env('APP_URL', 'https://localhost'),
                    'description' => 'Production Server',
                    'variables' => [
                        'basePath' => [
                            'default' => '/api/v1'
                        ]
                    ]
                ],
                [
                    'url' => 'http://localhost:8000',
                    'description' => 'Development Server',
                    'variables' => [
                        'basePath' => [
                            'default' => '/api/v1'
                        ]
                    ]
                ]
            ],
            'paths' => $this->generatePaths(),
            'components' => $this->generateComponents(),
            'security' => [
                ['bearerAuth' => []],
                ['apiKey' => []]
            ],
            'tags' => $this->generateTags(),
        ];

        return response()->json($openapi);
    }

    /**
     * Get HTML documentation page
     */
    public function documentation()
    {
        return view('api.documentation');
    }

    /**
     * Generate API paths from routes
     */
    private function generatePaths(): array
    {
        $paths = [];
        $routes = collect(app('router')->getRoutes()->getRoutes())
            ->filter(function ($route) {
                return strpos($route->uri, 'api/v') === 0;
            });

        foreach ($routes as $route) {
            $uri = $this->formatUri($route->uri);
            $method = strtolower($route->methods[0] ?? 'get');

            if (!isset($paths[$uri])) {
                $paths[$uri] = [];
            }

            $paths[$uri][$method] = $this->generateOperation($route);
        }

        return $paths;
    }

    /**
     * Generate operation details for OpenAPI
     */
    private function generateOperation($route): array
    {
        $operation = [
            'summary' => $this->extractSummary($route),
            'description' => $this->extractDescription($route),
            'tags' => [$this->extractTag($route)],
            'parameters' => $this->generateParameters($route),
            'responses' => $this->generateResponses(),
        ];

        $method = strtolower($route->methods[0] ?? 'get');
        if (in_array($method, ['post', 'put', 'patch'])) {
            $operation['requestBody'] = $this->generateRequestBody();
        }

        return $operation;
    }

    /**
     * Format URI for OpenAPI spec
     */
    private function formatUri(string $uri): string
    {
        return '/' . preg_replace('/\{(.+?)\}/', '{$1}', $uri);
    }

    /**
     * Extract route summary from controller comment
     */
    private function extractSummary($route): string
    {
        return 'API Endpoint';
    }

    /**
     * Extract route description
     */
    private function extractDescription($route): string
    {
        return '';
    }

    /**
     * Extract tag from route prefix
     */
    private function extractTag($route): string
    {
        $uri = $route->uri;
        if (preg_match('/api\/v[0-9]\/([a-z]+)/', $uri, $matches)) {
            return ucfirst($matches[1]);
        }
        return 'General';
    }

    /**
     * Generate parameters for OpenAPI
     */
    private function generateParameters($route): array
    {
        $parameters = [];

        // Add path parameters
        if (preg_match_all('/\{([^}]+)\}/', $route->uri, $matches)) {
            foreach ($matches[1] as $param) {
                $parameters[] = [
                    'name' => $param,
                    'in' => 'path',
                    'required' => true,
                    'schema' => ['type' => 'string']
                ];
            }
        }

        // Add authentication header
        $parameters[] = [
            'name' => 'Authorization',
            'in' => 'header',
            'required' => false,
            'schema' => ['type' => 'string'],
            'example' => 'Bearer <token>'
        ];

        return $parameters;
    }

    /**
     * Generate request body schema
     */
    private function generateRequestBody(): array
    {
        return [
            'required' => true,
            'content' => [
                'application/json' => [
                    'schema' => [
                        'type' => 'object',
                        'properties' => [
                            'example' => ['type' => 'string']
                        ]
                    ]
                ]
            ]
        ];
    }

    /**
     * Generate response schemas
     */
    private function generateResponses(): array
    {
        return [
            '200' => [
                'description' => 'Successful response',
                'content' => [
                    'application/json' => [
                        'schema' => [
                            'type' => 'object',
                            'properties' => [
                                'status' => ['type' => 'string'],
                                'data' => ['type' => 'object'],
                                'message' => ['type' => 'string']
                            ]
                        ]
                    ]
                ]
            ],
            '401' => [
                'description' => 'Unauthorized'
            ],
            '429' => [
                'description' => 'Rate limit exceeded'
            ],
            '500' => [
                'description' => 'Server error'
            ]
        ];
    }

    /**
     * Generate component schemas
     */
    private function generateComponents(): array
    {
        return [
            'securitySchemes' => [
                'bearerAuth' => [
                    'type' => 'http',
                    'scheme' => 'bearer',
                    'bearerFormat' => 'JWT'
                ],
                'apiKey' => [
                    'type' => 'apiKey',
                    'in' => 'header',
                    'name' => 'X-API-Token'
                ]
            ],
            'schemas' => [
                'User' => [
                    'type' => 'object',
                    'properties' => [
                        'id' => ['type' => 'integer'],
                        'name' => ['type' => 'string'],
                        'email' => ['type' => 'string', 'format' => 'email'],
                        'phone' => ['type' => 'string'],
                        'created_at' => ['type' => 'string', 'format' => 'date-time']
                    ]
                ],
                'Product' => [
                    'type' => 'object',
                    'properties' => [
                        'id' => ['type' => 'integer'],
                        'name' => ['type' => 'string'],
                        'price' => ['type' => 'number', 'format' => 'double'],
                        'description' => ['type' => 'string'],
                    ]
                ],
                'ApiResponse' => [
                    'type' => 'object',
                    'properties' => [
                        'status' => ['type' => 'string', 'enum' => ['success', 'error']],
                        'code' => ['type' => 'integer'],
                        'message' => ['type' => 'string'],
                        'data' => ['type' => 'object']
                    ]
                ]
            ]
        ];
    }

    /**
     * Generate tags for grouping operations
     */
    private function generateTags(): array
    {
        return [
            ['name' => 'Auth', 'description' => 'Authentication endpoints'],
            ['name' => 'User', 'description' => 'User management'],
            ['name' => 'Product', 'description' => 'Product catalog'],
            ['name' => 'Order', 'description' => 'Order management'],
            ['name' => 'Payment', 'description' => 'Payment processing'],
            ['name' => 'Wallet', 'description' => 'Wallet & balance management'],
            ['name' => 'Review', 'description' => 'Product reviews & ratings'],
        ];
    }
}
