<x-mail::message>
# Monthly Report - {{ $month }}

Dear {{ $institute->owner->name }},

Here is the comprehensive monthly report for **{{ $institute->name }}**.

---

## 📊 Attendance Summary

<x-mail::panel>
- **Total Records:** {{ $reportData['attendance']['total_records'] }}
- **Present:** {{ $reportData['attendance']['present'] }}
- **Absent:** {{ $reportData['attendance']['absent'] }}
- **Late:** {{ $reportData['attendance']['late'] }}
- **Attendance Rate:** {{ $reportData['attendance']['attendance_rate'] }}%
</x-mail::panel>

---

## 💰 Payment Summary

<x-mail::panel>
- **Total Payments:** {{ $reportData['payments']['total_payments'] }}
- **Paid Payments:** {{ $reportData['payments']['paid_payments'] }}
- **Total Amount:** Rs. {{ number_format($reportData['payments']['total_amount'], 2) }}
- **Paid Amount:** Rs. {{ number_format($reportData['payments']['paid_amount'], 2) }}
- **Pending Amount:** Rs. {{ number_format($reportData['payments']['pending_amount'], 2) }}
- **Overdue Amount:** Rs. {{ number_format($reportData['payments']['overdue_amount'], 2) }}
- **Collection Rate:** {{ $reportData['payments']['collection_rate'] }}%
</x-mail::panel>

---

## 👨‍🎓 Student Summary

<x-mail::panel>
- **Total Active Students:** {{ $reportData['students']['total_active'] }}
- **New Enrollments:** {{ $reportData['students']['new_enrollments'] }}
- **Became Inactive:** {{ $reportData['students']['inactive'] }}
</x-mail::panel>

---

## 👨‍🏫 Teacher Summary

<x-mail::panel>
- **Total Active Teachers:** {{ $reportData['teachers']['total_active'] }}
</x-mail::panel>

---

## 📚 Grade Summary

<x-mail::panel>
- **Total Grades Recorded:** {{ $reportData['grades']['total_grades'] }}
- **Average Grade:** {{ $reportData['grades']['average_grade'] }}%
- **Top Performers (≥75%):** {{ $reportData['grades']['top_performers'] }}
</x-mail::panel>

---

*Generated on {{ \Carbon\Carbon::now()->format('F j, Y g:i A') }}*

Thank you for using our Tuition Management System.

Best regards,<br>
**Tuition Management System**
</x-mail::message>
