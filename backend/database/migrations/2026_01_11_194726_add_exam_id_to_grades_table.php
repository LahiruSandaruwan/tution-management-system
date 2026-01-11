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
        Schema::table('grades', function (Blueprint $table) {
            // Add exam_id as optional foreign key (nullable for backward compatibility)
            $table->foreignId('exam_id')->nullable()->after('student_id')->constrained('exams')->onDelete('cascade');
            $table->index('exam_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('grades', function (Blueprint $table) {
            $table->dropForeign(['exam_id']);
            $table->dropIndex(['exam_id']);
            $table->dropColumn('exam_id');
        });
    }
};
