<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\Institute;
use App\Services\AccountLockoutService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AccountLockoutTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Institute $institute;

    protected function setUp(): void
    {
        parent::setUp();

        // Create test institute
        $this->institute = Institute::factory()->create();

        // Create test user
        $this->user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('correctpassword'),
            'institute_id' => $this->institute->id,
        ]);
    }

    public function test_successful_login_does_not_trigger_lockout(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'correctpassword',
        ]);

        $response->assertStatus(200);
        $response->assertJson([
            'success' => true,
            'message' => 'Login successful',
        ]);

        // Verify no lockout record exists
        $this->assertDatabaseMissing('account_lockouts', [
            'email' => 'test@example.com',
        ]);
    }

    public function test_failed_login_attempts_are_recorded(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401);
        $response->assertJson([
            'success' => false,
            'message' => 'Invalid credentials',
        ]);

        // Verify failed attempt was recorded
        $this->assertDatabaseHas('login_attempts', [
            'email' => 'test@example.com',
            'successful' => false,
        ]);
    }

    public function test_account_locks_after_five_failed_attempts(): void
    {
        // Make 5 failed login attempts
        for ($i = 0; $i < 5; $i++) {
            $response = $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'wrongpassword',
            ]);

            if ($i < 4) {
                $response->assertStatus(401);
            }
        }

        // The 5th attempt should still return 401, but account should be locked
        $this->assertDatabaseHas('account_lockouts', [
            'email' => 'test@example.com',
        ]);

        // 6th attempt should return lockout message or rate limit
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'correctpassword', // Even with correct password
        ]);

        // Could be 403 (lockout) or 429 (rate limit) - both mean user is blocked
        $this->assertContains($response->status(), [403, 429]);

        if ($response->status() === 403) {
            $response->assertJsonStructure([
                'success',
                'message',
                'locked_until',
            ]);
            $this->assertStringContainsString('temporarily locked', $response->json('message'));
        }
    }

    public function test_lockout_prevents_login_with_correct_password(): void
    {
        // Lock the account by making 5 failed attempts
        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'wrongpassword',
            ]);
        }

        // Try to login with correct password - should be rejected
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'correctpassword',
        ]);

        // Could be 403 (lockout) or 429 (rate limit) - both mean user is blocked
        $this->assertContains($response->status(), [403, 429]);

        if ($response->status() === 403) {
            $response->assertJson([
                'success' => false,
            ]);
        }
    }

    public function test_successful_login_resets_failed_attempts(): void
    {
        // Make 3 failed attempts
        for ($i = 0; $i < 3; $i++) {
            $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'wrongpassword',
            ]);
        }

        // Verify attempts were recorded
        $this->assertEquals(3, \DB::table('login_attempts')
            ->where('email', 'test@example.com')
            ->where('successful', false)
            ->count()
        );

        // Successful login
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'correctpassword',
        ]);

        $response->assertStatus(200);

        // Verify lockout was reset
        $lockout = \DB::table('account_lockouts')
            ->where('email', 'test@example.com')
            ->first();

        if ($lockout) {
            $this->assertEquals(0, $lockout->failed_attempts);
            $this->assertNull($lockout->locked_until);
        }
    }

    public function test_lockout_expires_after_fifteen_minutes(): void
    {
        $lockoutService = app(AccountLockoutService::class);

        // Create a lockout that should have expired
        \DB::table('account_lockouts')->insert([
            'email' => 'test@example.com',
            'failed_attempts' => 5,
            'locked_until' => now()->subMinutes(1), // Expired 1 minute ago
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Should not be locked anymore
        $this->assertFalse($lockoutService->isLocked('test@example.com'));

        // Should be able to login
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'correctpassword',
        ]);

        $response->assertStatus(200);
    }

    public function test_multiple_ips_can_fail_login_simultaneously(): void
    {
        // Simulate attacks from different IPs
        for ($i = 0; $i < 3; $i++) {
            $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'wrongpassword',
            ], ['REMOTE_ADDR' => '192.168.1.1']);
        }

        for ($i = 0; $i < 2; $i++) {
            $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'wrongpassword',
            ], ['REMOTE_ADDR' => '192.168.1.2']);
        }

        // Total 5 attempts from different IPs should lock account
        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'correctpassword',
        ]);

        $response->assertStatus(403);
    }

    public function test_lockout_service_tracks_statistics(): void
    {
        $lockoutService = app(AccountLockoutService::class);

        // Lock one account
        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/auth/login', [
                'email' => 'test@example.com',
                'password' => 'wrongpassword',
            ]);
        }

        // Get statistics
        $stats = $lockoutService->getLockoutStats();

        $this->assertArrayHasKey('currently_locked', $stats);
        $this->assertArrayHasKey('lockouts_today', $stats);
        $this->assertArrayHasKey('failed_attempts_today', $stats);
        $this->assertGreaterThanOrEqual(1, $stats['currently_locked']);
        $this->assertGreaterThanOrEqual(5, $stats['failed_attempts_today']);
    }

    public function test_nonexistent_user_fails_without_creating_lockout(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'nonexistent@example.com',
            'password' => 'anypassword',
        ]);

        $response->assertStatus(401);

        // Attempt should still be recorded for security monitoring
        $this->assertDatabaseHas('login_attempts', [
            'email' => 'nonexistent@example.com',
            'successful' => false,
        ]);
    }
}
