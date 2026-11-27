<?php

namespace App\ERP\Application\Exceptions;

use RuntimeException;

class IdempotencyConflictException extends RuntimeException
{
    public function __construct(string $message = 'Idempotency key has already been used with different request parameters.')
    {
        parent::__construct($message);
    }
}
