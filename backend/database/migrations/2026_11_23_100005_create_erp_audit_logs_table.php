<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->nullable()->constrained('erp_tenants')->nullOnDelete();
            $table->unsignedBigInteger('branch_id')->nullable();
            $table->string('actor_id', 100);
            $table->string('action', 100);
            $table->string('aggregate_id', 100);
            $table->json('context')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->string('request_id', 100)->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['tenant_id', 'action']);
            $table->index(['actor_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_audit_logs');
    }
};
