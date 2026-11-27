<?php

namespace App\ERP\Application\Contracts;

interface DeliveryPlatformAdapter
{
    public function platform(): string;

    /** @param array<string, mixed> $payload */
    public function verifyWebhook(string $signature, string $rawBody, array $payload): bool;

    /** @param array<string, mixed> $payload */
    public function normalizeOrder(array $payload): array;

    public function acknowledge(string $externalOrderId): void;

    public function updateStatus(string $externalOrderId, string $status): void;
}
