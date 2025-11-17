<?php

namespace App\Mail;

use App\Models\Teacher;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WelcomeTeacherMail extends Mailable
{
    use Queueable, SerializesModels;

    public $teacher;
    public $teacherName;
    public $instituteName;
    public $email;
    public $temporaryPassword;

    /**
     * Create a new message instance.
     */
    public function __construct(Teacher $teacher, string $temporaryPassword = null)
    {
        $this->teacher = $teacher;
        $this->teacherName = $teacher->user->name;
        $this->instituteName = $teacher->institute->name;
        $this->email = $teacher->user->email;
        $this->temporaryPassword = $temporaryPassword;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: "Welcome to {$this->instituteName} - Teacher Account",
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            markdown: 'emails.welcome-teacher',
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
