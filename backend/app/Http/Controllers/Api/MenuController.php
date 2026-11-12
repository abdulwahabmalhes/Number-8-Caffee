<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;

class MenuController extends Controller
{
    public function index()
    {
        $categories = Category::with(['products' => function($q) {
            $q->where('is_available', true)
              ->with(['optionGroups.options' => function($oq) {
                  $oq->where('is_available', true);
              }])
              ->orderBy('sort_order');
        }])->where('is_active', true)->orderBy('sort_order')->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }
}
