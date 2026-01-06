# Admin User Guide - Tuition Management System

## Table of Contents
1. [Getting Started](#getting-started)
2. [Dashboard Overview](#dashboard-overview)
3. [Student Management](#student-management)
4. [Teacher Management](#teacher-management)
5. [Class Management](#class-management)
6. [Payment Management](#payment-management)
7. [Attendance Management](#attendance-management)
8. [Reports & Analytics](#reports--analytics)
9. [RFID Card Management](#rfid-card-management)
10. [Institute Settings](#institute-settings)

---

## Getting Started

### Logging In

1. Open your web browser and navigate to your institute's management portal
2. Enter your admin email address
3. Enter your password
4. Click "Login"

**Forgot Password?**
- Click "Forgot Password" on the login screen
- Enter your email address
- Check your email for a password reset link (valid for 15 minutes)
- Click the link and enter your new password

### First Time Setup

After your first login, you should:

1. **Update Your Profile**
   - Click your name in the top-right corner
   - Select "Profile"
   - Update your contact information
   - Upload a profile photo (optional)

2. **Review Institute Information**
   - Navigate to "Settings" > "Institute Information"
   - Verify all details are correct
   - Update logo, contact information, and address if needed

3. **Create User Accounts**
   - Start by adding teachers
   - Then add students
   - Assign RFID cards as needed

---

## Dashboard Overview

The admin dashboard provides a real-time overview of your institute's operations.

### Key Metrics

**Student Statistics**
- Total Students: Number of registered students
- Active Students: Currently enrolled students
- Inactive Students: Suspended or withdrawn students

**Teacher Statistics**
- Total Teachers: All teaching staff
- Active Teachers: Currently teaching
- Subject Coverage: Teachers per subject

**Financial Overview**
- Monthly Revenue: Current month's collected payments
- Pending Payments: Outstanding payment amount
- Overdue Payments: Past-due payments requiring attention

**Today's Attendance**
- Present: Students who attended today
- Absent: Students who missed classes
- Late: Students who arrived late
- Attendance Rate: Overall percentage

### Quick Actions

Use the quick action buttons for common tasks:
- Add New Student
- Add New Teacher
- Create Class
- Record Payment
- Mark Attendance

---

## Student Management

### Adding a New Student

1. Navigate to "Students" in the main menu
2. Click "Add Student" button
3. Fill in the required information:

**Personal Information** (Required)
- Full Name
- Email Address (must be unique)
- Phone Number
- Student ID Number (auto-generated or manual)
- Grade/Class Level
- Date of Birth

**Parent/Guardian Information**
- Parent Name
- Parent Phone Number
- Parent Email (optional)

**Additional Information** (Optional)
- Residential Address
- Profile Photo
- Emergency Contact
- Medical Information

4. Set an initial password (minimum 12 characters)
5. Click "Save" to create the student account

**Best Practices:**
- Use a consistent student ID format (e.g., STU001, STU002)
- Verify email addresses are correct
- Take profile photos with a plain background
- Always fill in parent contact information

### Viewing Student Details

1. Go to "Students" list
2. Use the search bar to find a specific student
3. Click on the student's name to view their profile

**Student Profile Sections:**
- **Personal Info**: Basic details and contact information
- **Enrolled Classes**: List of classes the student is attending
- **Payment History**: All payments and pending amounts
- **Attendance Record**: Attendance percentage and history
- **RFID Card**: Assigned card details and gate access logs

### Editing Student Information

1. Open the student's profile
2. Click "Edit" button
3. Modify the necessary fields
4. Click "Save Changes"

**What You Can Edit:**
- Personal information (name, phone, address)
- Grade/class level
- Parent contact information
- Profile photo

**What You Cannot Edit:**
- Student ID number (permanent identifier)
- Creation date
- Historical payment and attendance records

### Managing Student Status

**Deactivating a Student:**
1. Open student profile
2. Click "Deactivate" button
3. Confirm the action
4. Student status changes to "Inactive"

**Effects of Deactivation:**
- Cannot log into the system
- Not counted in active student statistics
- RFID card access is disabled
- Can be reactivated at any time

**Reactivating a Student:**
1. Filter students by "Inactive" status
2. Open the student's profile
3. Click "Activate" button
4. Student can now access the system

### Deleting a Student

⚠️ **Warning:** Deletion is permanent and cannot be undone.

1. Open student profile
2. Click "Delete" button
3. Type "DELETE" to confirm
4. Click "Confirm Deletion"

**What Gets Deleted:**
- Student profile and user account
- Personal information
- RFID card assignments

**What Is Retained:**
- Historical payment records (for accounting)
- Historical attendance records (for reporting)
- Enrollment history (anonymized)

### Enrolling Students in Classes

1. Go to "Classes" menu
2. Select the class you want to manage
3. Click "Manage Enrollments"
4. Click "Add Students"
5. Search and select students to enroll
6. Click "Enroll Selected Students"

**Maximum Capacity:**
- Each class has a maximum student limit
- System prevents over-enrollment
- You'll see a warning if approaching capacity

---

## Teacher Management

### Adding a New Teacher

1. Navigate to "Teachers" in the main menu
2. Click "Add Teacher" button
3. Fill in the required information:

**Personal Information** (Required)
- Full Name
- Email Address (must be unique)
- Phone Number
- Subject Specialization
- Qualifications (degrees, certifications)
- Date of Birth

**Employment Information**
- Employee ID (auto-generated or manual)
- Join Date
- Teaching Experience (years)
- Salary Information (optional, confidential)

**Additional Information** (Optional)
- Residential Address
- Profile Photo
- Emergency Contact
- Bank Account Details (for payroll)

4. Set an initial password
5. Click "Save" to create the teacher account

### Assigning Classes to Teachers

1. Go to "Classes" menu
2. Click "Create New Class" or edit existing class
3. Select the teacher from the dropdown
4. Set class schedule and room
5. Save the class

**Each class must have:**
- One assigned teacher
- Subject and grade level
- Schedule (day and time)
- Room/location
- Maximum student capacity

### Viewing Teacher Performance

1. Open teacher's profile
2. View the "Performance" tab

**Metrics Available:**
- Classes Taught: Number of active classes
- Total Students: Students across all classes
- Average Attendance: Attendance rate in teacher's classes
- Payment Collection Rate: Percentage of students who paid

---

## Class Management

### Creating a New Class

1. Navigate to "Classes"
2. Click "Create Class"
3. Fill in class details:

**Basic Information**
- Subject (e.g., Mathematics, Science, English)
- Grade Level (e.g., Grade 10, A/L)
- Class Name (optional, e.g., "Advanced Math")

**Schedule**
- Day of Week (Monday-Sunday)
- Start Time (e.g., 4:00 PM)
- Duration (in minutes: 60, 90, 120, 180)

**Location**
- Room Number or Name
- Building (if multiple buildings)
- Capacity (maximum students)

**Financial**
- Monthly Class Fee
- Payment Due Date (day of month)

**Teacher Assignment**
- Select teacher from dropdown
- Only teachers qualified for the subject appear

4. Click "Create Class"

### Managing Class Enrollment

**Viewing Enrolled Students:**
1. Go to class details page
2. Click "Students" tab
3. View list of all enrolled students

**Enrollment Status:**
- Current enrollment vs. maximum capacity
- List of enrolled students with contact info
- Payment status for each student

**Removing a Student from Class:**
1. Open class details
2. Go to "Students" tab
3. Click "Remove" next to student's name
4. Confirm removal

**Note:** Removing a student from a class does NOT delete their account.

### Scheduling Changes

To change class schedule:
1. Open class details
2. Click "Edit Schedule"
3. Update day, time, or duration
4. Click "Save Changes"

**System will notify:**
- All enrolled students
- The assigned teacher
- Parents (via email and SMS)

---

## Payment Management

### Creating Payment Records

**Automatic Payment Generation:**
- System automatically generates monthly payments for all enrolled students
- Based on class fees and enrollment date
- Generated on the 1st of each month

**Manual Payment Creation:**
1. Go to "Payments" menu
2. Click "Create Payment"
3. Select student
4. Select class
5. Enter amount and due date
6. Click "Save"

### Recording Payments

When a student pays:

1. Go to "Payments" menu
2. Filter by "Pending" status
3. Find the student's payment
4. Click "Record Payment"
5. Select payment method:
   - Cash
   - Credit/Debit Card
   - Bank Transfer
   - Online Payment
6. Enter any remarks (optional)
7. Click "Confirm Payment"

**System automatically:**
- Updates payment status to "Paid"
- Records payment date and time
- Logs who received the payment
- Updates financial reports

### Viewing Payment History

**For All Students:**
1. Go to "Payments" > "Payment History"
2. Filter by:
   - Date range
   - Class
   - Payment status
   - Payment method

**For Individual Student:**
1. Open student profile
2. Click "Payments" tab
3. View complete payment history

### Handling Overdue Payments

**Identifying Overdue Payments:**
1. Go to "Payments" > "Overdue"
2. System shows all payments past due date
3. Sort by:
   - Days overdue
   - Amount
   - Student name

**Sending Payment Reminders:**
1. Select overdue payments
2. Click "Send Reminder"
3. System sends email to student and parents
4. Reminder includes:
   - Amount due
   - Days overdue
   - Payment instructions
   - Contact information

**System automatically sends:**
- Reminder 3 days before due date
- Overdue notice on due date
- Weekly reminders for overdue payments

### Payment Reports

Generate payment reports:

1. Go to "Reports" > "Financial Reports"
2. Select report type:
   - Monthly Revenue Report
   - Payment Collection Report
   - Overdue Payments Report
   - Payment Method Analysis
3. Set date range
4. Click "Generate Report"
5. Export as PDF or Excel

---

## Attendance Management

### Marking Daily Attendance

**Method 1: Class-Based Attendance**
1. Go to "Attendance" menu
2. Select today's date
3. Select the class
4. System shows all enrolled students
5. Mark each student as:
   - Present ✓
   - Absent ✗
   - Late ⏰
6. Add remarks if needed
7. Click "Save Attendance"

**Method 2: Student Search**
1. Go to "Attendance"
2. Use search bar to find student
3. Click "Mark Attendance"
4. Select status
5. Save

**Method 3: Bulk Import**
1. Go to "Attendance" > "Bulk Import"
2. Download the CSV template
3. Fill in attendance data
4. Upload the CSV file
5. Review and confirm

### Viewing Attendance Records

**Class Attendance Report:**
1. Go to "Attendance" > "Reports"
2. Select class
3. Choose date range
4. View attendance summary:
   - Total sessions
   - Present count
   - Absent count
   - Late count
   - Attendance percentage

**Student Attendance Report:**
1. Open student profile
2. Click "Attendance" tab
3. View monthly calendar with attendance marks
4. See attendance percentage

### RFID-Based Attendance

If using RFID gate access:

1. Students tap their RFID card at gate
2. System automatically marks attendance
3. Records entry time
4. Sends notification to parents
5. Updates attendance statistics

**Viewing RFID Logs:**
1. Go to "RFID" > "Gate Access Logs"
2. Filter by date, student, or gate
3. View detailed access history

---

## Reports & Analytics

### Dashboard Analytics

**Real-Time Metrics:**
- Current enrollment numbers
- Today's attendance rate
- This month's revenue
- Pending and overdue payments
- Class utilization rates

**Trend Analysis:**
- Student enrollment trends (last 6 months)
- Revenue trends
- Attendance trends
- Teacher performance trends

### Generate Custom Reports

1. Go to "Reports" menu
2. Select report type
3. Configure filters:
   - Date range
   - Classes
   - Students
   - Teachers
   - Payment status
4. Click "Generate Report"
5. Export options:
   - PDF (for printing)
   - Excel (for analysis)
   - CSV (for import)

### Available Reports

**Academic Reports:**
- Attendance Summary Report
- Student Performance Report
- Class Enrollment Report
- Teacher Schedule Report

**Financial Reports:**
- Monthly Revenue Report
- Payment Collection Report
- Overdue Payments Report
- Class-wise Revenue Report
- Payment Method Analysis

**Administrative Reports:**
- Student Demographics Report
- Teacher Qualifications Report
- RFID Access Log Report
- System Activity Log Report

### Automated Monthly Reports

System automatically generates and emails monthly reports:

**Sent To:** Institute owner/admin
**Sent On:** 1st of each month
**Contains:**
- Previous month's statistics
- Revenue summary
- Attendance summary
- Student enrollment changes
- Teacher statistics
- Comparison with previous months

---

## RFID Card Management

### Registering RFID Cards

1. Go to "RFID" > "Card Management"
2. Click "Register New Card"
3. Enter card UID (or scan card)
4. Assign to student
5. Click "Register"

**Card Status:**
- Active: Card works at gates
- Inactive: Card disabled
- Lost: Card reported missing
- Damaged: Card needs replacement

### Replacing Lost Cards

1. Open student profile
2. Go to "RFID Card" section
3. Click "Report Lost"
4. System deactivates old card
5. Register new card
6. Old card cannot be used

### Gate Access Configuration

1. Go to "RFID" > "Gate Settings"
2. Configure access rules:
   - Active hours (e.g., 6 AM - 10 PM)
   - Allowed days
   - Access restrictions
3. Save settings

**Access Notifications:**
- Real-time notifications when students enter/exit
- SMS to parents (optional)
- Email alerts for unauthorized access attempts

---

## Institute Settings

### Institute Information

Update your institute's information:

1. Go to "Settings" > "Institute Info"
2. Update:
   - Institute name
   - Address
   - Contact phone/email
   - Website
   - Logo
3. Save changes

### User Management

**Creating Admin Users:**
1. Go to "Settings" > "Users"
2. Click "Add Admin User"
3. Fill in details
4. Set permissions
5. Save

**Admin Permissions:**
- Full Access: All features
- Finance Only: Payments and reports
- Academic Only: Students, teachers, attendance
- Read Only: View-only access

### System Configuration

**Email Settings:**
- SMTP configuration
- Email templates
- Automated email schedules

**SMS Settings:**
- SMS gateway configuration
- SMS templates
- SMS credit balance

**Notification Settings:**
- Enable/disable notifications
- Configure notification channels
- Set notification schedules

---

## Best Practices

### Security

1. **Change your password regularly** (every 3 months)
2. **Never share your admin credentials**
3. **Log out when leaving your computer**
4. **Use strong passwords** (12+ characters, mixed case, numbers, symbols)
5. **Review activity logs regularly**

### Data Management

1. **Back up data regularly** (automatic backups run nightly)
2. **Verify information before deleting**
3. **Keep student records up to date**
4. **Archive old records** (students who graduated)

### Communication

1. **Respond to payment reminders promptly**
2. **Keep parents informed** of schedule changes
3. **Update contact information** immediately when changed
4. **Use system notifications** instead of manual calls

### Financial Management

1. **Record payments immediately**
2. **Reconcile accounts monthly**
3. **Follow up on overdue payments** within 7 days
4. **Generate financial reports** regularly
5. **Review payment trends** monthly

---

## Troubleshooting

### Common Issues

**Cannot Log In:**
- Verify email and password are correct
- Check Caps Lock is off
- Try password reset
- Contact system administrator

**Student Cannot Enroll in Class:**
- Check if class is at full capacity
- Verify student is active
- Ensure student meets grade requirements

**Payment Not Showing:**
- Check payment was saved successfully
- Verify correct student and class selected
- Refresh the page
- Check payment status filter

**RFID Card Not Working:**
- Verify card is registered
- Check card status is "Active"
- Ensure student account is active
- Test card registration

**Report Not Generating:**
- Check date range is valid
- Verify filters are correct
- Try smaller date range
- Contact support if issue persists

---

## Support & Help

### Getting Help

**In-App Help:**
- Click "?" icon in top-right corner
- Access contextual help on any page
- View video tutorials

**Contact Support:**
- Email: support@tuitionmanagement.com
- Phone: +94 11 234 5678
- Support Hours: Mon-Fri, 9 AM - 6 PM

**Knowledge Base:**
- Visit help.tuitionmanagement.com
- Search for articles
- Watch video tutorials
- Download user guides

### Training

**New Admin Training:**
- 2-hour comprehensive training session
- Hands-on practice with test data
- Q&A session
- Training materials provided

**Schedule Training:**
- Contact support to schedule
- Available online or on-site
- Group or individual sessions

---

**Version:** 1.0.0
**Last Updated:** 2026-01-06
**System:** Tuition Management System
