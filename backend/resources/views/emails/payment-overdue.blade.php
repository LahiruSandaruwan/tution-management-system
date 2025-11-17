<x-mail::message>
# ⚠️ OVERDUE Payment Notice

Dear {{ $studentName }},

Your payment is now **OVERDUE by {{ $daysOverdue }} day(s)**.

<x-mail::panel>
## Payment Details

- **Amount:** Rs. {{ number_format($payment->amount, 2) }}
- **Due Date:** {{ \Carbon\Carbon::parse($payment->due_date)->format('F j, Y') }}
- **Month:** {{ $payment->payment_month }}
- **Current Status:** OVERDUE
- **Days Overdue:** {{ $daysOverdue }} day(s)
</x-mail::panel>

## Immediate Action Required

Please settle this payment immediately to continue accessing our services.

**Important Notice:** Your access may be restricted until payment is received. Late fees may apply for overdue payments.

@if($payment->description)
**Payment Note:** {{ $payment->description }}
@endif

## Payment Instructions

Please contact the institute administration for payment options and methods.

If you have already made the payment, please disregard this notice and contact us with your payment confirmation.

Best regards,<br>
**{{ $instituteName }}**

---
*This is an automated reminder. If you need assistance, please contact the institute directly.*
</x-mail::message>
