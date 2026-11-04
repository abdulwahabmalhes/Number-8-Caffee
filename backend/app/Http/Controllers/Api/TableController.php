<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Table;
use Illuminate\Support\Str;

class TableController extends Controller
{
    public function scanQr(Request $request)
    {
        $request->validate([
            'qr_token' => 'nullable|string',
            'table_number' => 'nullable|string',
        ]);

        if ($request->has('qr_token') && !empty($request->qr_token)) {
            $table = Table::with('branch')->where('qr_token', $request->qr_token)->first();
        } else if ($request->has('table_number') && !empty($request->table_number)) {
            $inputNum = trim($request->table_number);
            $padded = is_numeric($inputNum) ? str_pad($inputNum, 2, '0', STR_PAD_LEFT) : $inputNum;
            $table = Table::with('branch')
                ->where('table_number', $inputNum)
                ->orWhere('table_number', $padded)
                ->first();
        } else {
            return response()->json(['success' => false, 'message' => 'Please provide qr_token or table_number'], 400);
        }

        if (!$table) {
            return response()->json(['success' => false, 'message' => 'Table not found'], 404);
        }

        if (!$table->is_active) {
            return response()->json(['success' => false, 'message' => 'This table is currently inactive'], 400);
        }

        if (!$table->branch->is_active) {
            return response()->json(['success' => false, 'message' => 'Branch is currently closed'], 400);
        }

        return response()->json([
            'success' => true,
            'session_id' => Str::uuid()->toString(),
            'branch_id' => $table->branch_id,
            'table_id' => $table->id,
            'table_number' => $table->table_number,
            'branch_name' => $table->branch->name_en,
        ]);
    }
}
