<?php

namespace App\ERP\Application\Contracts;

interface IdempotencyStore
{
    public function reserve(string $scope, string $key, string $requestHash): bool;

    public function complete(string $scope, string $key, string $responseReference): void;
}
