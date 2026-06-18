<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'current_password' => 'required|string|min:6',
            'new_password' => 'required|string|min:8|regex:/^(?=.*[a-zA-Z])(?=.*\d).+$/',
            'new_password_confirmation' => 'required|same:new_password',
        ];
    }

    public function messages(): array
    {
        return [
            'current_password.required' => 'Password lama harus diisi.',
            'current_password.string' => 'Password lama harus berupa teks.',
            'current_password.min' => 'Password lama minimal 6 karakter.',
            'new_password.required' => 'Password baru harus diisi.',
            'new_password.string' => 'Password baru harus berupa teks.',
            'new_password.min' => 'Password baru minimal 8 karakter.',
            'new_password.regex' => 'Password baru harus mengandung huruf dan angka.',
            'new_password_confirmation.required' => 'Konfirmasi password baru harus diisi.',
            'new_password_confirmation.same' => 'Konfirmasi password baru tidak sesuai.',
        ];
    }
}
