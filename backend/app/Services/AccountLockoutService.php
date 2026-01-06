<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AccountLockoutService
{
    /**
     * Maximum failed login attempts before lockout
     */
    const MAX_ATTEMPTS = 5;

    /**
     * Lockout duration in minutes
     */
    const LOCKOUT_DURATION = 15;

    /**
     * Time window for counting failed attempts (minutes)
     */
    const ATTEMPT_WINDOW = 15;

    /**
     * Check if an account is currently locked
     */
    public function isLocked(string $email): bool
    {
        $lockout = DB::table('account_lockouts')
            ->where('email', $email)
            ->first();

        if (!$lockout) {
            return false;
        }

        // Check if lockout has expired
        if ($lockout->locked_until && Carbon::parse($lockout->locked_until)->isFuture()) {
            return true;
        }

        // Lockout expired, reset the record
        if ($lockout->locked_until && Carbon::parse($lockout->locked_until)->isPast()) {
            $this->resetLockout($email);
            return false;
        }

        return false;
    }

    /**
     * Get remaining lockout time in minutes
     */
    public function getRemainingLockoutTime(string $email): ?int
    {
        $lockout = DB::table('account_lockouts')
            ->where('email', $email)
            ->first();

        if (!$lockout || !$lockout->locked_until) {
            return null;
        }

        $lockedUntil = Carbon::parse($lockout->locked_until);

        if ($lockedUntil->isPast()) {
            return null;
        }

        return $lockedUntil->diffInMinutes(now());
    }

    /**
     * Record a failed login attempt
     */
    public function recordFailedAttempt(string $email, string $ipAddress): void
    {
        // Record the attempt
        DB::table('login_attempts')->insert([
            'email' => $email,
            'ip_address' => $ipAddress,
            'successful' => false,
            'attempted_at' => now(),
        ]);

        // Count recent failed attempts
        $recentFailedAttempts = $this->getRecentFailedAttempts($email);

        // Update or create lockout record
        DB::table('account_lockouts')->updateOrInsert(
            ['email' => $email],
            [
                'ip_address' => $ipAddress,
                'failed_attempts' => $recentFailedAttempts,
                'locked_until' => $recentFailedAttempts >= self::MAX_ATTEMPTS
                    ? now()->addMinutes(self::LOCKOUT_DURATION)
                    : null,
                'updated_at' => now(),
            ]
        );

        // Log activity if locked
        if ($recentFailedAttempts >= self::MAX_ATTEMPTS) {
            \Log::warning('Account locked due to failed login attempts', [
                'email' => $email,
                'ip_address' => $ipAddress,
                'attempts' => $recentFailedAttempts,
                'locked_until' => now()->addMinutes(self::LOCKOUT_DURATION),
            ]);
        }
    }

    /**
     * Record a successful login attempt
     */
    public function recordSuccessfulAttempt(string $email, string $ipAddress): void
    {
        // Record the successful attempt
        DB::table('login_attempts')->insert([
            'email' => $email,
            'ip_address' => $ipAddress,
            'successful' => true,
            'attempted_at' => now(),
        ]);

        // Reset lockout
        $this->resetLockout($email);
    }

    /**
     * Get count of recent failed attempts
     */
    protected function getRecentFailedAttempts(string $email): int
    {
        return DB::table('login_attempts')
            ->where('email', $email)
            ->where('successful', false)
            ->where('attempted_at', '>=', now()->subMinutes(self::ATTEMPT_WINDOW))
            ->count();
    }

    /**
     * Reset lockout for an account
     */
    public function resetLockout(string $email): void
    {
        DB::table('account_lockouts')
            ->where('email', $email)
            ->update([
                'failed_attempts' => 0,
                'locked_until' => null,
                'updated_at' => now(),
            ]);
    }

    /**
     * Clean up old login attempts (should be run daily)
     */
    public function cleanupOldAttempts(): int
    {
        // Delete attempts older than 30 days
        return DB::table('login_attempts')
            ->where('attempted_at', '<', now()->subDays(30))
            ->delete();
    }

    /**
     * Get lockout statistics for monitoring
     */
    public function getLockoutStats(): array
    {
        $currentlyLocked = DB::table('account_lockouts')
            ->where('locked_until', '>', now())
            ->count();

        $totalLockoutsToday = DB::table('account_lockouts')
            ->where('updated_at', '>=', now()->startOfDay())
            ->where('failed_attempts', '>=', self::MAX_ATTEMPTS)
            ->count();

        $totalAttemptsToday = DB::table('login_attempts')
            ->where('attempted_at', '>=', now()->startOfDay())
            ->where('successful', false)
            ->count();

        return [
            'currently_locked' => $currentlyLocked,
            'lockouts_today' => $totalLockoutsToday,
            'failed_attempts_today' => $totalAttemptsToday,
        ];
    }
}
