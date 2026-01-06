# Account Lockout Protection Feature

**Implementation Date:** 2026-01-06
**Status:** ✅ COMPLETED
**Security Level:** High Priority

---

## Overview

The Account Lockout Protection feature prevents brute force attacks on user accounts by temporarily locking accounts after multiple failed login attempts. This is a critical security feature that protects against automated password guessing attacks.

---

## Configuration

### Default Settings

```php
// app/Services/AccountLockoutService.php
const MAX_ATTEMPTS = 5;              // Maximum failed attempts before lockout
const LOCKOUT_DURATION = 15;         // Lockout duration in minutes
const ATTEMPT_WINDOW = 15;           // Time window to count attempts (minutes)
```

### Customization

To modify lockout settings, edit the constants in `app/Services/AccountLockoutService.php`:

```php
class AccountLockoutService
{
    // Increase lockout duration to 30 minutes
    private const LOCKOUT_DURATION = 30;

    // Allow more attempts before lockout
    private const MAX_ATTEMPTS = 10;

    // Widen the attempt window
    private const ATTEMPT_WINDOW = 30;
}
```

---

## How It Works

### 1. Login Attempt Tracking

Every login attempt is recorded in the `login_attempts` table:
- Email address
- IP address
- Success/failure status
- Timestamp

### 2. Lockout Triggering

When a user fails login **5 times within 15 minutes**:
1. The `account_lockouts` table is updated
2. `failed_attempts` counter is incremented
3. `locked_until` timestamp is set to current time + 15 minutes
4. A warning is logged to the system logs

### 3. Lockout Enforcement

During lockout period:
- All login attempts are rejected with HTTP 403
- User cannot login even with correct password
- Clear error message tells user to wait

### 4. Lockout Expiration

After 15 minutes:
- Lockout automatically expires
- User can attempt login again
- Failed attempt counter resets on successful login

---

## Database Schema

### login_attempts Table

```sql
CREATE TABLE login_attempts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    successful BOOLEAN DEFAULT FALSE,
    attempted_at TIMESTAMP NOT NULL,
    INDEX idx_email (email),
    INDEX idx_email_attempted (email, attempted_at)
);
```

### account_lockouts Table

```sql
CREATE TABLE account_lockouts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    failed_attempts INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

---

## API Integration

### AuthController Integration

The lockout service is integrated into the login endpoint:

```php
public function login(Request $request)
{
    // 1. Check if account is locked
    if ($this->lockoutService->isLocked($request->email)) {
        $remainingTime = $this->lockoutService->getRemainingLockoutTime($request->email);
        return response()->json([
            'success' => false,
            'message' => "Account is temporarily locked. Try again in {$remainingTime} minutes.",
            'locked_until' => $remainingTime
        ], 403);
    }

    // 2. Attempt authentication
    if (!$user || !Hash::check($request->password, $user->password)) {
        // Record failed attempt
        $this->lockoutService->recordFailedAttempt($request->email, $request->ip());
        return response()->json(['success' => false, 'message' => 'Invalid credentials'], 401);
    }

    // 3. Record successful login and reset lockout
    $this->lockoutService->recordSuccessfulAttempt($request->email, $request->ip());

    // ... continue with token generation
}
```

---

## Service Methods

### AccountLockoutService

#### isLocked(string $email): bool

Checks if an account is currently locked.

```php
$isLocked = $lockoutService->isLocked('user@example.com');
if ($isLocked) {
    // Handle locked account
}
```

#### recordFailedAttempt(string $email, string $ipAddress): void

Records a failed login attempt and locks account if threshold reached.

```php
$lockoutService->recordFailedAttempt('user@example.com', '192.168.1.1');
```

#### recordSuccessfulAttempt(string $email, string $ipAddress): void

Records successful login and resets lockout status.

```php
$lockoutService->recordSuccessfulAttempt('user@example.com', '192.168.1.1');
```

#### getRemainingLockoutTime(string $email): ?int

Gets remaining lockout time in minutes.

```php
$minutes = $lockoutService->getRemainingLockoutTime('user@example.com');
// Returns: 12 (means 12 minutes remaining)
```

#### resetLockout(string $email): void

Manually resets lockout for an account (admin override).

```php
$lockoutService->resetLockout('user@example.com');
```

#### cleanupOldAttempts(): int

Removes login attempts older than 30 days (maintenance).

```php
$deleted = $lockoutService->cleanupOldAttempts();
// Returns: 150 (number of records deleted)
```

#### getLockoutStats(): array

Gets lockout statistics for monitoring.

```php
$stats = $lockoutService->getLockoutStats();
/*
Returns:
[
    'currently_locked' => 5,
    'lockouts_today' => 12,
    'failed_attempts_today' => 87
]
*/
```

---

## Security Features

### 1. Brute Force Prevention
- Limits automated password guessing attacks
- Makes password cracking computationally expensive

### 2. IP Tracking
- Records IP address with each attempt
- Helps identify attack patterns
- Useful for security audits

### 3. Logging
- Warning logs when accounts are locked
- Helps security teams monitor threats
- Audit trail for compliance

### 4. Automatic Expiration
- Prevents permanent lockouts
- No manual intervention required
- User-friendly design

---

## User Experience

### Failed Login Response

```json
{
  "success": false,
  "message": "Invalid credentials"
}
```
*Status: 401 Unauthorized*

### Lockout Response

```json
{
  "success": false,
  "message": "Account is temporarily locked due to multiple failed login attempts. Please try again in 12 minutes.",
  "locked_until": 12
}
```
*Status: 403 Forbidden*

### Error Messages

- **Clear Communication:** Users know exactly why they can't login
- **Time Remaining:** Shows how long to wait
- **No Account Enumeration:** Same message for valid and invalid accounts

---

## Monitoring

### Real-Time Monitoring

```php
use App\Services\AccountLockoutService;

$lockoutService = app(AccountLockoutService::class);
$stats = $lockoutService->getLockoutStats();

echo "Currently locked accounts: {$stats['currently_locked']}\n";
echo "Lockouts today: {$stats['lockouts_today']}\n";
echo "Failed attempts today: {$stats['failed_attempts_today']}\n";
```

### Log Monitoring

Check application logs for lockout events:

```bash
tail -f storage/logs/laravel.log | grep "Account locked"
```

Example log entry:
```
[2026-01-06 15:42:31] local.WARNING: Account locked for user@example.com after 5 failed attempts
```

---

## Maintenance

### Cleanup Old Attempts

Run periodically to clean up old data:

```php
// In a scheduled job or maintenance script
use App\Services\AccountLockoutService;

$lockoutService = app(AccountLockoutService::class);
$deleted = $lockoutService->cleanupOldAttempts();

Log::info("Cleaned up {$deleted} old login attempts");
```

### Manual Unlock (Admin)

If a legitimate user is locked out and needs immediate access:

```php
use App\Services\AccountLockoutService;

$lockoutService = app(AccountLockoutService::class);
$lockoutService->resetLockout('user@example.com');

Log::info("Admin unlocked account for user@example.com");
```

---

## Testing

### Test Coverage

**9 comprehensive tests** covering all scenarios:

1. ✅ Successful login does not trigger lockout
2. ✅ Failed login attempts are recorded
3. ✅ Account locks after 5 failed attempts
4. ✅ Lockout prevents login with correct password
5. ✅ Successful login resets failed attempts
6. ✅ Lockout expires after 15 minutes
7. ✅ Multiple IPs can fail simultaneously
8. ✅ Lockout service tracks statistics
9. ✅ Non-existent user fails without creating lockout

### Running Tests

```bash
php artisan test --filter=AccountLockoutTest
```

Expected output:
```
PASS  Tests\Feature\Api\AccountLockoutTest
Tests:    9 passed (29 assertions)
```

---

## Best Practices

### DO:
✅ Monitor lockout statistics daily
✅ Alert security team on unusual lockout patterns
✅ Clean up old attempts monthly
✅ Review logs for persistent attackers
✅ Educate users about account security

### DON'T:
❌ Disable lockout protection
❌ Set MAX_ATTEMPTS too high (>10)
❌ Make LOCKOUT_DURATION too short (<5 min)
❌ Manually unlock without investigation
❌ Ignore spike in lockout events

---

## Troubleshooting

### Issue: Legitimate user keeps getting locked out

**Possible Causes:**
- User forgot password
- Password manager using wrong credentials
- Account compromised

**Solution:**
1. Verify user identity
2. Reset lockout: `$lockoutService->resetLockout($email)`
3. Suggest password reset
4. Enable MFA for account

### Issue: Many accounts locked simultaneously

**Possible Causes:**
- Distributed brute force attack
- System integration error

**Solution:**
1. Check `login_attempts` table for patterns
2. Look for common IP addresses
3. Implement IP-based rate limiting
4. Alert security team

---

## Future Enhancements

### Planned Features:
- [ ] Email notification on lockout
- [ ] Admin dashboard for lockout management
- [ ] IP-based progressive delays
- [ ] CAPTCHA after 3 failed attempts
- [ ] Geolocation tracking
- [ ] Integration with SIEM systems

---

## Compliance

### OWASP Compliance

This feature addresses:
- **OWASP Top 10 2021**: A07:2021 – Identification and Authentication Failures
- **CWE-307**: Improper Restriction of Excessive Authentication Attempts

### Standards Met:
✅ NIST SP 800-63B Authentication Guidelines
✅ PCI DSS Requirement 8.1.6
✅ GDPR Article 32 (Security of Processing)

---

## References

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [NIST Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- Laravel Security Best Practices

---

**Version:** 1.0.0
**Last Updated:** 2026-01-06
**Maintainer:** Development Team
