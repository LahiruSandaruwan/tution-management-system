<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Monthly Summary Report</title>
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
        .section {
            margin: 20px 0;
        }
        .section-title {
            background-color: #4A5568;
            color: white;
            padding: 10px;
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 15px;
        }
        .stats-grid {
            display: table;
            width: 100%;
            margin-bottom: 20px;
        }
        .stat-item {
            display: table-cell;
            padding: 15px;
            border: 1px solid #E2E8F0;
            text-align: center;
            width: 25%;
        }
        .stat-label {
            font-size: 11px;
            color: #718096;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 18px;
            font-weight: bold;
            color: #2D3748;
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
        <h2>Monthly Summary Report</h2>
        <p style="color: #718096;">{{ $month }}</p>
    </div>

    <div class="info-section">
        <p><strong>Institute:</strong> {{ $institute->name }}</p>
        <p><strong>Report Period:</strong> {{ $month }}</p>
        <p><strong>Generated:</strong> {{ $generated_at }}</p>
    </div>

    <div class="section">
        <div class="section-title">ATTENDANCE SUMMARY</div>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-label">Total Records</div>
                <div class="stat-value">{{ $attendance_stats['total_records'] }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Present</div>
                <div class="stat-value" style="color: #38A169;">{{ $attendance_stats['present'] }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Absent</div>
                <div class="stat-value" style="color: #E53E3E;">{{ $attendance_stats['absent'] }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Late</div>
                <div class="stat-value" style="color: #DD6B20;">{{ $attendance_stats['late'] }}</div>
            </div>
        </div>
        <div style="text-align: center; padding: 10px; background-color: #F7FAFC; margin-top: 10px;">
            <strong>Attendance Rate:</strong> <span style="font-size: 18px; color: #3182CE;">{{ $attendance_stats['attendance_rate'] }}%</span>
        </div>
    </div>

    <div class="section">
        <div class="section-title">PAYMENT SUMMARY</div>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-label">Total Amount</div>
                <div class="stat-value">Rs. {{ number_format($payment_stats['total_amount'], 2) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Paid</div>
                <div class="stat-value" style="color: #38A169;">Rs. {{ number_format($payment_stats['paid_amount'], 2) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Pending</div>
                <div class="stat-value" style="color: #DD6B20;">Rs. {{ number_format($payment_stats['pending_amount'], 2) }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Overdue</div>
                <div class="stat-value" style="color: #E53E3E;">Rs. {{ number_format($payment_stats['overdue_amount'], 2) }}</div>
            </div>
        </div>
        <div style="margin-top: 15px;">
            <div style="background-color: #F7FAFC; padding: 10px;">
                <strong>Payment Count:</strong> {{ $payment_stats['paid_count'] }} / {{ $payment_stats['total_count'] }} paid
            </div>
            <div style="text-align: center; padding: 10px; background-color: #EDF2F7; margin-top: 5px;">
                <strong>Collection Rate:</strong> <span style="font-size: 18px; color: #3182CE;">{{ $payment_stats['collection_rate'] }}%</span>
            </div>
        </div>
    </div>

    <div class="footer">
        <p>Tuition Management System - Automated Report Generation</p>
        <p>This report was automatically generated on {{ $generated_at }}</p>
    </div>
</body>
</html>
