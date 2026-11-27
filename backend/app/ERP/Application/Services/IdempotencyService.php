<?php

namespace App\ERP\Application\Services;

use App\ERP\Application\Exceptions\IdempotencyConflictException;
use App\ERP\Infrastructure\Persistence\Models\ErpIdempotencyRecord;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Closure;
use Illuminate\Support\Facades\DB;

class IdempotencyService
{
    /**
     * Executes a business action wrapped with atomic idempotency tracking.
     * Returns an array with ['code' => int, 'body' => mixed, 'is_replay' => bool].
     *
     * @throws IdempotencyConflictException
     */
    public function execute(
        int $tenantId,
        int $branchId,
        string $actionType,
        string $idempotencyKey,
        array $requestPayload,
        Closure $callback,
        ?int $userId = null
    ): array {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        $requestHash = $this->calculateHash($requestPayload);

        // 1. Check existing record
        $existing = ErpIdempotencyRecord::query()
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->where('action_type', $actionType)
            ->where('idempotency_key', $idempotencyKey)
            ->first();

        if ($existing) {
            if ($existing->request_hash !== $requestHash) {
                throw new IdempotencyConflictException(
                    "Idempotency key '{$idempotencyKey}' has already been used for '{$actionType}' with different request parameters."
                );
            }

            return [
                'code' => $existing->response_code,
                'body' => $existing->response_body,
                'is_replay' => true,
            ];
        }

        // 2. Execute callback inside transaction and persist idempotency record atomically
        return DB::transaction(function () use ($tenantId, $branchId, $actionType, $idempotencyKey, $requestHash, $callback, $userId) {
            $result = $callback();
            $code = $result['code'] ?? 200;
            $body = $result['body'] ?? $result;
            $resourceId = $result['resource_id'] ?? null;

            ErpIdempotencyRecord::create([
                'tenant_id' => $tenantId,
                'branch_id' => $branchId,
                'action_type' => $actionType,
                'idempotency_key' => $idempotencyKey,
                'request_hash' => $requestHash,
                'response_code' => $code,
                'response_body' => $body,
                'resource_id' => $resourceId ? (string) $resourceId : null,
                'user_id' => $userId,
            ]);

            return [
                'code' => $code,
                'body' => $body,
                'is_replay' => false,
            ];
        });
    }

    public function calculateHash(array $payload): string
    {
        $normalized = $this->normalizeArray($payload);
        return hash('sha256', (string) json_encode($normalized));
    }

    private function normalizeArray(array $data): array
    {
        ksort($data);
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $data[$key] = $this->normalizeArray($value);
            }
        }
        return $data;
    }
}
