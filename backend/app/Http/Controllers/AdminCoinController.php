<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;

class AdminCoinController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        if (!Auth::check() || Auth::user()->role !== 'admin') {
            return redirect()->route('login');
        }

        return view('admin.coins.index');
    }
}
