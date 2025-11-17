<?php

namespace App\Jobs;

use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use App\Mail\PaymentReminderMail;
use App\Mail\PaymentOverdueMail;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class SendPaymentReminderJob implements ShouldQueue
{
    use Queueable;

    public $timeout = 300; // 5 minutes
    public $tries = 3;

    /**
     * Create a new job instance.
     */
    public function __construct()
    {
        //
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        Log::info('Starting payment reminder job');

        // Find all pending/overdue payments that need reminders
        $today = Carbon::now();
        $reminderDate = $today->copy()->addDays(3); // Remind 3 days before due

        // Get pending payments with upcoming due dates
        $upcomingPayments = Payment::where('status', 'pending')
            ->whereDate('due_date', '<=', $reminderDate)
            ->whereDate('due_date', '>=', $today)
            ->with(['student.user', 'institute'])
            ->get();

        Log::info("Found {$upcomingPayments->count()} upcoming payments");

        foreach ($upcomingPayments as $payment) {
            try {
                $this->sendReminderEmail($payment);
            } catch (\Exception $e) {
                Log::error("Failed to send reminder for payment {$payment->id}: " . $e->getMessage());
            }
        }

        // Get overdue payments
        $overduePayments = Payment::where('status', 'pending')
            ->whereDate('due_date', '<', $today)
            ->with(['student.user', 'institute'])
            ->get();

        Log::info("Found {$overduePayments->count()} overdue payments");

        foreach ($overduePayments as $payment) {
            try {
                $this->sendOverdueEmail($payment);

                // Update payment status to overdue
                if ($payment->status !== 'overdue') {
                    $payment->update(['status' => 'overdue']);
                }
            } catch (\Exception $e) {
                Log::error("Failed to send overdue notice for payment {$payment->id}: " . $e->getMessage());
            }
        }

        Log::info('Payment reminder job completed');
    }

    /**
     * Send reminder email for upcoming payment
     */
    private function sendReminderEmail(Payment $payment): void
    {
        $student = $payment->student;
        $user = $student->user;

        if (!$user->email) {
            return;
        }

        Mail::to($user->email)->send(new PaymentReminderMail($payment));

        Log::info("Sent payment reminder to {$user->email} for payment {$payment->id}");
    }

    /**
     * Send overdue payment notification
     */
    private function sendOverdueEmail(Payment $payment): void
    {
        $student = $payment->student;
        $user = $student->user;

        if (!$user->email) {
            return;
        }

        Mail::to($user->email)->send(new PaymentOverdueMail($payment));

        Log::info("Sent overdue notice to {$user->email} for payment {$payment->id}");
    }
}
