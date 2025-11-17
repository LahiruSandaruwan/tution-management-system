# Tuition Management System - API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Profile Management](#profile-management)
4. [Dashboard APIs](#dashboard-apis)
5. [Report APIs](#report-apis)
6. [PDF Export APIs](#pdf-export-apis)
7. [Background Jobs](#background-jobs)
8. [Email System](#email-system)

## Overview

The Tuition Management System provides a comprehensive RESTful API built with Laravel 11. All API endpoints are prefixed with `/api` and return JSON responses.

**Base URL:** `http://your-domain.com/api`

**Authentication:** Laravel Sanctum (Token-based)

## Authentication

### Register
**POST** `/auth/register`

Create a new user account (student, teacher, or admin).

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+94771234567",
  "role": "student",
  "institute_id": 1,
  "student_id_number": "STU001",
  "grade": "Grade 10"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {...},
    "token": "1|aBcDeFgHiJkLmNoPqRsTuVwXyZ..."
  }
}
```

### Login
**POST** `/auth/login`

Authenticate and receive an access token.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {...},
    "student": {...},
    "token": "2|xYzAbCdEfGhIjKlMnOpQrStUv..."
  }
}
```

### Forgot Password
**POST** `/auth/forgot-password`

Request a password reset token (sent via email).

**Request Body:**
```json
{
  "email": "john@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset link has been sent to your email",
  "token": "abc123xyz" // Only in development mode
}
```

**Email Sent:** Professional HTML email with reset token (expires in 60 minutes)

### Reset Password
**POST** `/auth/reset-password`

Reset password using the token received via email.

**Request Body:**
```json
{
  "email": "john@example.com",
  "token": "abc123xyz",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

### Change Password (Authenticated)
**POST** `/auth/change-password`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "current_password": "oldpassword",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

### Logout
**POST** `/auth/logout`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

## Profile Management

### Upload Profile Photo
**POST** `/auth/upload-profile-photo`

**Headers:** `Authorization: Bearer {token}`

**Request Body:** `multipart/form-data`
- `profile_photo`: Image file (JPEG, PNG, JPG, GIF, max 2MB)

**Response:**
```json
{
  "success": true,
  "message": "Profile photo uploaded successfully",
  "data": {
    "profile_photo": "profile_photos/profile_1_1234567890.jpg",
    "profile_photo_url": "http://your-domain.com/storage/profile_photos/profile_1_1234567890.jpg"
  }
}
```

**Features:**
- Automatic deletion of old profile photos
- File validation (image types only, max 2MB)
- Activity logging
- Accessible via `$user->profile_photo_url`

### Update Profile
**POST** `/auth/update-profile`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "name": "John Updated Doe",
  "phone": "+94779876543",
  "address": "123 Main Street, Colombo"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "user": {...}
  }
}
```

### Delete Profile Photo
**DELETE** `/auth/delete-profile-photo`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "message": "Profile photo deleted successfully"
}
```

## Dashboard APIs

### Get Dashboard Statistics
**GET** `/dashboard/stats`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "total_classes": 5,
    "attendance_percentage": 85.5,
    "payment_status": "paid",
    "pending_amount": 0,
    "total_students": 150,
    "total_teachers": 12
  }
}
```

### Get Recent Activities
**GET** `/dashboard/recent-activities`

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "attendance",
      "title": "Attendance Marked",
      "description": "Mathematics - Present",
      "timestamp": "2025-11-17 10:30:00",
      "time_ago": "2 hours ago"
    }
  ]
}
```

## Report APIs

All report endpoints require admin role and authentication.

**Base Prefix:** `/reports`

**Headers:** `Authorization: Bearer {token}`

### Attendance Report
**GET** `/reports/attendance`

**Query Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD
- `class_id` (optional): Filter by class
- `student_id` (optional): Filter by student

**Response:**
```json
{
  "success": true,
  "data": {
    "attendances": [...],
    "statistics": {
      "total_records": 100,
      "present": 85,
      "absent": 10,
      "late": 5,
      "attendance_rate": 85.00
    }
  }
}
```

### Payment Report
**GET** `/reports/payments`

**Query Parameters:**
- `start_date` (optional): YYYY-MM-DD
- `end_date` (optional): YYYY-MM-DD
- `month` (optional): Payment month
- `year` (optional): Payment year
- `status` (optional): paid, pending, overdue

**Response:**
```json
{
  "success": true,
  "data": {
    "payments": [...],
    "statistics": {
      "total_amount": 150000,
      "paid_amount": 120000,
      "pending_amount": 20000,
      "overdue_amount": 10000,
      "total_count": 50,
      "paid_count": 40,
      "pending_count": 7,
      "overdue_count": 3
    }
  }
}
```

## PDF Export APIs

All PDF endpoints require admin role and authentication.

**Base Prefix:** `/reports/export`

**Headers:** `Authorization: Bearer {token}`

### Export Attendance Report PDF
**GET** `/reports/export/attendance-pdf`

**Query Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD
- `class_id` (optional)
- `student_id` (optional)

**Response:** PDF file download

**Filename:** `attendance_report_YYYY-MM-DD.pdf`

### Export Payment Report PDF
**GET** `/reports/export/payments-pdf`

**Query Parameters:**
- `start_date` (optional): YYYY-MM-DD
- `end_date` (optional): YYYY-MM-DD
- `month` (optional)
- `year` (optional)
- `status` (optional)

**Response:** PDF file download

**Filename:** `payment_report_YYYY-MM-DD.pdf`

### Export Monthly Summary PDF
**GET** `/reports/export/monthly-summary-pdf`

**Query Parameters:**
- `month` (required): 1-12
- `year` (required): YYYY

**Response:** PDF file download

**Filename:** `monthly_summary_YYYY-MM.pdf`

**Contents:**
- Attendance Summary (total, present, absent, late, rate)
- Payment Summary (total, paid, pending, overdue, collection rate)
- Institute information
- Generation timestamp

## Background Jobs

### SendPaymentReminderJob

**Purpose:** Automatically send payment reminders and overdue notices

**Schedule:** Recommended to run daily via cron

**Features:**
- Sends reminders 3 days before due date
- Sends overdue notices for past-due payments
- Automatically updates payment status to 'overdue'
- Uses professional email templates
- Comprehensive logging

**Manual Dispatch:**
```php
use App\Jobs\SendPaymentReminderJob;

SendPaymentReminderJob::dispatch();
```

**Laravel Scheduler (app/Console/Kernel.php):**
```php
protected function schedule(Schedule $schedule)
{
    $schedule->job(new SendPaymentReminderJob)->daily();
}
```

### GenerateMonthlyReportJob

**Purpose:** Generate comprehensive monthly reports for institutes

**Schedule:** Recommended to run on the 1st of each month

**Features:**
- Attendance statistics
- Payment collection statistics
- Student enrollment statistics
- Teacher statistics
- Grade/performance statistics
- Professional email with all stats
- Sent to institute owners

**Manual Dispatch:**
```php
use App\Jobs\GenerateMonthlyReportJob;

// For previous month, all institutes
GenerateMonthlyReportJob::dispatch();

// For specific month and institute
GenerateMonthlyReportJob::dispatch(11, 2025, 1);
```

**Laravel Scheduler:**
```php
protected function schedule(Schedule $schedule)
{
    $schedule->job(new GenerateMonthlyReportJob)
        ->monthlyOn(1, '08:00');
}
```

## Email System

All emails use professional Laravel Mailable classes with Markdown templates.

### Email Templates

1. **PaymentReminderMail**
   - Sent 3 days before payment due date
   - Shows amount, due date, payment month
   - Friendly reminder tone

2. **PaymentOverdueMail**
   - Sent for overdue payments
   - Urgent notice with days overdue
   - Warning about access restrictions

3. **MonthlyReportMail**
   - Comprehensive monthly statistics
   - Attendance summary
   - Payment summary
   - Student and teacher counts
   - Grade statistics

4. **PasswordResetMail**
   - Secure password reset with token
   - 60-minute expiry notice
   - Step-by-step instructions

5. **WelcomeStudentMail**
   - New student onboarding
   - Account details (email, student ID)
   - Temporary password (if provided)
   - App download links
   - Feature list

6. **WelcomeTeacherMail**
   - New teacher onboarding
   - Account details (email, employee ID, subject)
   - Temporary password (if provided)
   - App features and responsibilities

### Email Configuration

Ensure your `.env` file has proper mail configuration:

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@tutionms.com
MAIL_FROM_NAME="Tuition Management System"
```

### Queue Configuration

For production, use queue drivers for better performance:

```env
QUEUE_CONNECTION=database
```

Run queue worker:
```bash
php artisan queue:work
```

## Error Responses

All API endpoints return consistent error responses:

### Validation Error (422)
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

### Authentication Error (401)
```json
{
  "success": false,
  "message": "Unauthenticated"
}
```

### Authorization Error (403)
```json
{
  "success": false,
  "message": "You do not have permission to perform this action"
}
```

### Not Found Error (404)
```json
{
  "success": false,
  "message": "Resource not found"
}
```

### Server Error (500)
```json
{
  "success": false,
  "message": "An error occurred",
  "error": "Error details..."
}
```

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- **Public endpoints:** 60 requests per minute
- **Authenticated endpoints:** 120 requests per minute

Rate limit headers are included in responses:
- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`
- `Retry-After` (when limit exceeded)

## Best Practices

1. **Always use HTTPS** in production
2. **Store tokens securely** (use secure storage in mobile apps)
3. **Refresh tokens** before they expire
4. **Handle errors gracefully** with proper user feedback
5. **Use appropriate HTTP methods** (GET, POST, PUT, DELETE)
6. **Validate input** on the client side before API calls
7. **Cache responses** where appropriate to reduce API calls
8. **Log errors** for debugging and monitoring

## Support

For API support or bug reports, please contact:
- Email: support@tutionms.com
- GitHub Issues: [Project Repository]

---

**Last Updated:** November 17, 2025
**API Version:** 1.0.0
**Laravel Version:** 11.x
