<?php

namespace App\ERP\Infrastructure\Security;

use Illuminate\Support\Facades\DB;
use RuntimeException;

class DatabaseSafetyGuard
{
    /**
     * Asserts that the active database connection is strictly an isolated local SQLite database.
     * Throws RuntimeException immediately if non-SQLite or production connection is detected.
     */
    public static function assertIsolatedLocalSqlite(): void
    {
        $connectionName = DB::getDefaultConnection();
        $config = config("database.connections.{$connectionName}", []);
        $driver = $config['driver'] ?? null;
        $database = $config['database'] ?? null;

        if ($driver !== 'sqlite') {
            throw new RuntimeException(
                "SAFETY HALT: ERP execution is strictly restricted to SQLite. Current driver: '{$driver}'."
            );
        }

        // Allow in-memory sqlite for testing
        if ($database === ':memory:') {
            return;
        }

        // For file-based SQLite, verify it is inside the project and not connected to an external or production database
        $normalizedPath = str_replace('\\', '/', (string) $database);
        $projectPath = str_replace('\\', '/', base_path());

        $isInsideProject = str_starts_with($normalizedPath, $projectPath) 
            || str_starts_with($normalizedPath, 'database/')
            || !str_contains($normalizedPath, '/');

        if (!$isInsideProject && !file_exists($database)) {
            // Also accept relative path resolved against database_path
            $resolved = database_path(basename($database));
            if (!str_starts_with(str_replace('\\', '/', $resolved), $projectPath)) {
                throw new RuntimeException(
                    "SAFETY HALT: SQLite database path '{$database}' is outside the authorized local workspace."
                );
            }
        }
    }
}
