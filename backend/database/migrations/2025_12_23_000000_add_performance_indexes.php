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
              // Students table indexes
            Schema::table('students', function (Blueprint $table) {
                          $table->index('student_id_number');
                          $table->index('status');
                          $table->index(['institute_id', 'status']);
            });

            // Payments table indexes
            Schema::table('payments', function (Blueprint $table) {
                          $table->index('status');
                          $table->index('due_date');
                          $table->index(['student_id', 'status']);
                          $table->index(['institute_id', 'status']);
                          $table->index(['due_date', 'status']);
            });

            // Attendances table indexes
            Schema::table('attendances', function (Blueprint $table) {
                          $table->index('date');
                          $table->index('status');
                          $table->index(['student_id', 'date']);
                          $table->index(['class_id', 'date']);
            });

            // Gate logs table indexes
            Schema::table('gate_logs', function (Blueprint $table) {
                          $table->index('card_uid');
                          $table->index('timestamp');
                          $table->index('access_granted');
                          $table->index(['institute_id', 'timestamp']);
            });

            // RFID cards table indexes
            Schema::table('rfid_cards', function (Blueprint $table) {
                          $table->unique('card_uid');
                          $table->index('status');
            });

            // Users table indexes
            Schema::table('users', function (Blueprint $table) {
                          $table->index('role');
                          $table->index(['institute_id', 'role']);
            });
    }

      /**
       * Reverse the migrations.
       */
      public function down(): void
    {
              Schema::table('students', function (Blueprint $table) {
                            $table->dropIndex(['student_id_number']);
                            $table->dropIndex(['status']);
                            $table->dropIndex(['institute_id', 'status']);
              });

            Schema::table('payments', function (Blueprint $table) {
                          $table->dropIndex(['status']);
                          $table->dropIndex(['due_date']);
                          $table->dropIndex(['student_id', 'status']);
                          $table->dropIndex(['institute_id', 'status']);
                          $table->dropIndex(['due_date', 'status']);
            });

            Schema::table('attendances', function (Blueprint $table) {
                          $table->dropIndex(['date']);
                          $table->dropIndex(['status']);
                          $table->dropIndex(['student_id', 'date']);
                          $table->dropIndex(['class_id', 'date']);
            });

            Schema::table('gate_logs', function (Blueprint $table) {
                          $table->dropIndex(['card_uid']);
                          $table->dropIndex(['timestamp']);
                          $table->dropIndex(['access_granted']);
                          $table->dropIndex(['institute_id', 'timestamp']);
            });

            Schema::table('rfid_cards', function (Blueprint $table) {
                          $table->dropUnique(['card_uid']);
                          $table->dropIndex(['status']);
            });

            Schema::table('users', function (Blueprint $table) {
                          $table->dropIndex(['role']);
                          $table->dropIndex(['institute_id', 'role']);
            });
    }
  };
