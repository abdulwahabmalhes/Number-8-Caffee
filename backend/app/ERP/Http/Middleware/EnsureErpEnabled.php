<?php

namespace App\ERP\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureErpEnabled
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! config('erp.enabled', false)) {
            return response()->json([
                'error' => [
                    'code' => 'erp_disabled',
                    'message' => 'The ERP service is currently disabled.',
                    'request_id' => $request->header('X-Request-ID'),
                    'fields' => (object) [],
                ],
            ], 404);
        }

        return $next($request);
    }
}
