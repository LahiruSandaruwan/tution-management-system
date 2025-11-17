import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/api_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GateMonitoringScreen extends ConsumerStatefulWidget {
  const GateMonitoringScreen({super.key});

  @override
  ConsumerState<GateMonitoringScreen> createState() => _GateMonitoringScreenState();
}

class _GateMonitoringScreenState extends ConsumerState<GateMonitoringScreen> {
  Map<String, dynamic>? _gateData;
  List<dynamic> _gateLogs = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadGateData();
    // Auto-refresh every 10 seconds to simulate live feed
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadGateData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGateData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiProvider);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final data = await apiService.getGateLogsReport(
        startDate: today,
        endDate: today,
      );

      setState(() {
        _gateData = data;
        _gateLogs = data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Gate Monitoring'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _loadGateData,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    title: 'Entries Today',
                    value: _gateData?['statistics']?['total_entries']?.toString() ?? '0',
                    icon: Icons.arrow_downward,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    title: 'Exits Today',
                    value: _gateData?['statistics']?['total_exits']?.toString() ?? '0',
                    icon: Icons.arrow_upward,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    title: 'Currently Inside',
                    value: _gateData?['statistics']?['currently_inside']?.toString() ?? '0',
                    icon: Icons.people,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    title: 'Access Denied',
                    value: _gateData?['statistics']?['denied_today']?.toString() ?? '0',
                    icon: Icons.block,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Live Feed
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.emergency_recording, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Live Activity Feed',
                            style: AppTheme.titleLarge,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, color: Colors.white, size: 8),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _gateLogs.isEmpty
                          ? _buildEmptyState()
                          : _buildActivityFeed(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(
                  value,
                  style: AppTheme.headingLarge.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sensors,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Activity Today',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gate logs will appear here as students enter or exit',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gateLogs.length,
      itemBuilder: (context, index) {
        final log = _gateLogs[index];
        final action = log['action']?.toString().toLowerCase() ?? 'entry';
        final isGranted = log['status']?.toString().toLowerCase() == 'granted';
        final timestamp = log['timestamp'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isGranted
              ? (action == 'entry'
                  ? AppTheme.successColor.withOpacity(0.05)
                  : AppTheme.primaryColor.withOpacity(0.05))
              : AppTheme.errorColor.withOpacity(0.05),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isGranted
                  ? (action == 'entry' ? AppTheme.successColor : AppTheme.primaryColor)
                  : AppTheme.errorColor,
              child: Icon(
                isGranted
                    ? (action == 'entry'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward)
                    : Icons.block,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              log['student_name']?.toString() ?? 'Unknown Student',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['student_id']?.toString() ?? 'N/A'),
                if (log['reason'] != null)
                  Text(
                    log['reason'].toString(),
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isGranted
                        ? (action == 'entry'
                            ? AppTheme.successColor
                            : AppTheme.primaryColor)
                        : AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isGranted
                        ? (action == 'entry' ? 'ENTRY' : 'EXIT')
                        : 'DENIED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp != null
                      ? DateFormat('HH:mm:ss').format(DateTime.parse(timestamp))
                      : 'N/A',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
