<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class Setting extends Model
{
    protected $primaryKey = 'key';
    public $incrementing = false;
    protected $keyType = 'string';
    protected $fillable = ['key', 'value'];

    /**
     * Get a setting by key with a default fallback.
     */
    public static function get(string $key, $default = null)
    {
        try {
            if (Schema::hasTable('settings')) {
                $item = static::find($key);
                if ($item !== null && $item->value !== null) {
                    return $item->value;
                }
            }
        } catch (\Throwable $e) {}

        // Fallback to storage/app/settings.json
        try {
            $filePath = storage_path('app/settings.json');
            if (file_exists($filePath)) {
                $json = json_decode(file_get_contents($filePath), true);
                if (isset($json[$key])) {
                    return $json[$key];
                }
            }
        } catch (\Throwable $e) {}

        return $default;
    }

    /**
     * Set a setting by key.
     */
    public static function set(string $key, $value): bool
    {
        // 1. Save to JSON file as immediate reliable fallback
        try {
            $dir = storage_path('app');
            if (!is_dir($dir)) {
                @mkdir($dir, 0755, true);
            }
            $filePath = $dir . '/settings.json';
            $data = [];
            if (file_exists($filePath)) {
                $data = json_decode(file_get_contents($filePath), true) ?: [];
            }
            $data[$key] = $value;
            @file_put_contents($filePath, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
        } catch (\Throwable $e) {}

        // 2. Save to database table
        try {
            if (!Schema::hasTable('settings')) {
                Schema::create('settings', function ($table) {
                    $table->string('key')->primary();
                    $table->text('value')->nullable();
                    $table->timestamps();
                });
            }
            static::updateOrCreate(['key' => $key], ['value' => (string)$value]);
            return true;
        } catch (\Throwable $e) {
            return true;
        }
    }
}
