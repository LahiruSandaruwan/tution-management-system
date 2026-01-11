<?php

use Illuminate\Support\Facades\Route;

// Health check endpoints (no authentication required for monitoring)
Route::get('/health', [App\Http\Controllers\Api\HealthController::class, 'index']);
Route::get('/health/detailed', [App\Http\Controllers\Api\HealthController::class, 'detailed']);
Route::get('/health/database', [App\Http\Controllers\Api\HealthController::class, 'database']);
Route::get('/health/cache', [App\Http\Controllers\Api\HealthController::class, 'cache']);

// Public routes with rate limiting
Route::middleware('throttle:10,1')->group(function () {
    Route::post('/auth/register', [App\Http\Controllers\Api\AuthController::class, 'register']);
});

// Login routes with stricter rate limiting (5 attempts per minute)
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/auth/login', [App\Http\Controllers\Api\AuthController::class, 'login']);
    Route::post('/auth/forgot-password', [App\Http\Controllers\Api\AuthController::class, 'forgotPassword']);
});

// Password reset with moderate rate limiting
Route::middleware('throttle:10,1')->group(function () {
    Route::post('/auth/reset-password', [App\Http\Controllers\Api\AuthController::class, 'resetPassword']);
});

// RFID Gate API routes (protected by API key) with high rate limit for gate operations
Route::prefix('gate')->middleware(['gate.api.key', 'throttle:120,1'])->group(function () {
    Route::post('/verify', [App\Http\Controllers\Api\RFIDVerificationController::class, 'verify']);
    Route::post('/log', [App\Http\Controllers\Api\RFIDVerificationController::class, 'logAccess']);
    Route::get('/live-feed', [App\Http\Controllers\Api\RFIDVerificationController::class, 'liveFeed']);
});

// Protected routes (require authentication)
Route::middleware(['auth:sanctum', 'institute'])->group(function () {

    // Auth routes
    Route::post('/auth/logout', [App\Http\Controllers\Api\AuthController::class, 'logout']);
    Route::get('/auth/me', [App\Http\Controllers\Api\AuthController::class, 'me']);
    Route::post('/auth/change-password', [App\Http\Controllers\Api\AuthController::class, 'changePassword']);
    Route::post('/auth/upload-profile-photo', [App\Http\Controllers\Api\AuthController::class, 'uploadProfilePhoto']);
    Route::post('/auth/update-profile', [App\Http\Controllers\Api\AuthController::class, 'updateProfile']);
    Route::delete('/auth/delete-profile-photo', [App\Http\Controllers\Api\AuthController::class, 'deleteProfilePhoto']);

    // FCM Token routes (Push Notifications)
    Route::prefix('fcm-tokens')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\FcmTokenController::class, 'index']);
        Route::post('/', [App\Http\Controllers\Api\FcmTokenController::class, 'store']);
        Route::delete('/{id}', [App\Http\Controllers\Api\FcmTokenController::class, 'destroy']);
        Route::post('/{id}/deactivate', [App\Http\Controllers\Api\FcmTokenController::class, 'deactivate']);
        Route::delete('/all/delete', [App\Http\Controllers\Api\FcmTokenController::class, 'destroyAll']);
    });

    // GDPR Data Export & Deletion routes (GDPR Article 15, 17, 20)
    Route::get('/gdpr/export-data', [App\Http\Controllers\Api\DataExportController::class, 'exportUserData']);
    Route::delete('/gdpr/delete-account', [App\Http\Controllers\Api\DataExportController::class, 'deleteUserData']);

    // Dashboard routes
    Route::get('/dashboard/stats', [App\Http\Controllers\Api\DashboardController::class, 'stats']);
    Route::get('/dashboard/recent-activities', [App\Http\Controllers\Api\DashboardController::class, 'recentActivities']);

    // Student routes
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('students', App\Http\Controllers\Api\StudentController::class);
        Route::post('/students/{student}/toggle-status', [App\Http\Controllers\Api\StudentController::class, 'toggleStatus']);
        Route::get('/students/{student}/attendance-summary', [App\Http\Controllers\Api\StudentController::class, 'attendanceSummary']);
        Route::get('/students/{student}/payment-summary', [App\Http\Controllers\Api\StudentController::class, 'paymentSummary']);
    });

    // Teacher routes (admin only)
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('teachers', App\Http\Controllers\Api\TeacherController::class);
        Route::post('/teachers/{teacher}/toggle-status', [App\Http\Controllers\Api\TeacherController::class, 'toggleStatus']);
    });

    // Subject routes
    Route::get('/subjects', [App\Http\Controllers\Api\SubjectController::class, 'index']);
    Route::get('/subjects/{subject}', [App\Http\Controllers\Api\SubjectController::class, 'show']);

    // Class routes
    Route::apiResource('classes', App\Http\Controllers\Api\ClassController::class);
    Route::get('/classes/{class}/students', [App\Http\Controllers\Api\ClassController::class, 'students']);
    Route::post('/classes/{class}/enroll', [App\Http\Controllers\Api\ClassController::class, 'enrollStudent']);
    Route::delete('/classes/{class}/students/{student}', [App\Http\Controllers\Api\ClassController::class, 'removeStudent']);

    // Attendance routes
    Route::prefix('attendance')->group(function () {
        Route::post('/mark', [App\Http\Controllers\Api\AttendanceController::class, 'mark']);
        Route::post('/mark-bulk', [App\Http\Controllers\Api\AttendanceController::class, 'markBulk']);
        Route::get('/class/{class}', [App\Http\Controllers\Api\AttendanceController::class, 'getClassAttendance']);
        Route::get('/class/{class}/report', [App\Http\Controllers\Api\AttendanceController::class, 'classReport']);
        Route::get('/student/{student}/summary', [App\Http\Controllers\Api\AttendanceController::class, 'studentSummary']);
    });

    // Payment routes
    Route::prefix('payments')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\PaymentController::class, 'index']);
        Route::post('/', [App\Http\Controllers\Api\PaymentController::class, 'store']);
        Route::get('/defaulters', [App\Http\Controllers\Api\PaymentController::class, 'defaulters']);
        Route::get('/statistics', [App\Http\Controllers\Api\PaymentController::class, 'statistics']);
        Route::get('/student/{student}', [App\Http\Controllers\Api\PaymentController::class, 'studentPayments']);
        Route::post('/generate-monthly', [App\Http\Controllers\Api\PaymentController::class, 'generateMonthly']);
        Route::get('/{payment}', [App\Http\Controllers\Api\PaymentController::class, 'show']);
    });

    // Grade routes
    Route::prefix('grades')->group(function () {
        Route::post('/', [App\Http\Controllers\Api\GradeController::class, 'store']);
        Route::put('/{grade}', [App\Http\Controllers\Api\GradeController::class, 'update']);
        Route::delete('/{grade}', [App\Http\Controllers\Api\GradeController::class, 'destroy']);
        Route::get('/student/{student}', [App\Http\Controllers\Api\GradeController::class, 'studentGrades']);
        Route::get('/class/{class}/exam/{exam}', [App\Http\Controllers\Api\GradeController::class, 'classExamGrades']);
    });

    // Schedule routes
    Route::apiResource('schedules', App\Http\Controllers\Api\ScheduleController::class);
    Route::get('/schedules/teacher/{teacher}', [App\Http\Controllers\Api\ScheduleController::class, 'teacherSchedule']);
    Route::get('/schedules/student/{student}', [App\Http\Controllers\Api\ScheduleController::class, 'studentSchedule']);

    // Announcement routes
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('announcements', App\Http\Controllers\Api\AnnouncementController::class);
        Route::post('/announcements/{announcement}/send', [App\Http\Controllers\Api\AnnouncementController::class, 'send']);
    });

    // Notification routes
    Route::prefix('notifications')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\NotificationController::class, 'index']);
        Route::post('/{notification}/read', [App\Http\Controllers\Api\NotificationController::class, 'markAsRead']);
        Route::get('/unread-count', [App\Http\Controllers\Api\NotificationController::class, 'unreadCount']);
    });

    // RFID Card routes (admin only)
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('rfid-cards', App\Http\Controllers\Api\RfidCardController::class);
        Route::post('/rfid-cards/{rfidCard}/assign', [App\Http\Controllers\Api\RfidCardController::class, 'assignToStudent']);
        Route::post('/rfid-cards/{rfidCard}/block', [App\Http\Controllers\Api\RfidCardController::class, 'block']);
    });

    // Report routes (admin only)
    Route::middleware('role:admin')->prefix('reports')->group(function () {
        Route::get('/attendance', [App\Http\Controllers\Api\ReportController::class, 'attendance']);
        Route::get('/payments', [App\Http\Controllers\Api\ReportController::class, 'payments']);
        Route::get('/gate-logs', [App\Http\Controllers\Api\ReportController::class, 'gateLogs']);
        Route::get('/academic', [App\Http\Controllers\Api\ReportController::class, 'academic']);

        // PDF Export routes
        Route::get('/export/attendance-pdf', [App\Http\Controllers\Api\ReportController::class, 'exportAttendancePdf']);
        Route::get('/export/payments-pdf', [App\Http\Controllers\Api\ReportController::class, 'exportPaymentsPdf']);
        Route::get('/export/monthly-summary-pdf', [App\Http\Controllers\Api\ReportController::class, 'exportMonthlySummaryPdf']);
    });
});
