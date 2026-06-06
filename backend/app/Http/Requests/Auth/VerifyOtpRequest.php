<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class VerifyOtpRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'phone_number' => 'required|string|min:10|max:15',
            'code' => 'required|string|size:6',
            'name' => 'required|string|max:255',
            'role' => 'required|in:consumer,umkm,producer',
        ];
    }

    public function messages()
    {
        return [
            'phone_number.required' => 'Nomor telepon harus diisi',
            'code.required' => 'Kode OTP harus diisi',
            'code.size' => 'Kode OTP harus 6 digit',
            'name.required' => 'Nama harus diisi',
            'role.required' => 'Role harus diisi',
            'role.in' => 'Role harus consumer, umkm, atau producer',
        ];
    }
}