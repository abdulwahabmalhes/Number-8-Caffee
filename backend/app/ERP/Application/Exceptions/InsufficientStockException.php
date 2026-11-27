<?php

namespace App\ERP\Application\Exceptions;

use RuntimeException;

class InsufficientStockException extends RuntimeException
{
    public function __construct(string $message = "Insufficient inventory stock for requested recipe.")
    {
        parent::__construct($message, 422);
    }
}
