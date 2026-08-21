<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class AiChatController extends Controller
{
    /**
     * POST /api/ai/chat
     * Chat dengan LOKAL AI Assistant via Gemini API
     * Rate limit: 20 requests/menit per token (F-10)
     * maxOutputTokens: 2048 agar jawaban panjang tidak terpotong
     */
    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:5000',
        ]);

        // ── Rate Limit: 20 req/menit per user ────────────────────
        $user = auth()->user();
        $rateLimitKey = "ai_chat_rate_limit_{$user->id}";
        $rateLimitMax = 20;
        $rateLimitTTL = 60;

        $currentCount = (int) Cache::get($rateLimitKey, 0);
        if ($currentCount >= $rateLimitMax) {
            return response()->json([
                'success' => false,
                'message' => 'Batas penggunaan AI Assistant tercapai. Silakan coba lagi dalam 1 menit.',
            ], 429);
        }

        Cache::put($rateLimitKey, $currentCount + 1, $rateLimitTTL);

        try {
            $apiKey  = config('services.gemini.api_key');

            if (empty($apiKey)) {
                Log::warning('AI Chat: GEMINI_API_KEY tidak dikonfigurasi');
                return response()->json([
                    'success' => false,
                    'message' => 'Fitur AI belum dikonfigurasi. Hubungi administrator.',
                ], 503);
            }

            $systemPrompt = "Kamu adalah LOKAL AI Assistant, asisten virtual ramah dari platform EkonomiLokal. " .
                "Tugasmu membantu konsumen menemukan produk UMKM lokal Indonesia, memberikan rekomendasi produk lokal, " .
                "serta memberi solusi bisnis sederhana untuk pelaku UMKM. " .
                "Gunakan Bahasa Indonesia kasual yang santun dan mudah dipahami. " .
                "Jawab dengan hangat, informatif, dan tetap fokus pada topik UMKM dan produk lokal Indonesia. " .
                "Jika ditanya di luar topik tersebut, arahkan kembali ke topik UMKM. " .
                "Berikan jawaban yang lengkap dan tidak terputus.";

            $userMessage = $request->message;
            $allErrors   = [];
            $reply       = null;
            $isQuota     = false;

            // ── Generation Config: 2048 tokens, 30s timeout ──────
            $generationConfig = [
                'temperature'     => 0.7,
                'maxOutputTokens' => 2048,
                'topP'           => 0.95,
                'topK'           => 40,
            ];

            // ── Prioritas endpoint Gemini ────────────────────────
            $endpoints = [
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={$apiKey}",
                "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key={$apiKey}",
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key={$apiKey}",
            ];

            foreach ($endpoints as $idx => $restUrl) {
                try {
                    $response = Http::timeout(30)->post($restUrl, [
                        'contents' => [
                            ['role' => 'user', 'parts' => [['text' => "{$systemPrompt}\n\nPertanyaan: {$userMessage}"]],
                        ],
                        'generationConfig' => $generationConfig,
                    ]);

                    if ($response->successful()) {
                        $data  = $response->json();
                        $reply = $data['candidates'][0]['content']['parts'][0]['text'] ?? null;
                        if ($reply) break;
                    } else {
                        $code = $response->status();
                        if ($code === 429) $isQuota = true;
                        $allErrors[] = "Endpoint-{$idx}: HTTP {$code}";
                    }
                } catch (\Throwable $e) {
                    $allErrors[] = "Endpoint-{$idx}: " . $e->getMessage();
                }
            }

            // ── Fallback: OpenAI-compatible ──────────────────────
            if (!$reply) {
                $openaiUrl = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions?key={$apiKey}";
                try {
                    $response = Http::timeout(30)->post($openaiUrl, [
                        'model'       => 'gemini-1.5-flash',
                        'messages'    => [
                            ['role' => 'system', 'content' => $systemPrompt],
                            ['role' => 'user',   'content' => $userMessage],
                        ],
                        'temperature' => 0.7,
                        'max_tokens'  => 2048,
                    ]);

                    if ($response->successful()) {
                        $data  = $response->json();
                        $reply = $data['choices'][0]['message']['content'] ?? null;
                    } else {
                        $code = $response->status();
                        if ($code === 429) $isQuota = true;
                        $allErrors[] = "OpenAI-format: HTTP {$code}";
                    }
                } catch (\Throwable $e) {
                    $allErrors[] = "OpenAI-format: " . $e->getMessage();
                }
            }

            // ── Jika semua gagal ─────────────────────────────────
            if (!$reply) {
                Log::error('AI Chat: Semua model gagal', [
                    'errors'  => $allErrors,
                    'message' => $request->message,
                ]);

                if ($isQuota) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Kuota AI Assistant sedang habis. Silakan ganti API key baru di .env atau coba lagi nanti.',
                    ], 429);
                }

                return response()->json([
                    'success' => false,
                    'message' => 'Asisten AI sedang sibuk, coba lagi nanti.',
                ], 500);
            }

            return response()->json([
                'success'  => true,
                'response' => $reply,
            ]);

        } catch (\Throwable $e) {
            Log::error('AI Chat: Exception', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Asisten AI sedang sibuk, coba lagi nanti.',
            ], 500);
        }
    }
}