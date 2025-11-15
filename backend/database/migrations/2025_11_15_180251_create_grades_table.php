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
        Schema::create('grades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('institute_id')->constrained('institutes')->onDelete('cascade');
            $table->foreignId('class_id')->constrained('classes')->onDelete('cascade');
            $table->foreignId('student_id')->constrained('students')->onDelete('cascade');
            $table->string('exam_type');
            $table->foreignId('subject_id')->constrained('subjects')->onDelete('cascade');
            $table->decimal('marks', 5, 2);
            $table->decimal('max_marks', 5, 2);
            $table->string('grade', 5)->nullable();
            $table->text('remarks')->nullable();
            $table->date('exam_date');
            $table->timestamps();

            // Indexes
            $table->index('institute_id');
            $table->index('class_id');
            $table->index('student_id');
            $table->index('subject_id');
            $table->index('exam_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('grades');
    }
};
