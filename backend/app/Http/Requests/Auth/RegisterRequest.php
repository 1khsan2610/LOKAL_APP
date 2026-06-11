<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|min:3|max:100',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|regex:/^(?=.*[a-zA-Z])(?=.*\d).+$/',
            'password_confirmation' => 'required|same:password',
            'phone_number' => 'required|string|min:10|max:15',
            'role' => 'required|in:consumer,umkm',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Nama harus diisi.',
            'name.string' => 'Nama harus berupa teks.',
            'name.min' => 'Nama minimal 3 karakter.',
            'name.max' => 'Nama maksimal 100 karakter.',
            
            'email.required' => 'Email harus diisi.',
            'email.email' => 'Email tidak valid.',
            'email.unique' => 'Email sudah terdaftar.',
            
            'password.required' => 'Password harus diisi.',
            'password.string' => 'Password harus berupa teks.',
            'password.min' => 'Password minimal 8 karakter.',
            'password.regex' => 'Password harus mengandung huruf dan angka.',
            
            'password_confirmation.required' => 'Konfirmasi password harus diisi.',
            'password_confirmation.same' => 'Konfirmasi password tidak sesuai dengan password.',
            
            'phone_number.required' => 'Nomor telepon harus diisi.',
            'phone_number.string' => 'Nomor telepon harus berupa teks.',
            'phone_number.min' => 'Nomor telepon minimal 10 digit.',
            'phone_number.max' => 'Nomor telepon maksimal 15 digit.',
            
            'role.required' => 'Role harus diisi.',
            'role.in' => 'Role harus consumer atau umkm.',
        ];
    }
}
