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
        Schema::create('fee_structures', function (Blueprint $table) {
            $table->id();
            $table->foreignId('institute_id')->constrained('institutes')->onDelete('cascade');
            $table->string('grade', 50);
            $table->foreignId('subject_id')->nullable()->constrained('subjects')->onDelete('cascade');
            $table->decimal('monthly_fee', 10, 2);
            $table->decimal('registration_fee', 10, 2)->default(0);
            $table->timestamps();

            // Indexes
            $table->index('institute_id');
            $table->index('grade');
            $table->index('subject_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('fee_structures');
    }
};
