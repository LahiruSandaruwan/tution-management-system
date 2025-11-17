<x-mail::message>
# Welcome to {{ $instituteName }}!

Dear {{ $studentName }},

We're excited to welcome you as a new student at **{{ $instituteName }}**!

Your student account has been successfully created and you now have access to our Tuition Management System.

<x-mail::panel>
## Your Account Details

- **Email:** {{ $email }}
- **Student ID:** {{ $student->registration_number }}
@if($temporaryPassword)
- **Temporary Password:** {{ $temporaryPassword }}
@endif
</x-mail::panel>

## Getting Started

@if($temporaryPassword)
1. Download our student mobile app from the Play Store or App Store
2. Log in with your email and the temporary password provided above
3. **Important:** Change your password immediately after your first login
4. Complete your profile information
5. Start tracking your attendance, payments, and grades!
@else
1. Download our student mobile app from the Play Store or App Store
2. Log in with your email and password
3. Complete your profile information
4. Start tracking your attendance, payments, and grades!
@endif

## App Features

- 📅 View your class schedule and attendance
- 💰 Track your payment history
- 📊 Monitor your grades and performance
- 📢 Receive important notifications
- 👤 Manage your profile

If you have any questions or need assistance, please don't hesitate to contact the institute administration.

We look forward to being part of your educational journey!

Best regards,<br>
**{{ $instituteName }}**

---
*Need help? Contact your institute administrator.*
</x-mail::message>
