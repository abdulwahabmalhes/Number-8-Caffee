<?php

namespace App\ERP\Application\Contracts;

interface AuditLogger
{
    /** @param array<string, mixed> $context */
    public function record(string $actorId, string $action, string $aggregateId, array $context = []): void;
}
