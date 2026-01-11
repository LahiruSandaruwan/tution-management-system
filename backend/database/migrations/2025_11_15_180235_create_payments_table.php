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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('institute_id')->constrained('institutes')->onDelete('cascade');
            $table->foreignId('student_id')->constrained('students')->onDelete('cascade');
            $table->decimal('amount', 10, 2);
            $table->date('payment_date');
            $table->date('due_date');
            $table->string('month', 20);
            $table->year('year');
            $table->enum('status', ['paid', 'pending', 'overdue'])->default('pending');
            $table->string('payment_method')->nullable();
            $table->string('receipt_number')->nullable()->unique();
            $table->text('notes')->nullable();
            $table->timestamps();

            // Indexes
            $table->index('institute_id');
            $table->index('student_id');
            $table->index('status');
            $table->index(['student_id', 'month', 'year']);
            $table->index('payment_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
