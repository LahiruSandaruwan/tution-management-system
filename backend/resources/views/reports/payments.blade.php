<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Payment Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.6;
            color: #333;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #4A5568;
            padding-bottom: 20px;
        }
        .header h1 {
            color: #2D3748;
            margin: 0;
            font-size: 24px;
        }
        .header h2 {
            color: #4A5568;
            margin: 5px 0;
            font-size: 18px;
            font-weight: normal;
        }
        .info-section {
            margin-bottom: 20px;
        }
        .info-section p {
            margin: 5px 0;
        }
        .stats-section {
            background-color: #F7FAFC;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
        }
        .stats-grid {
            display: table;
            width: 100%;
            margin-top: 10px;
        }
        .stat-item {
            display: table-cell;
            padding: 10px;
            text-align: center;
            width: 25%;
        }
        .stat-label {
            font-size: 10px;
            color: #718096;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 16px;
            font-weight: bold;
            color: #2D3748;
        }
        .payment-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .payment-table th {
            background-color: #4A5568;
            color: white;
            padding: 10px;
            text-align: left;
            font-size: 11px;
        }
        .payment-table td {
            padding: 8px;
            border-bottom: 1px solid #E2E8F0;
            font-size: 11px;
        }
        .payment-table tr:nth-child(even) {
            background-color: #F7FAFC;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            display: inline-block;
        }
        .status-paid {
            background-color: #C6F6D5;
            color: #22543D;
        }
        .status-pending {
            background-color: #FED7AA;
            color: #7C2D12;
        }
        .status-overdue {
            background-color: #FED7D7;
            color: #742A2A;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #E2E8F0;
            text-align: center;
            font-size: 10px;
            color: #718096;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ $institute->name }}</h1>
        <h2>Payment Report</h2>
        @if(isset($filters['month']) || isset($filters['year']))
            <p style="color: #718096;">
                @if(isset($filters['month']) && isset($filters['year']))
                    {{ \Carbon\Carbon::createFromFormat('Y-m', $filters['year'] . '-' . $filters['month'])->format('F Y') }}
                @elseif(isset($filters['year']))
                    Year {{ $filters['year'] }}
                @endif
            </p>
        @elseif(isset($filters['start_date']) && isset($filters['end_date']))
            <p style="color: #718096;">{{ \Carbon\Carbon::parse($filters['start_date'])->format('F j, Y') }} - {{ \Carbon\Carbon::parse($filters['end_date'])->format('F j, Y') }}</p>
        @endif
    </div>

    <div class="info-section">
        <p><strong>Institute:</strong> {{ $institute->name }}</p>
        @if(isset($filters['start_date']) && isset($filters['end_date']))
            <p><strong>Report Period:</strong> {{ \Carbon\Carbon::parse($filters['start_date'])->format('F j, Y') }} - {{ \Carbon\Carbon::parse($filters['end_date'])->format('F j, Y') }}</p>
        @endif
        @if(isset($filters['status']))
            <p><strong>Status Filter:</strong> {{ ucfirst($filters['status']) }}</p>
        @endif
        <p><strong>Generated:</strong> {{ $generated_at }}</p>
        <p><strong>Total Payments:</strong> {{ $stats['total_count'] }}</p>
    </div>

    <div class="stats-section">
        <strong>Payment Summary</strong>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-label">Total Amount</div>
                <div class="stat-value">Rs. {{ number_format($stats['total_amount'], 2) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Paid</div>
                <div class="stat-value" style="color: #38A169;">Rs. {{ number_format($stats['paid_amount'], 2) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Pending</div>
                <div class="stat-value" style="color: #DD6B20;">Rs. {{ number_format($stats['pending_amount'], 2) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Overdue</div>
                <div class="stat-value" style="color: #E53E3E;">Rs. {{ number_format($stats['overdue_amount'], 2) }}</div>
            </div>
        </div>
        <div style="margin-top: 10px; display: table; width: 100%;">
            <div style="display: table-cell; width: 50%; padding: 10px; text-align: center;">
                <strong>Payment Count:</strong> {{ $stats['paid_count'] }} / {{ $stats['total_count'] }} paid
            </div>
            <div style="display: table-cell; width: 50%; padding: 10px; text-align: center;">
                <strong>Collection Rate:</strong>
                <span style="font-size: 16px; color: #3182CE;">
                    {{ $stats['total_amount'] > 0 ? round(($stats['paid_amount'] / $stats['total_amount']) * 100, 2) : 0 }}%
                </span>
            </div>
        </div>
    </div>

    <table class="payment-table">
        <thead>
            <tr>
                <th>Student</th>
                <th>Month</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Payment Date</th>
                <th>Due Date</th>
                <th>Receipt</th>
            </tr>
        </thead>
        <tbody>
            @forelse($payments as $payment)
                <tr>
                    <td>{{ $payment->student->user->name ?? 'N/A' }}</td>
                    <td>{{ \Carbon\Carbon::createFromFormat('Y-m', $payment->year . '-' . (strlen($payment->month) == 1 ? '0' . $payment->month : $payment->month))->format('M Y') }}</td>
                    <td>Rs. {{ number_format($payment->amount, 2) }}</td>
                    <td>
                        <span class="status-badge status-{{ $payment->status }}">
                            {{ ucfirst($payment->status) }}
                        </span>
                    </td>
                    <td>{{ $payment->payment_date ? \Carbon\Carbon::parse($payment->payment_date)->format('M j, Y') : '-' }}</td>
                    <td>{{ $payment->due_date ? \Carbon\Carbon::parse($payment->due_date)->format('M j, Y') : '-' }}</td>
                    <td style="font-family: monospace; font-size: 9px;">{{ $payment->receipt_number ?? '-' }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" style="text-align: center; padding: 20px; color: #718096;">
                        No payment records found for this period.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        <p>Tuition Management System - Automated Report Generation</p>
        <p>This report was automatically generated on {{ $generated_at }}</p>
    </div>
</body>
</html>
