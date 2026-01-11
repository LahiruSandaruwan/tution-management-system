<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class () extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('fcm_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->text('token'); // FCM token can be quite long
            $table->string('device_type')->nullable(); // 'android', 'ios', 'web'
            $table->string('device_id')->nullable(); // Unique device identifier
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_used_at')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('user_id');
            $table->index('is_active');
            $table->index(['user_id', 'device_id']); // Composite index for finding specific user's device

            // Unique constraint on token to prevent duplicates
            $table->unique('token', 'fcm_tokens_token_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('fcm_tokens');
    }
};
