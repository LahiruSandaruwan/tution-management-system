<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('gate_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('institute_id')->constrained('institutes')->onDelete('cascade');
            $table->foreignId('rfid_card_id')->nullable()->constrained('rfid_cards')->onDelete('set null');
            $table->foreignId('student_id')->nullable()->constrained('students')->onDelete('set null');
            $table->enum('action', ['entry', 'exit']);
            $table->enum('status', ['success', 'denied'])->default('success');
            $table->string('reason')->nullable();
            $table->timestamp('timestamp')->useCurrent();
            $table->timestamp('created_at')->useCurrent();

            // Indexes
            $table->index('institute_id');
            $table->index('rfid_card_id');
            $table->index('student_id');
            $table->index('timestamp');
            $table->index(['institute_id', 'timestamp']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gate_logs');
    }
};
