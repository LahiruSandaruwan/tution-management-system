# User Acceptance Testing (UAT) Checklist

**Estimated Time:** 2-3 hours
**Environment:** Staging (Pre-Production)
**Test Date:** __________
**Tester:** __________

---

## Overview

This checklist ensures all critical user workflows function correctly before production deployment. Test each scenario systematically and document any issues found.

---

## Test Environment Setup

### Prerequisites
- [ ] Staging environment deployed
- [ ] Database seeded with test data
- [ ] All services running (app, database, Redis, queue workers)
- [ ] Health checks passing
- [ ] Test user accounts created

### Test Users Required

Create these test accounts in staging:

```
Admin User:
Email: admin@test.com
Password: Admin@Test123

Teacher User:
Email: teacher@test.com
Password: Teacher@Test123

Student User:
Email: student@test.com
Password: Student@Test123
```

---

## 1. Authentication & Authorization Tests (15 minutes)

### 1.1 User Registration
- [ ] **Test:** Register new admin user
  - Navigate to registration page
  - Fill in: Name, Email, Password, Confirm Password
  - Select Institute
  - Submit form
  - **Expected:** Success message, redirected to dashboard
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Duplicate email registration
  - Try registering with existing email
  - **Expected:** Error message "Email already exists"
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Weak password validation
  - Try password < 12 characters
  - **Expected:** Validation error
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 1.2 User Login
- [ ] **Test:** Valid login (Admin)
  - Enter correct credentials
  - **Expected:** Successfully logged in, see dashboard
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Invalid password
  - Enter wrong password
  - **Expected:** Error message "Invalid credentials"
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Account lockout (5 failed attempts)
  - Attempt login with wrong password 5 times
  - **Expected:** Account locked for 15 minutes
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Locked account message
  - Try logging in while locked
  - **Expected:** Message showing remaining lockout time
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 1.3 Password Management
- [ ] **Test:** Forgot password
  - Click "Forgot Password"
  - Enter email
  - **Expected:** Email sent with reset link
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Reset password with valid token
  - Click reset link from email
  - Enter new password
  - **Expected:** Password updated, can login with new password
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Change password
  - Go to profile settings
  - Change password
  - **Expected:** Password updated successfully
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 1.4 Role-Based Access Control
- [ ] **Test:** Admin access to admin features
  - Login as admin
  - Try accessing: Students, Teachers, Classes, Payments
  - **Expected:** All accessible
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Teacher cannot access admin features
  - Login as teacher
  - Try accessing student management
  - **Expected:** Access denied (403)
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Student cannot access admin features
  - Login as student
  - Try accessing teacher management
  - **Expected:** Access denied (403)
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 2. Student Management Tests (20 minutes)

### 2.1 Create Student
- [ ] **Test:** Add new student
  - Navigate to Students → Add New
  - Fill in all fields:
    - Full Name
    - Date of Birth
    - Gender
    - Address
    - Phone
    - Emergency Contact
    - Grade
  - Upload profile photo
  - Submit
  - **Expected:** Student created, appears in list
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Required field validation
  - Try submitting without full name
  - **Expected:** Validation error
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 2.2 View Student
- [ ] **Test:** View student details
  - Click on student from list
  - **Expected:** See all student information
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** View student enrollments
  - Check enrolled classes section
  - **Expected:** List of enrolled classes
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** View payment history
  - Check payments section
  - **Expected:** List of all payments
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 2.3 Update Student
- [ ] **Test:** Edit student information
  - Update phone number
  - Change address
  - Update emergency contact
  - Save changes
  - **Expected:** Changes saved successfully
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Upload new profile photo
  - Change profile photo
  - **Expected:** New photo displayed
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 2.4 Delete Student
- [ ] **Test:** Delete student
  - Select student
  - Click delete
  - Confirm deletion
  - **Expected:** Student deleted, removed from list
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Cascade deletion
  - Verify student's enrollments deleted
  - Verify student's payments remain (archived)
  - **Expected:** Related data handled correctly
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 3. Teacher Management Tests (15 minutes)

### 3.1 Create Teacher
- [ ] **Test:** Add new teacher
  - Navigate to Teachers → Add New
  - Fill in: Name, Phone, Address, Subject, Qualifications
  - Set hire date
  - Submit
  - **Expected:** Teacher created successfully
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 3.2 View & Update Teacher
- [ ] **Test:** View teacher profile
  - Click on teacher
  - **Expected:** See full teacher details
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Update teacher details
  - Edit qualifications
  - Change phone number
  - **Expected:** Changes saved
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 3.3 Teacher Classes
- [ ] **Test:** View teacher's classes
  - Check assigned classes
  - **Expected:** List of all classes taught
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 4. Class Management Tests (20 minutes)

### 4.1 Create Class
- [ ] **Test:** Create new class
  - Navigate to Classes → Add New
  - Fill in:
    - Class Name
    - Subject
    - Grade
    - Teacher
    - Monthly Fee
    - Max Students
    - Schedule (Day, Start Time, End Time)
  - Submit
  - **Expected:** Class created successfully
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 4.2 Student Enrollment
- [ ] **Test:** Enroll student in class
  - Go to class details
  - Click "Enroll Student"
  - Select student
  - Confirm
  - **Expected:** Student enrolled, appears in class roster
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Max students limit
  - Try enrolling when class is full
  - **Expected:** Error message "Class is full"
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Remove student from class
  - Select enrolled student
  - Click remove
  - Confirm
  - **Expected:** Student removed from class
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 4.3 Class Schedule
- [ ] **Test:** View class schedule
  - Navigate to schedule
  - **Expected:** See all classes by day/time
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Schedule conflict detection
  - Try creating overlapping class for same teacher
  - **Expected:** Warning about schedule conflict
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 5. Payment Management Tests (20 minutes)

### 5.1 Record Payment
- [ ] **Test:** Add payment for student
  - Navigate to Payments → Add New
  - Select student
  - Enter amount
  - Select payment method (Cash/Bank Transfer/Card)
  - Select month/year
  - Add description
  - Submit
  - **Expected:** Payment recorded successfully
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 5.2 View Payments
- [ ] **Test:** View all payments
  - Navigate to Payments
  - **Expected:** List of all payments
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Filter payments by status
  - Filter: Paid, Pending, Overdue
  - **Expected:** Filtered results correct
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Search payments
  - Search by student name
  - **Expected:** Relevant payments shown
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 5.3 Payment Reports
- [ ] **Test:** Generate monthly payment report
  - Select month
  - Generate report
  - **Expected:** PDF report downloaded
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** View defaulters list
  - Navigate to Defaulters
  - **Expected:** List of students with pending payments
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 6. RFID & Gate Access Tests (15 minutes)

### 6.1 RFID Card Management
- [ ] **Test:** Assign RFID card to student
  - Go to RFID Cards → Add New
  - Enter RFID number
  - Select student
  - Set issue date
  - Activate card
  - **Expected:** Card assigned successfully
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 6.2 Gate Verification
- [ ] **Test:** Verify RFID card (API test)
  - Send POST request to `/api/gate/verify`
  - Include RFID number
  - **Expected:** Student information returned
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Invalid RFID verification
  - Try with non-existent RFID
  - **Expected:** Error "Card not found"
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 6.3 Gate Logs
- [ ] **Test:** View gate access logs
  - Navigate to Reports → Gate Logs
  - **Expected:** List of all gate access events
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Filter logs by date
  - Select date range
  - **Expected:** Filtered logs shown
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 7. Dashboard & Analytics Tests (10 minutes)

### 7.1 Admin Dashboard
- [ ] **Test:** View dashboard statistics
  - Login as admin
  - Check dashboard shows:
    - Total students
    - Total teachers
    - Total classes
    - Monthly revenue
    - Recent activities
  - **Expected:** All statistics display correctly
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 7.2 Charts & Graphs
- [ ] **Test:** Revenue chart
  - Check monthly revenue graph
  - **Expected:** Chart displays with data
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Student enrollment trends
  - Check enrollment chart
  - **Expected:** Trend line shows enrollment over time
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 8. GDPR Compliance Tests (10 minutes)

### 8.1 Data Export
- [ ] **Test:** Export user data
  - Login as student
  - Navigate to Settings → Privacy
  - Click "Export My Data"
  - **Expected:** JSON file downloaded with all user data
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Verify exported data completeness
  - Check JSON contains:
    - User account info
    - Profile data
    - Enrollments
    - Payments
    - Authentication history
  - **Expected:** All data present
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 8.2 Account Deletion
- [ ] **Test:** Delete user account
  - Login as test user
  - Go to Settings → Privacy
  - Click "Delete Account"
  - Enter password
  - Type "DELETE_MY_ACCOUNT"
  - Confirm
  - **Expected:** Account deleted, cannot login
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Verify cascade deletion
  - Check database that all related data deleted
  - **Expected:** User and related data removed
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 9. Performance Tests (10 minutes)

### 9.1 Page Load Times
- [ ] **Test:** Dashboard load time
  - Measure with browser DevTools
  - **Expected:** < 2 seconds
  - **Actual:** _____________ ms
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Student list load time
  - Load students page (with 50+ students)
  - **Expected:** < 3 seconds
  - **Actual:** _____________ ms
  - **Status:** ☐ Pass ☐ Fail

---

### 9.2 API Response Times
- [ ] **Test:** Login API
  - Measure API response time
  - **Expected:** < 500ms
  - **Actual:** _____________ ms
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Health check API
  - Call `/api/health/detailed`
  - **Expected:** < 200ms
  - **Actual:** _____________ ms
  - **Status:** ☐ Pass ☐ Fail

---

## 10. Security Tests (15 minutes)

### 10.1 HTTPS/SSL
- [ ] **Test:** HTTPS enforcement
  - Try accessing via HTTP
  - **Expected:** Redirected to HTTPS
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** SSL certificate valid
  - Check certificate in browser
  - **Expected:** Valid certificate, no warnings
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 10.2 XSS Protection
- [ ] **Test:** Input sanitization
  - Try entering `<script>alert('XSS')</script>` in name field
  - **Expected:** Sanitized, script not executed
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 10.3 CSRF Protection
- [ ] **Test:** CSRF token validation
  - Submit form without CSRF token
  - **Expected:** Request rejected
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 10.4 SQL Injection
- [ ] **Test:** SQL injection prevention
  - Try entering `' OR '1'='1` in email field
  - **Expected:** Treated as literal string, no injection
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## 11. Mobile Responsiveness (10 minutes)

### 11.1 Mobile View
- [ ] **Test:** Dashboard on mobile (375px width)
  - Resize browser or use device
  - **Expected:** Layout adapts, all elements visible
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

- [ ] **Test:** Forms on mobile
  - Try filling student form on mobile
  - **Expected:** Easy to use, no horizontal scroll
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

### 11.2 Tablet View
- [ ] **Test:** Dashboard on tablet (768px width)
  - **Expected:** Optimal layout for tablet
  - **Actual:** _____________
  - **Status:** ☐ Pass ☐ Fail

---

## Test Results Summary

### Statistics

- **Total Tests:** ___ / 60
- **Passed:** ___ (___%)
- **Failed:** ___ (___%)
- **Blocked:** ___

### Critical Issues Found

| # | Issue Description | Severity | Status |
|---|-------------------|----------|--------|
| 1 | | ☐ Critical ☐ High ☐ Medium ☐ Low | ☐ Open ☐ Fixed |
| 2 | | ☐ Critical ☐ High ☐ Medium ☐ Low | ☐ Open ☐ Fixed |
| 3 | | ☐ Critical ☐ High ☐ Medium ☐ Low | ☐ Open ☐ Fixed |

### Recommendations

**Proceed to Production:**
- ☐ Yes - All critical tests passed
- ☐ No - Critical issues must be fixed
- ☐ Conditional - Fix issues then re-test

**Comments:**
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________

---

## Sign-Off

**Tester Name:** _____________________
**Date:** _____________________
**Signature:** _____________________

**QA Lead Approval:** _____________________
**Date:** _____________________

**Product Owner Approval:** _____________________
**Date:** _____________________

---

**Test Duration:** _____ hours
**Environment:** Staging
**Next Steps:** ☐ Fix issues ☐ Re-test ☐ Deploy to production

---

**Document Version:** 1.0
**Last Updated:** 2026-01-10
