<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_tenants', function (Blueprint $table) {
            $table->id();
            $table->string('ulid', 26)->unique();
            $table->string('slug', 100)->unique();
            $table->string('name', 255);
            $table->string('status', 30)->default('active');
            $table->json('settings')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_tenants');
    }
};
