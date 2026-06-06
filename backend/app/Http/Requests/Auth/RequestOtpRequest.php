<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RequestOtpRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'phone_number' => 'required|string|min:10|max:15',
        ];
    }

    public function messages()
    {
        return [
            'phone_number.required' => 'Nomor telepon harus diisi',
            'phone_number.string' => 'Nomor telepon harus berupa teks',
            'phone_number.min' => 'Nomor telepon minimal 10 digit',
            'phone_number.max' => 'Nomor telepon maksimal 15 digit',
        ];
    }
}