<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_user_permissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('permission', 100);
            $table->timestamps();

            $table->unique(['tenant_id', 'user_id', 'permission']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_user_permissions');
    }
};
