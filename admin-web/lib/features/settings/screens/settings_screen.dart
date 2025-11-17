import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _itemsPerPage = prefs.getInt('items_per_page') ?? 20;
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Appearance Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.palette_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Appearance',
                              style: AppTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        ListTile(
                          leading: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                            color: AppTheme.primaryColor,
                          ),
                          title: const Text('Dark Mode'),
                          subtitle: Text(
                            isDarkMode
                                ? 'Dark mode is enabled'
                                : 'Light mode is enabled',
                          ),
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (_) {
                              ref.read(themeModeProvider.notifier).toggleTheme();
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notification Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Notifications',
                              style: AppTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        SwitchListTile(
                          secondary: const Icon(Icons.email_outlined),
                          title: const Text('Email Notifications'),
                          subtitle: const Text(
                            'Receive notifications via email',
                          ),
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                            _savePreference('email_notifications', value);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_active_outlined),
                          title: const Text('Push Notifications'),
                          subtitle: const Text(
                            'Receive push notifications in-app',
                          ),
                          value: _pushNotifications,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                            _savePreference('push_notifications', value);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        SwitchListTile(
                          secondary: const Icon(Icons.volume_up_outlined),
                          title: const Text('Sound'),
                          subtitle: const Text(
                            'Play sound for notifications',
                          ),
                          value: _soundEnabled,
                          onChanged: (value) {
                            setState(() => _soundEnabled = value);
                            _savePreference('sound_enabled', value);
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.display_settings_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Display Settings',
                              style: AppTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        ListTile(
                          leading: const Icon(Icons.table_rows_outlined),
                          title: const Text('Items Per Page'),
                          subtitle: Text('Show $_itemsPerPage items per page'),
                          trailing: DropdownButton<int>(
                            value: _itemsPerPage,
                            items: const [
                              DropdownMenuItem(value: 10, child: Text('10')),
                              DropdownMenuItem(value: 20, child: Text('20')),
                              DropdownMenuItem(value: 50, child: Text('50')),
                              DropdownMenuItem(value: 100, child: Text('100')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _itemsPerPage = value);
                                _savePreference('items_per_page', value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Account Information',
                              style: AppTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoRow('Name', user?.name ?? 'N/A'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Email', user?.email ?? 'N/A'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Role', user?.role ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // System Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.settings_outlined,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'System Information',
                              style: AppTheme.titleLarge,
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _buildInfoRow('App Version', '1.0.0'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Build Number', '100'),
                        const SizedBox(height: 12),
                        _buildInfoRow('Platform', 'Web'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Danger Zone
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_outlined,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Danger Zone',
                              style: AppTheme.titleLarge.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        ListTile(
                          leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                          title: const Text('Clear Cache'),
                          subtitle: const Text(
                            'Clear all cached data and preferences',
                          ),
                          trailing: OutlinedButton(
                            onPressed: _showClearCacheDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear all cached data? This will reset all your preferences and you will be logged out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache cleared successfully'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }
}
