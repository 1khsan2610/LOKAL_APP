<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AiChatController extends Controller
{
    /**
     * POST /api/ai/chat
     * Chat dengan LOKAL AI Assistant via Gemini API
     *
     * Mendukung 2 format endpoint:
     * 1. Langsung: https://generativelanguage.googleapis.com/v1/models/...:generateContent
     * 2. OpenAI-compatible: https://generativelanguage.googleapis.com/v1beta/openai/chat/completions
     */
    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        try {
            $apiKey  = config('services.gemini.api_key');
            $baseUrl = config('services.gemini.base_url', 'https://generativelanguage.googleapis.com/v1');

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
                "Jika ditanya di luar topik tersebut, arahkan kembali ke topik UMKM.";

            $userMessage = $request->message;
            $allErrors   = [];
            $reply       = null;
            $isQuota     = false;

            // ── Coba Gemini REST format dulu ───────────────────────
            // Urutan prioritas endpoint yang sudah terbukti bekerja.
            $endpoints = [
                // Prioritas 1: gemini-flash-latest via v1beta (terbukti 200 dengan key baru)
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key={$apiKey}",
                // Prioritas 2: gemini-2.0-flash via v1
                "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key={$apiKey}",
                // Prioritas 3: gemini-1.5-flash via v1beta
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={$apiKey}",
            ];

            foreach ($endpoints as $idx => $restUrl) {
                try {
                    $response = Http::timeout(30)->post($restUrl, [
                        'contents' => [
                            ['role' => 'user', 'parts' => [['text' => "{$systemPrompt}\n\nUser: {$userMessage}"]]],
                        ],
                        'generationConfig' => [
                            'temperature'    => 0.7,
                            'maxOutputTokens' => 512,
                        ],
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

            // ── Fallback: OpenAI-compatible ────────────────────────
            // https://generativelanguage.googleapis.com/v1beta/openai/chat/completions?key=API_KEY
            if (!$reply) {
                $openaiUrl = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions?key={$apiKey}";
                try {
                    $response = Http::timeout(30)->post($openaiUrl, [
                        'model'       => 'gemini-2.0-flash',
                        'messages'    => [
                            ['role' => 'system', 'content' => $systemPrompt],
                            ['role' => 'user',   'content' => $userMessage],
                        ],
                        'temperature' => 0.7,
                        'max_tokens'  => 512,
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

            // ── Jika semua gagal ──────────────────────────────────
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