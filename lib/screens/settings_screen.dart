import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _dailyRemindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _budgetAlertsEnabled = prefs.getBool('budget_alerts_enabled') ?? true;
      _dailyRemindersEnabled = prefs.getBool('daily_reminders_enabled') ?? true;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'notifications_enabled') _notificationsEnabled = value;
      if (key == 'budget_alerts_enabled') _budgetAlertsEnabled = value;
      if (key == 'daily_reminders_enabled') {
        _dailyRemindersEnabled = value;
        if (value) {
          NotificationService().scheduleDailyReminder(20, 0);
        } else {
          // Effectively canceled by the check inside scheduleDailyReminder
          NotificationService().scheduleDailyReminder(20, 0); 
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showEditNameDialog(AuthProvider auth) {
    _nameController.text = auth.displayName ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.updateDisplayName(_nameController.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  auth.displayName ?? 'No Name Set',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  auth.userEmail ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildSectionHeader('Profile & Theme'),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Name'),
            onTap: () => _showEditNameDialog(auth),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to Black & Green theme'),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
            activeColor: const Color(0xFF4CAF50),
          ),

          const Divider(),
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Enable All Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) => _updateSetting('notifications_enabled', value),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber_rounded),
            title: const Text('Budget Alerts'),
            subtitle: const Text('Notify at 80% and 100% usage'),
            value: _budgetAlertsEnabled,
            onChanged: _notificationsEnabled 
                ? (value) => _updateSetting('budget_alerts_enabled', value)
                : null,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alarm_on_rounded),
            title: const Text('Daily Reminders'),
            subtitle: const Text('Remind to log expenses at 8:00 PM'),
            value: _dailyRemindersEnabled,
            onChanged: _notificationsEnabled 
                ? (value) => _updateSetting('daily_reminders_enabled', value)
                : null,
            activeColor: Theme.of(context).colorScheme.primary,
          ),

          const Divider(),
          _buildSectionHeader('Support'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.pop(context);
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}