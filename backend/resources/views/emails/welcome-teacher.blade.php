<x-mail::message>
# Welcome to {{ $instituteName }}!

Dear {{ $teacherName }},

We're delighted to welcome you as a new teacher at **{{ $instituteName }}**!

Your teacher account has been successfully created and you now have access to our Tuition Management System.

<x-mail::panel>
## Your Account Details

- **Email:** {{ $email }}
- **Employee ID:** {{ $teacher->employee_id }}
@if($temporaryPassword)
- **Temporary Password:** {{ $temporaryPassword }}
@endif
- **Subject:** {{ $teacher->subject }}
</x-mail::panel>

## Getting Started

@if($temporaryPassword)
1. Download our teacher mobile app from the Play Store or App Store
2. Log in with your email and the temporary password provided above
3. **Important:** Change your password immediately after your first login
4. Complete your profile information
5. Start managing your classes, marking attendance, and grading students!
@else
1. Download our teacher mobile app from the Play Store or App Store
2. Log in with your email and password
3. Complete your profile information
4. Start managing your classes, marking attendance, and grading students!
@endif

## App Features

- 📅 Manage your class schedule
- ✅ Mark student attendance with RFID scanning
- 📊 Record and track student grades
- 👥 View your student list
- 📢 Send notifications to students
- 👤 Manage your profile

## Additional Resources

You will have access to:
- Student management tools
- Attendance marking system
- Grade reporting features
- Performance analytics

If you have any questions or need assistance, please contact the institute administration.

We're excited to have you on our team!

Best regards,<br>
**{{ $instituteName }}**

---
*Need help? Contact your institute administrator.*
</x-mail::message>
