import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final teacher = authState.teacher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'T',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Teacher Name',
                      style: AppTheme.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher?.employeeId ?? 'N/A',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        teacher?.specialization ?? 'N/A',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            Text(
              'Personal Information',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: user?.email ?? 'N/A',
                  ),
                  const Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: user?.phone ?? 'N/A',
                  ),
                  if (teacher?.qualification != null) ...[
                    const Divider(height: 1),
                    _buildInfoItem(
                      icon: Icons.school,
                      label: 'Qualification',
                      value: teacher!.qualification!,
                    ),
                  ],
                  if (teacher?.dateOfJoining != null) ...[
                    const Divider(height: 1),
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'Date of Joining',
                      value: teacher!.dateOfJoining!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings/Actions
            Text(
              'Settings',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  // Dark Mode Toggle
                  ListTile(
                    leading: Icon(
                      ref.watch(themeModeProvider) == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text('Dark Mode', style: AppTheme.titleMedium),
                    trailing: Switch(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  const Divider(height: 1),
                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                    title: Text('Language', style: AppTheme.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ref.read(localeProvider.notifier).getLanguageName(
                            ref.watch(localeProvider),
                          ),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
                      ],
                    ),
                    onTap: () => _showLanguageDialog(),
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.lock,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.help,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.info,
                    label: 'About',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 16),

            // App Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: AppTheme.bodySmall),
      subtitle: Text(value, style: AppTheme.titleMedium),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: AppTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLocales.map((locale) {
            final currentLocale = ref.read(localeProvider);
            final languageName = ref.read(localeProvider.notifier).getLanguageName(locale);

            return RadioListTile<Locale>(
              title: Text(languageName),
              value: locale,
              groupValue: currentLocale,
              activeColor: AppTheme.primaryColor,
              onChanged: (Locale? value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
