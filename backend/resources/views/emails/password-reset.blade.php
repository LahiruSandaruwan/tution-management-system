<x-mail::message>
# Password Reset Request

Dear {{ $userName }},

We received a request to reset your password for your account.

<x-mail::panel>
## Your Reset Token

**{{ $token }}**

Please use this token to reset your password. This token will expire in 60 minutes.
</x-mail::panel>

## How to Reset Your Password

1. Open the mobile app or web dashboard
2. Navigate to the "Reset Password" page
3. Enter your email address: **{{ $email }}**
4. Enter the reset token shown above
5. Create your new password

**Important Security Notice:**
- This token is valid for 60 minutes only
- If you didn't request this password reset, please ignore this email
- Never share your reset token with anyone

If you have any issues, please contact your institute administrator.

Best regards,<br>
**Tuition Management System**

---
*This is an automated email. Please do not reply directly to this message.*
</x-mail::message>
