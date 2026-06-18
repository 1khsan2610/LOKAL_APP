<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()?->id;

        return [
            'name' => 'sometimes|required|string|max:255',
            'phone_number' => ['sometimes', 'required', 'string', 'max:20', 'unique:users,phone_number,' . $userId],
            'address' => 'sometimes|nullable|string|max:1000',
            'city' => 'sometimes|nullable|string|max:255',
            'profile_image_url' => 'sometimes|nullable|string|max:255',
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Nama harus diisi.',
            'name.string' => 'Nama harus berupa teks.',
            'name.max' => 'Nama maksimal 255 karakter.',
            'phone_number.required' => 'Nomor HP harus diisi.',
            'phone_number.string' => 'Nomor HP harus berupa teks.',
            'phone_number.max' => 'Nomor HP maksimal 20 karakter.',
            'phone_number.unique' => 'Nomor HP sudah terdaftar.',
            'address.string' => 'Alamat harus berupa teks.',
            'address.max' => 'Alamat maksimal 1000 karakter.',
            'city.string' => 'Kota harus berupa teks.',
            'city.max' => 'Kota maksimal 255 karakter.',
            'profile_image_url.string' => 'URL foto harus berupa teks.',
            'profile_image_url.max' => 'URL foto maksimal 255 karakter.',
        ];
    }
}
