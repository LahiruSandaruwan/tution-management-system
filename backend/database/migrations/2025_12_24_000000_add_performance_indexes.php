<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Add performance indexes for frequently queried columns.
     */
    public function up(): void
    {
        // Students table indexes
        Schema::table('students', function (Blueprint $table) {
            $table->index('student_id_number', 'idx_students_student_id');
            $table->index('status', 'idx_students_status');
            $table->index(['institute_id', 'status'], 'idx_students_institute_status');
        });

        // Payments table indexes
        Schema::table('payments', function (Blueprint $table) {
            $table->index('status', 'idx_payments_status');
            $table->index('due_date', 'idx_payments_due_date');
            $table->index(['student_id', 'status'], 'idx_payments_student_status');
            $table->index(['institute_id', 'status'], 'idx_payments_institute_status');
            $table->index(['due_date', 'status'], 'idx_payments_due_date_status');
        });

        // Attendances table indexes
        Schema::table('attendances', function (Blueprint $table) {
            $table->index('date', 'idx_attendances_date');
            $table->index('status', 'idx_attendances_status');
            $table->index(['student_id', 'date'], 'idx_attendances_student_date');
            $table->index(['class_id', 'date'], 'idx_attendances_class_date');
        });

        // Gate logs table indexes
        Schema::table('gate_logs', function (Blueprint $table) {
            $table->index('card_uid', 'idx_gate_logs_card_uid');
            $table->index('timestamp', 'idx_gate_logs_timestamp');
            $table->index('access_granted', 'idx_gate_logs_access_granted');
            $table->index(['institute_id', 'timestamp'], 'idx_gate_logs_institute_timestamp');
        });

        // RFID cards table indexes
        Schema::table('rfid_cards', function (Blueprint $table) {
            if (!Schema::hasColumn('rfid_cards', 'card_uid')) {
                return; // Skip if column doesn't exist
            }

            // Check if unique constraint already exists
            $sm = Schema::getConnection()->getDoctrineSchemaManager();
            $indexes = $sm->listTableIndexes('rfid_cards');

            $hasUniqueIndex = false;
            foreach ($indexes as $index) {
                if ($index->isUnique() && in_array('card_uid', $index->getColumns())) {
                    $hasUniqueIndex = true;
                    break;
                }
            }

            if (!$hasUniqueIndex) {
                $table->unique('card_uid', 'idx_rfid_cards_card_uid_unique');
            }

            $table->index('status', 'idx_rfid_cards_status');
        });

        // Users table indexes
        Schema::table('users', function (Blueprint $table) {
            $table->index('role', 'idx_users_role');
            $table->index(['institute_id', 'role'], 'idx_users_institute_role');
        });

        // Classes table indexes (for faster queries)
        Schema::table('classes', function (Blueprint $table) {
            $table->index('status', 'idx_classes_status');
            $table->index(['institute_id', 'status'], 'idx_classes_institute_status');
        });

        // Schedules table indexes
        Schema::table('schedules', function (Blueprint $table) {
            $table->index('day_of_week', 'idx_schedules_day_of_week');
            $table->index(['class_id', 'day_of_week'], 'idx_schedules_class_day');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('students', function (Blueprint $table) {
            $table->dropIndex('idx_students_student_id');
            $table->dropIndex('idx_students_status');
            $table->dropIndex('idx_students_institute_status');
        });

        Schema::table('payments', function (Blueprint $table) {
            $table->dropIndex('idx_payments_status');
            $table->dropIndex('idx_payments_due_date');
            $table->dropIndex('idx_payments_student_status');
            $table->dropIndex('idx_payments_institute_status');
            $table->dropIndex('idx_payments_due_date_status');
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->dropIndex('idx_attendances_date');
            $table->dropIndex('idx_attendances_status');
            $table->dropIndex('idx_attendances_student_date');
            $table->dropIndex('idx_attendances_class_date');
        });

        Schema::table('gate_logs', function (Blueprint $table) {
            $table->dropIndex('idx_gate_logs_card_uid');
            $table->dropIndex('idx_gate_logs_timestamp');
            $table->dropIndex('idx_gate_logs_access_granted');
            $table->dropIndex('idx_gate_logs_institute_timestamp');
        });

        Schema::table('rfid_cards', function (Blueprint $table) {
            $table->dropUnique('idx_rfid_cards_card_uid_unique');
            $table->dropIndex('idx_rfid_cards_status');
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('idx_users_role');
            $table->dropIndex('idx_users_institute_role');
        });

        Schema::table('classes', function (Blueprint $table) {
            $table->dropIndex('idx_classes_status');
            $table->dropIndex('idx_classes_institute_status');
        });

        Schema::table('schedules', function (Blueprint $table) {
            $table->dropIndex('idx_schedules_day_of_week');
            $table->dropIndex('idx_schedules_class_day');
        });
    }
};
