import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/reminder_provider.dart';
import 'reminders_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer3<ThemeProvider, ExpenseProvider, ReminderProvider>(
        builder: (context, themeProvider, expenseProvider, reminderProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserProfile(context)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                _buildSettingsSection(
                  context,
                  'Preferences',
                  [
                    _buildThemeToggle(context, themeProvider),
                    _buildNotificationSettings(context),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                const SizedBox(height: 24),

                _buildSettingsSection(
                  context,
                  'Data Management',
                  [
                    _buildDataTile(
                      context,
                      'Backup Data',
                      'Export your data to cloud storage',
                      Icons.cloud_upload_rounded,
                      () => _showBackupDialog(context),
                    ),
                    _buildDataTile(
                      context,
                      'Restore Data',
                      'Import data from backup',
                      Icons.cloud_download_rounded,
                      () => _showRestoreDialog(context),
                    ),
                    _buildDataTile(
                      context,
                      'Clear All Data',
                      'Reset app to initial state',
                      Icons.delete_forever_rounded,
                      () => _showClearDataDialog(context, expenseProvider, reminderProvider),
                      isDestructive: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                const SizedBox(height: 24),

                _buildSettingsSection(
                  context,
                  'Reminders',
                  [
                    _buildActionTile(
                      context,
                      'Manage Reminders',
                      'Set up bill and payment reminders',
                      Icons.notifications_rounded,
                      () => _navigateToReminders(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

                const SizedBox(height: 24),

                _buildSettingsSection(
                  context,
                  'About',
                  [
                    _buildInfoTile(context, 'Version', '1.0.0'),
                    _buildInfoTile(context, 'Developer', 'Finance Tracker Team'),
                    _buildActionTile(
                      context,
                      'Privacy Policy',
                      'Read our privacy policy',
                      Icons.privacy_tip_rounded,
                      () => _showPrivacyPolicy(context),
                    ),
                    _buildActionTile(
                      context,
                      'Terms of Service',
                      'Read our terms of service',
                      Icons.description_rounded,
                      () => _showTermsOfService(context),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your finance settings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        color: const Color(0xFF6C63FF),
      ),
      title: const Text('Dark Mode'),
      subtitle: Text(themeProvider.isDarkMode ? 'Currently enabled' : 'Currently disabled'),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.notifications_rounded,
        color: Color(0xFF6C63FF),
      ),
      title: const Text('Notifications'),
      subtitle: const Text('Enable push notifications'),
      trailing: Switch(
        value: true,
        onChanged: (value) {
          // TODO: Implement notification toggle
        },
      ),
    );
  }

  Widget _buildDataTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF6C63FF),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value) {
    return ListTile(
      leading: const Icon(Icons.info_rounded, color: Color(0xFF6C63FF)),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  void _navigateToReminders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RemindersScreen(),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('This feature will be available in a future update. Your data is automatically saved locally.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    ExpenseProvider expenseProvider,
    ReminderProvider reminderProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your expenses, categories, and reminders. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await expenseProvider.clearAllData();
                await reminderProvider.clearAllReminders();

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing data: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Finance Tracker Privacy Policy\n\n'
            'We respect your privacy and are committed to protecting your personal data. This app:\n\n'
            '• Stores all data locally on your device\n'
            '• Does not collect or transmit personal information\n'
            '• Does not use third-party analytics\n'
            '• Does not contain advertisements\n\n'
            'Your financial data remains private and secure on your device.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Finance Tracker Terms of Service\n\n'
            'By using this application, you agree to:\n\n'
            '• Use the app for personal financial tracking only\n'
            '• Take responsibility for backing up your data\n'
            '• Not hold the developers liable for any data loss\n'
            '• Use the app in accordance with local laws\n\n'
            'This app is provided "as is" without warranty of any kind.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}