import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GenerateMonthlyDialog extends StatefulWidget {
  final Function(String month, int year) onGenerate;

  const GenerateMonthlyDialog({
    super.key,
    required this.onGenerate,
  });

  @override
  State<GenerateMonthlyDialog> createState() => _GenerateMonthlyDialogState();
}

class _GenerateMonthlyDialogState extends State<GenerateMonthlyDialog> {
  String _selectedMonth = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ][DateTime.now().month - 1];
  int _selectedYear = DateTime.now().year;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          const Text('Generate Monthly Payments'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This will generate payment records for all active students for the selected month. '
            'Existing payments will not be affected.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedMonth,
            decoration: const InputDecoration(
              labelText: 'Month',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            items: [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ].map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedMonth = value!);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: const InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_month),
            ),
            items: List.generate(3, (index) {
              final year = DateTime.now().year + (1 - index);
              return DropdownMenuItem(
                value: year,
                child: Text('$year'),
              );
            }),
            onChanged: (value) {
              setState(() => _selectedYear = value!);
            },
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            side: BorderSide(color: Colors.grey[400]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _handleGenerate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.generating_tokens),
          label: const Text(
            'Generate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleGenerate() async {
    setState(() => _isSubmitting = true);
    await widget.onGenerate(_selectedMonth, _selectedYear);
    setState(() => _isSubmitting = false);
  }
}
