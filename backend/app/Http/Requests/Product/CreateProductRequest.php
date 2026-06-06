<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class CreateProductRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return $this->user()->isUmkm();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category' => 'required|string|max:100',
            'price' => 'required|numeric|min:1000',
            'cost_price' => 'nullable|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'weight' => 'nullable|integer|min:0',
            'attributes' => 'nullable|json',
            'images' => 'nullable|array|max:5',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Nama produk harus diisi.',
            'category.required' => 'Kategori produk harus diisi.',
            'price.required' => 'Harga produk harus diisi.',
            'price.min' => 'Harga minimum Rp 1.000.',
            'stock.required' => 'Stok produk harus diisi.',
            'images.max' => 'Maksimal 5 foto per produk.',
            'images.*.max' => 'Ukuran foto maksimal 2 MB.',
        ];
    }
}
