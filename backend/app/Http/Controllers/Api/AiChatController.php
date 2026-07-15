<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AiChatController extends Controller
{
    /**
     * POST /api/ai/chat
     * Chat dengan LOKAL AI Assistant via Gemini API
     */
    public function chat(Request $request)
    {
        // Validasi input
        $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        try {
            $apiKey = env('GEMINI_API_KEY');
            $endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={$apiKey}";

            // System instruction untuk LOKAL AI Assistant
            $systemInstruction = "Kamu adalah LOKAL AI Assistant, asisten virtual ramah dari platform EkonomiLokal. " .
                "Tugasmu membantu konsumen menemukan produk UMKM lokal Indonesia, memberikan rekomendasi produk lokal, " .
                "serta memberi solusi bisnis sederhana untuk pelaku UMKM. " .
                "Gunakan Bahasa Indonesia kasual yang santun dan mudah dipahami. " .
                "Jawablah dengan hangat, informatif, dan tetap fokus pada topik UMKM serta produk lokal Indonesia.";

            // Susun payload sesuai dokumentasi Gemini API
            $payload = [
                'system_instruction' => [
                    'parts' => [
                        ['text' => $systemInstruction],
                    ],
                ],
                'contents' => [
                    [
                        'parts' => [
                            ['text' => $request->message],
                        ],
                    ],
                ],
                'generationConfig' => [
                    'temperature' => 0.7,
                    'maxOutputTokens' => 512,
                ],
            ];

            // Kirim request ke Gemini API
            $response = Http::timeout(30)->post($endpoint, $payload);

            // Jika gagal
            if (!$response->successful()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Asisten AI sedang sibuk, coba lagi nanti.',
                ], 500);
            }

            // Parse response
            $data = $response->json();
            $reply = $data['candidates'][0]['content']['parts'][0]['text'] ?? 'Maaf, saya belum bisa menjawab pertanyaan Anda saat ini.';

            return response()->json([
                'success' => true,
                'response' => $reply,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Asisten AI sedang sibuk, coba lagi nanti.',
            ], 500);
        }
    }
}