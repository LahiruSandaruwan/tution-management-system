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
        Schema::create('exams', function (Blueprint $table) {
            $table->id();
            $table->foreignId('institute_id')->constrained('institutes')->onDelete('cascade');
            $table->foreignId('class_id')->constrained('classes')->onDelete('cascade');
            $table->foreignId('subject_id')->constrained('subjects')->onDelete('cascade');
            $table->string('name'); // e.g., "Monthly Test", "Final Exam", "Mid-Term"
            $table->string('exam_type'); // e.g., "monthly", "quarterly", "final", "mid-term"
            $table->text('description')->nullable();
            $table->date('exam_date');
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();
            $table->integer('duration_minutes')->nullable(); // Exam duration
            $table->decimal('total_marks', 5, 2); // Maximum marks for this exam
            $table->decimal('pass_marks', 5, 2)->nullable(); // Passing marks
            $table->enum('status', ['scheduled', 'ongoing', 'completed', 'cancelled'])->default('scheduled');
            $table->text('instructions')->nullable(); // Exam instructions for students
            $table->timestamps();

            // Indexes for better query performance
            $table->index('institute_id');
            $table->index('class_id');
            $table->index('subject_id');
            $table->index('exam_date');
            $table->index('exam_type');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exams');
    }
};
