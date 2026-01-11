<?php

namespace App\Http\Controllers\Api;

use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * GDPR Data Export Controller
 *
 * Provides users with the ability to export all their personal data
 * in compliance with GDPR Article 15 (Right of Access) and Article 20 (Right to Data Portability)
 */
class DataExportController extends Controller
{
    /**
     * Export all user data in JSON format
     *
     * GDPR Article 15: Right of Access
     * GDPR Article 20: Right to Data Portability
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function exportUserData(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated',
                ], 401);
            }

            // Build comprehensive data export
            $exportData = [
                'export_metadata' => [
                    'export_date' => now()->toIso8601String(),
                    'export_format' => 'JSON',
                    'gdpr_compliance' => 'Article 15 (Right of Access), Article 20 (Data Portability)',
                    'user_id' => $user->id,
                ],
                'user_account' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'institute_id' => $user->institute_id,
                    'institute_name' => $user->institute ? $user->institute->name : null,
                    'email_verified_at' => $user->email_verified_at?->toIso8601String(),
                    'created_at' => $user->created_at->toIso8601String(),
                    'updated_at' => $user->updated_at->toIso8601String(),
                ],
                'profile_data' => [],
                'activity_logs' => [],
                'authentication_history' => [],
            ];

            // Export role-specific data
            if ($user->role === 'student') {
                $exportData['profile_data'] = $this->exportStudentData($user);
            } elseif ($user->role === 'teacher') {
                $exportData['profile_data'] = $this->exportTeacherData($user);
            } elseif ($user->role === 'admin') {
                $exportData['profile_data'] = $this->exportAdminData($user);
            }

            // Export login attempts (last 100)
            $exportData['authentication_history'] = $this->exportLoginHistory($user);

            // Export account lockouts (if any)
            $exportData['account_lockouts'] = $this->exportLockoutHistory($user);

            // Log the export request for audit trail
            Log::info('GDPR data export requested', [
                'user_id' => $user->id,
                'email' => $user->email,
                'role' => $user->role,
                'ip_address' => $request->ip(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User data exported successfully',
                'data' => $exportData,
            ], 200);

        } catch (\Exception $e) {
            Log::error('Data export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to export user data',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }

    /**
     * Export student-specific data
     */
    private function exportStudentData(User $user): array
    {
        $student = Student::where('user_id', $user->id)
            ->with(['grade', 'enrollments.class', 'payments', 'rfidCards', 'gateLogs'])
            ->first();

        if (!$student) {
            return [];
        }

        return [
            'student_profile' => [
                'id' => $student->id,
                'student_id' => $student->student_id,
                'full_name' => $student->full_name,
                'date_of_birth' => $student->date_of_birth,
                'gender' => $student->gender,
                'address' => $student->address,
                'phone' => $student->phone,
                'emergency_contact' => $student->emergency_contact,
                'emergency_phone' => $student->emergency_phone,
                'grade_id' => $student->grade_id,
                'grade_name' => $student->grade?->name,
                'is_active' => $student->is_active,
                'profile_image' => $student->profile_image,
                'enrolled_date' => $student->enrolled_date,
                'created_at' => $student->created_at->toIso8601String(),
                'updated_at' => $student->updated_at->toIso8601String(),
            ],
            'class_enrollments' => $student->enrollments->map(fn ($enrollment) => [
                'class_id' => $enrollment->class_id,
                'class_name' => $enrollment->class?->name,
                'subject' => $enrollment->class?->subject?->name,
                'teacher' => $enrollment->class?->teacher?->full_name,
                'enrolled_at' => $enrollment->enrolled_at?->toIso8601String(),
                'status' => $enrollment->status,
            ])->toArray(),
            'payments' => $student->payments->map(fn ($payment) => [
                'id' => $payment->id,
                'amount' => $payment->amount,
                'payment_date' => $payment->payment_date,
                'payment_method' => $payment->payment_method,
                'status' => $payment->status,
                'description' => $payment->description,
                'month' => $payment->month,
                'year' => $payment->year,
                'created_at' => $payment->created_at->toIso8601String(),
            ])->toArray(),
            'rfid_cards' => $student->rfidCards->map(fn ($card) => [
                'id' => $card->id,
                'rfid_number' => $card->rfid_number,
                'is_active' => $card->is_active,
                'issued_date' => $card->issued_date?->toIso8601String(),
                'last_used' => $card->last_used?->toIso8601String(),
            ])->toArray(),
            'gate_access_logs' => $student->gateLogs->map(fn ($log) => [
                'id' => $log->id,
                'gate_type' => $log->gate_type,
                'timestamp' => $log->timestamp?->toIso8601String(),
                'rfid_number' => $log->rfid_number,
                'verification_status' => $log->verification_status,
            ])->toArray(),
        ];
    }

    /**
     * Export teacher-specific data
     */
    private function exportTeacherData(User $user): array
    {
        $teacher = Teacher::where('user_id', $user->id)
            ->with(['subject', 'classes', 'schedules'])
            ->first();

        if (!$teacher) {
            return [];
        }

        return [
            'teacher_profile' => [
                'id' => $teacher->id,
                'employee_id' => $teacher->employee_id,
                'full_name' => $teacher->full_name,
                'phone' => $teacher->phone,
                'address' => $teacher->address,
                'subject_id' => $teacher->subject_id,
                'subject_name' => $teacher->subject?->name,
                'qualifications' => $teacher->qualifications,
                'hire_date' => $teacher->hire_date,
                'is_active' => $teacher->is_active,
                'profile_image' => $teacher->profile_image,
                'created_at' => $teacher->created_at->toIso8601String(),
                'updated_at' => $teacher->updated_at->toIso8601String(),
            ],
            'classes' => $teacher->classes->map(fn ($class) => [
                'id' => $class->id,
                'name' => $class->name,
                'subject' => $class->subject?->name,
                'grade' => $class->grade?->name,
                'monthly_fee' => $class->monthly_fee,
                'max_students' => $class->max_students,
                'is_active' => $class->is_active,
                'created_at' => $class->created_at->toIso8601String(),
            ])->toArray(),
            'schedules' => $teacher->schedules->map(fn ($schedule) => [
                'id' => $schedule->id,
                'class_name' => $schedule->class?->name,
                'day_of_week' => $schedule->day_of_week,
                'start_time' => $schedule->start_time,
                'end_time' => $schedule->end_time,
                'room' => $schedule->room,
                'is_active' => $schedule->is_active,
            ])->toArray(),
        ];
    }

    /**
     * Export admin-specific data
     */
    private function exportAdminData(User $user): array
    {
        // Admin users don't have additional profile data beyond user account
        // But we can include their institute management data
        return [
            'admin_role' => 'Institute Administrator',
            'permissions' => [
                'manage_students' => true,
                'manage_teachers' => true,
                'manage_classes' => true,
                'manage_payments' => true,
                'view_reports' => true,
                'system_settings' => true,
            ],
        ];
    }

    /**
     * Export login history (last 100 attempts)
     */
    private function exportLoginHistory(User $user): array
    {
        return DB::table('login_attempts')
            ->where('email', $user->email)
            ->orderBy('attempted_at', 'desc')
            ->limit(100)
            ->get()
            ->map(fn ($attempt) => [
                'email' => $attempt->email,
                'ip_address' => $attempt->ip_address,
                'successful' => (bool) $attempt->successful,
                'attempted_at' => $attempt->attempted_at,
            ])
            ->toArray();
    }

    /**
     * Export account lockout history
     */
    private function exportLockoutHistory(User $user): array
    {
        $lockout = DB::table('account_lockouts')
            ->where('email', $user->email)
            ->first();

        if (!$lockout) {
            return [];
        }

        return [
            'email' => $lockout->email,
            'failed_attempts' => $lockout->failed_attempts,
            'locked_until' => $lockout->locked_until,
            'last_updated' => $lockout->updated_at,
        ];
    }

    /**
     * Delete user account and all associated data
     *
     * GDPR Article 17: Right to Erasure (Right to be Forgotten)
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function deleteUserData(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated',
                ], 401);
            }

            // Validate deletion request with password confirmation
            $request->validate([
                'password' => 'required|string',
                'confirmation' => 'required|in:DELETE_MY_ACCOUNT',
            ]);

            // Verify password
            if (!password_verify($request->password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid password confirmation',
                ], 403);
            }

            // Log deletion request for audit trail (before deletion)
            Log::warning('GDPR account deletion requested', [
                'user_id' => $user->id,
                'email' => $user->email,
                'role' => $user->role,
                'ip_address' => $request->ip(),
            ]);

            DB::beginTransaction();

            try {
                // Delete role-specific data
                if ($user->role === 'student') {
                    $student = Student::where('user_id', $user->id)->first();
                    if ($student) {
                        // Cascade delete will handle enrollments, payments, rfid_cards, gate_logs
                        $student->delete();
                    }
                } elseif ($user->role === 'teacher') {
                    $teacher = Teacher::where('user_id', $user->id)->first();
                    if ($teacher) {
                        // Cascade delete will handle classes, schedules
                        $teacher->delete();
                    }
                }

                // Delete login attempts
                DB::table('login_attempts')->where('email', $user->email)->delete();

                // Delete account lockouts
                DB::table('account_lockouts')->where('email', $user->email)->delete();

                // Delete user tokens
                $user->tokens()->delete();

                // Finally, delete the user account
                $user->delete();

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Your account and all associated data have been permanently deleted',
                ], 200);

            } catch (\Exception $e) {
                DB::rollBack();

                throw $e;
            }

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('Account deletion failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete account',
                'error' => config('app.debug') ? $e->getMessage() : 'Internal server error',
            ], 500);
        }
    }
}
