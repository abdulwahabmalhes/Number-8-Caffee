<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminOnlyMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user && ($user->hasRole('Cashier') || $user->hasRole('Barista'))) {
            abort(403, 'عذراً، غير مصرح للكاشير أو الباريستا بالدخول إلى لوحة الإدارة.');
        }

        return $next($request);
    }
}
