<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpRecipeVersion extends Model
{
    protected $table = 'erp_recipe_versions';

    protected $fillable = [
        'recipe_id',
        'version_number',
        'is_active',
        'effective_from',
    ];

    protected $casts = [
        'version_number' => 'integer',
        'is_active' => 'boolean',
        'effective_from' => 'datetime',
    ];

    public function recipe(): BelongsTo
    {
        return $this->belongsTo(ErpRecipe::class, 'recipe_id');
    }

    public function lines(): HasMany
    {
        return $this->hasMany(ErpRecipeLine::class, 'recipe_version_id');
    }
}
