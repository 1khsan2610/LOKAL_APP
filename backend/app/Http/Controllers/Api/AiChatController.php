<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\RateLimiter;

class AiChatController extends Controller
{
    /**
     * POST /api/ai/chat
     * Gemini AI Chat untuk EkonomiLokal
     */
    public function chat(Request $request)
    {
        $request->validate([
            'message'  => 'required|string|max:1000',
            'history'  => 'nullable|array|max:20',
        ]);

        $userId = auth()->id();

        // Rate limiting: 30 requests per minute per user
        $key = "ai_chat:{$userId}";
        if (RateLimiter::tooManyAttempts($key, 30)) {
            $seconds = RateLimiter::availableIn($key);
            return response()->json([
                'success' => false,
                'message' => "Terlalu banyak request. Coba lagi dalam {$seconds} detik.",
            ], 429);
        }
        RateLimiter::hit($key, 60);

        $apiKey  = config('services.gemini.api_key');
        $baseUrl = config('services.gemini.base_url');

        // Build conversation history
        $contents = [];

        // System context
        $systemPrompt = "Kamu adalah AI assistant untuk EkonomiLokal, sebuah platform e-commerce yang memfokuskan produk dari UMKM (Usaha Mikro Kecil Menengah) lokal Indonesia. " .
            "Tugasmu membantu pengguna mencari produk, info harga, rekomendasi UMKM, dan info tentang Lokal Coin (sistem reward kami). " .
            "Selalu jawab dalam Bahasa Indonesia yang ramah dan informatif. " .
            "Jangan menjawab pertanyaan di luar konteks belanja dan UMKM lokal. " .
            "Jika ada pertanyaan teknis atau keluhan, arahkan ke tim support kami.";

        // Add chat history
        if ($request->history) {
            foreach ($request->history as $msg) {
                $contents[] = [
                    'role'  => $msg['role'] === 'user' ? 'user' : 'model',
                    'parts' => [['text' => $msg['content']]],
                ];
            }
        }

        // Add current message
        $contents[] = [
            'role'  => 'user',
            'parts' => [['text' => $request->message]],
        ];

        $response = Http::timeout(30)->post(
            "{$baseUrl}/models/gemini-1.5-flash:generateContent?key={$apiKey}",
            [
                'system_instruction' => [
                    'parts' => [['text' => $systemPrompt]],
                ],
                'contents'           => $contents,
                'generationConfig'   => [
                    'temperature'     => 0.7,
                    'topK'            => 40,
                    'topP'            => 0.95,
                    'maxOutputTokens' => 512,
                ],
                'safetySettings' => [
                    ['category' => 'HARM_CATEGORY_HARASSMENT', 'threshold' => 'BLOCK_MEDIUM_AND_ABOVE'],
                    ['category' => 'HARM_CATEGORY_HATE_SPEECH', 'threshold' => 'BLOCK_MEDIUM_AND_ABOVE'],
                ],
            ]
        );

        if (!$response->successful()) {
            return response()->json([
                'success' => false,
                'message' => 'AI sedang tidak tersedia. Coba lagi nanti.',
            ], 503);
        }

        $data  = $response->json();
        $reply = $data['candidates'][0]['content']['parts'][0]['text'] ?? 'Maaf, aku tidak bisa menjawab saat ini.';

        return response()->json([
            'success' => true,
            'data'    => [
                'reply'         => $reply,
                'finish_reason' => $data['candidates'][0]['finishReason'] ?? 'STOP',
            ],
        ]);
    }
}
