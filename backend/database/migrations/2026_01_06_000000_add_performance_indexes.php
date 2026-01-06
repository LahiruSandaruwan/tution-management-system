<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Students table indexes
        Schema::table('students', function (Blueprint $table) {
            if (!$this->indexExists('students', 'idx_students_student_id_number')) {
                $table->index('student_id_number', 'idx_students_student_id_number');
            }
            if (!$this->indexExists('students', 'idx_students_institute_active')) {
                $table->index(['institute_id', 'is_active'], 'idx_students_institute_active');
            }
            if (!$this->indexExists('students', 'idx_students_grade')) {
                $table->index('grade', 'idx_students_grade');
            }
        });

        // Payments table indexes
        Schema::table('payments', function (Blueprint $table) {
            if (!$this->indexExists('payments', 'idx_payments_status')) {
                $table->index('status', 'idx_payments_status');
            }
            if (!$this->indexExists('payments', 'idx_payments_due_date')) {
                $table->index('due_date', 'idx_payments_due_date');
            }
            if (!$this->indexExists('payments', 'idx_payments_student_status')) {
                $table->index(['student_id', 'status'], 'idx_payments_student_status');
            }
            if (!$this->indexExists('payments', 'idx_payments_institute_status')) {
                $table->index(['institute_id', 'status'], 'idx_payments_institute_status');
            }
            if (!$this->indexExists('payments', 'idx_payments_month_year')) {
                $table->index(['month', 'year'], 'idx_payments_month_year');
            }
        });

        // Attendances table indexes
        Schema::table('attendances', function (Blueprint $table) {
            if (!$this->indexExists('attendances', 'idx_attendances_date')) {
                $table->index('date', 'idx_attendances_date');
            }
            if (!$this->indexExists('attendances', 'idx_attendances_status')) {
                $table->index('status', 'idx_attendances_status');
            }
            if (!$this->indexExists('attendances', 'idx_attendances_student_date')) {
                $table->index(['student_id', 'date'], 'idx_attendances_student_date');
            }
            if (!$this->indexExists('attendances', 'idx_attendances_class_date')) {
                $table->index(['class_id', 'date'], 'idx_attendances_class_date');
            }
            if (!$this->indexExists('attendances', 'idx_attendances_institute_date')) {
                $table->index(['institute_id', 'date'], 'idx_attendances_institute_date');
            }
        });

        // Users table indexes
        Schema::table('users', function (Blueprint $table) {
            if (!$this->indexExists('users', 'idx_users_role')) {
                $table->index('role', 'idx_users_role');
            }
            if (!$this->indexExists('users', 'idx_users_institute_role')) {
                $table->index(['institute_id', 'role'], 'idx_users_institute_role');
            }
        });

        // Teachers table indexes
        Schema::table('teachers', function (Blueprint $table) {
            if (!$this->indexExists('teachers', 'idx_teachers_institute_active')) {
                $table->index(['institute_id', 'is_active'], 'idx_teachers_institute_active');
            }
        });

        // Classes table indexes
        Schema::table('classes', function (Blueprint $table) {
            if (!$this->indexExists('classes', 'idx_classes_grade')) {
                $table->index('grade', 'idx_classes_grade');
            }
            if (!$this->indexExists('classes', 'idx_classes_is_active')) {
                $table->index('is_active', 'idx_classes_is_active');
            }
            if (!$this->indexExists('classes', 'idx_classes_institute_active')) {
                $table->index(['institute_id', 'is_active'], 'idx_classes_institute_active');
            }
        });

        // Activity logs table indexes
        Schema::table('activity_logs', function (Blueprint $table) {
            if (!$this->indexExists('activity_logs', 'idx_activity_logs_user_id')) {
                $table->index('user_id', 'idx_activity_logs_user_id');
            }
            if (!$this->indexExists('activity_logs', 'idx_activity_logs_action')) {
                $table->index('action', 'idx_activity_logs_action');
            }
            if (!$this->indexExists('activity_logs', 'idx_activity_logs_created_at')) {
                $table->index('created_at', 'idx_activity_logs_created_at');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Students table indexes
        Schema::table('students', function (Blueprint $table) {
            if ($this->indexExists('students', 'idx_students_student_id_number')) {
                $table->dropIndex('idx_students_student_id_number');
            }
            if ($this->indexExists('students', 'idx_students_institute_active')) {
                $table->dropIndex('idx_students_institute_active');
            }
            if ($this->indexExists('students', 'idx_students_grade')) {
                $table->dropIndex('idx_students_grade');
            }
        });

        // Payments table indexes
        Schema::table('payments', function (Blueprint $table) {
            if ($this->indexExists('payments', 'idx_payments_status')) {
                $table->dropIndex('idx_payments_status');
            }
            if ($this->indexExists('payments', 'idx_payments_due_date')) {
                $table->dropIndex('idx_payments_due_date');
            }
            if ($this->indexExists('payments', 'idx_payments_student_status')) {
                $table->dropIndex('idx_payments_student_status');
            }
            if ($this->indexExists('payments', 'idx_payments_institute_status')) {
                $table->dropIndex('idx_payments_institute_status');
            }
            if ($this->indexExists('payments', 'idx_payments_month_year')) {
                $table->dropIndex('idx_payments_month_year');
            }
        });

        // Attendances table indexes
        Schema::table('attendances', function (Blueprint $table) {
            if ($this->indexExists('attendances', 'idx_attendances_date')) {
                $table->dropIndex('idx_attendances_date');
            }
            if ($this->indexExists('attendances', 'idx_attendances_status')) {
                $table->dropIndex('idx_attendances_status');
            }
            if ($this->indexExists('attendances', 'idx_attendances_student_date')) {
                $table->dropIndex('idx_attendances_student_date');
            }
            if ($this->indexExists('attendances', 'idx_attendances_class_date')) {
                $table->dropIndex('idx_attendances_class_date');
            }
            if ($this->indexExists('attendances', 'idx_attendances_institute_date')) {
                $table->dropIndex('idx_attendances_institute_date');
            }
        });

        // Users table indexes
        Schema::table('users', function (Blueprint $table) {
            if ($this->indexExists('users', 'idx_users_role')) {
                $table->dropIndex('idx_users_role');
            }
            if ($this->indexExists('users', 'idx_users_institute_role')) {
                $table->dropIndex('idx_users_institute_role');
            }
        });

        // Teachers table indexes
        Schema::table('teachers', function (Blueprint $table) {
            if ($this->indexExists('teachers', 'idx_teachers_institute_active')) {
                $table->dropIndex('idx_teachers_institute_active');
            }
        });

        // Classes table indexes
        Schema::table('classes', function (Blueprint $table) {
            if ($this->indexExists('classes', 'idx_classes_grade')) {
                $table->dropIndex('idx_classes_grade');
            }
            if ($this->indexExists('classes', 'idx_classes_is_active')) {
                $table->dropIndex('idx_classes_is_active');
            }
            if ($this->indexExists('classes', 'idx_classes_institute_active')) {
                $table->dropIndex('idx_classes_institute_active');
            }
        });

        // Activity logs table indexes
        Schema::table('activity_logs', function (Blueprint $table) {
            if ($this->indexExists('activity_logs', 'idx_activity_logs_user_id')) {
                $table->dropIndex('idx_activity_logs_user_id');
            }
            if ($this->indexExists('activity_logs', 'idx_activity_logs_action')) {
                $table->dropIndex('idx_activity_logs_action');
            }
            if ($this->indexExists('activity_logs', 'idx_activity_logs_created_at')) {
                $table->dropIndex('idx_activity_logs_created_at');
            }
        });
    }

    /**
     * Check if an index exists on a table
     */
    private function indexExists(string $table, string $indexName): bool
    {
        $result = DB::select("SHOW INDEX FROM `{$table}` WHERE Key_name = ?", [$indexName]);
        return count($result) > 0;
    }
};
