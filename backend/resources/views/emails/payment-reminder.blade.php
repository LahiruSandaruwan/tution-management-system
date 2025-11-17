<x-mail::message>
# Payment Reminder

Dear {{ $studentName }},

This is a friendly reminder that your payment is due in **{{ $daysUntilDue }} day(s)**.

<x-mail::panel>
## Payment Details

- **Amount:** Rs. {{ number_format($payment->amount, 2) }}
- **Due Date:** {{ \Carbon\Carbon::parse($payment->due_date)->format('F j, Y') }}
- **Month:** {{ $payment->payment_month }}
- **Status:** {{ ucfirst($payment->status) }}
</x-mail::panel>

Please make the payment before the due date to avoid any inconvenience.

@if($payment->description)
**Note:** {{ $payment->description }}
@endif

Thank you for your cooperation.

Best regards,<br>
**{{ $instituteName }}**
</x-mail::message>
