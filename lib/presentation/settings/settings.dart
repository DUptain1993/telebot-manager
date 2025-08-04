import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/export_import_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tile_widget.dart';
import './widgets/theme_selection_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Settings state
  bool _biometricEnabled = true;
  bool _notificationsEnabled = true;
  bool _serverAlertsEnabled = true;
  bool _certificateAlertsEnabled = true;
  bool _systemStatusEnabled = true;
  bool _debugLoggingEnabled = false;
  ThemeMode _currentTheme = ThemeMode.system;
  String _refreshInterval = '30 seconds';
  String _sessionTimeout = '15 minutes';

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Alex Rodriguez",
    "email": "alex.rodriguez@securecompany.com",
    "role": "DevOps Engineer",
    "avatar":
        "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    "connected_servers": 3,
    "last_login": "2025-08-04T20:15:30.000Z",
    "account_created": "2024-03-15T10:30:00.000Z"
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRefreshIntervalDialog() {
    final intervals = [
      '15 seconds',
      '30 seconds',
      '1 minute',
      '5 minutes',
      '10 minutes'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals
              .map((interval) => RadioListTile<String>(
                    title: Text(interval),
                    value: interval,
                    groupValue: _refreshInterval,
                    onChanged: (value) {
                      setState(() => _refreshInterval = value!);
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showSessionTimeoutDialog() {
    final timeouts = [
      '5 minutes',
      '15 minutes',
      '30 minutes',
      '1 hour',
      'Never'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Timeout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: timeouts
              .map((timeout) => RadioListTile<String>(
                    title: Text(timeout),
                    value: timeout,
                    groupValue: _sessionTimeout,
                    onChanged: (value) {
                      setState(() => _sessionTimeout = value!);
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: ThemeSelectionWidget(
          currentTheme: _currentTheme,
          onThemeChanged: (theme) {
            setState(() => _currentTheme = theme);
            Navigator.pop(context);
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmationDialogWidget.show(
      context: context,
      title: 'Sign Out',
      message:
          'Are you sure you want to sign out? You will need to authenticate again to access the app.',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      iconName: 'logout',
    );

    if (confirmed == true && mounted) {
      // Simulate logout process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed out successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Navigate to login screen (in a real app)
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _handleClearCache() async {
    final confirmed = await ConfirmationDialogWidget.show(
      context: context,
      title: 'Clear Cache',
      message:
          'This will clear all cached data including server configurations and certificates. The app may need to reload data from servers.',
      confirmText: 'Clear Cache',
      cancelText: 'Cancel',
      isDestructive: true,
      iconName: 'delete_sweep',
    );

    if (confirmed == true && mounted) {
      // Simulate cache clearing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cache cleared successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _handleResetSettings() async {
    final confirmed = await ConfirmationDialogWidget.show(
      context: context,
      title: 'Reset All Settings',
      message:
          'This will reset all app settings to their default values. This action cannot be undone.',
      confirmText: 'Reset Settings',
      cancelText: 'Cancel',
      isDestructive: true,
      iconName: 'restore',
    );

    if (confirmed == true && mounted) {
      setState(() {
        _biometricEnabled = true;
        _notificationsEnabled = true;
        _serverAlertsEnabled = true;
        _certificateAlertsEnabled = true;
        _systemStatusEnabled = true;
        _debugLoggingEnabled = false;
        _currentTheme = ThemeMode.system;
        _refreshInterval = '30 seconds';
        _sessionTimeout = '15 minutes';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings reset to defaults'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Settings'),
          ],
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor:
              theme.colorScheme.onPrimary.withValues(alpha: 0.7),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          // User Profile Section
          _buildUserProfileSection(),

          // Security Section
          SettingsSectionWidget(
            title: 'Security',
            children: [
              BiometricAuthWidget(
                isEnabled: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
              SettingsTileWidget(
                title: 'Session Timeout',
                subtitle: 'Automatically sign out after inactivity',
                iconName: 'timer',
                type: SettingsTileType.selection,
                trailingText: _sessionTimeout,
                onTap: _showSessionTimeoutDialog,
                isLast: true,
              ),
            ],
          ),

          // Notifications Section
          SettingsSectionWidget(
            title: 'Notifications',
            children: [
              SettingsTileWidget(
                title: 'Push Notifications',
                subtitle: 'Receive notifications on this device',
                iconName: 'notifications',
                type: SettingsTileType.toggle,
                switchValue: _notificationsEnabled,
                onSwitchChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
                isFirst: true,
              ),
              SettingsTileWidget(
                title: 'Server Alerts',
                subtitle: 'Notifications for server status changes',
                iconName: 'dns',
                type: SettingsTileType.toggle,
                switchValue: _serverAlertsEnabled,
                onSwitchChanged: (value) =>
                    setState(() => _serverAlertsEnabled = value),
              ),
              SettingsTileWidget(
                title: 'Certificate Alerts',
                subtitle: 'Warnings for expiring SSL certificates',
                iconName: 'security',
                type: SettingsTileType.toggle,
                switchValue: _certificateAlertsEnabled,
                onSwitchChanged: (value) =>
                    setState(() => _certificateAlertsEnabled = value),
              ),
              SettingsTileWidget(
                title: 'System Status',
                subtitle: 'Updates on system health and performance',
                iconName: 'monitor_heart',
                type: SettingsTileType.toggle,
                switchValue: _systemStatusEnabled,
                onSwitchChanged: (value) =>
                    setState(() => _systemStatusEnabled = value),
                isLast: true,
              ),
            ],
          ),

          // App Preferences Section
          SettingsSectionWidget(
            title: 'App Preferences',
            children: [
              SettingsTileWidget(
                title: 'Theme',
                subtitle: 'Choose your preferred appearance',
                iconName: 'palette',
                type: SettingsTileType.selection,
                trailingText: _currentTheme.name.capitalize(),
                onTap: _showThemeSelectionDialog,
                isFirst: true,
              ),
              SettingsTileWidget(
                title: 'Auto Refresh',
                subtitle: 'How often to update server data',
                iconName: 'refresh',
                type: SettingsTileType.selection,
                trailingText: _refreshInterval,
                onTap: _showRefreshIntervalDialog,
                isLast: true,
              ),
            ],
          ),

          // Data Management Section
          SettingsSectionWidget(
            title: 'Data Management',
            children: const [
              ExportImportWidget(),
            ],
          ),

          // Advanced Section
          SettingsSectionWidget(
            title: 'Advanced',
            children: [
              SettingsTileWidget(
                title: 'Debug Logging',
                subtitle: 'Enable detailed logging for troubleshooting',
                iconName: 'bug_report',
                type: SettingsTileType.toggle,
                switchValue: _debugLoggingEnabled,
                onSwitchChanged: (value) =>
                    setState(() => _debugLoggingEnabled = value),
                isFirst: true,
              ),
              SettingsTileWidget(
                title: 'Clear Cache',
                subtitle: 'Remove cached data and temporary files',
                iconName: 'delete_sweep',
                type: SettingsTileType.action,
                onTap: _handleClearCache,
              ),
              SettingsTileWidget(
                title: 'Reset Settings',
                subtitle: 'Restore all settings to default values',
                iconName: 'restore',
                type: SettingsTileType.action,
                isDestructive: true,
                onTap: _handleResetSettings,
                isLast: true,
              ),
            ],
          ),

          // About Section
          SettingsSectionWidget(
            title: 'About',
            children: [
              SettingsTileWidget(
                title: 'App Version',
                subtitle: 'SecureBot Manager',
                iconName: 'info',
                type: SettingsTileType.info,
                trailingText: '1.0.0',
                isFirst: true,
              ),
              SettingsTileWidget(
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                iconName: 'privacy_tip',
                type: SettingsTileType.navigation,
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              SettingsTileWidget(
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                iconName: 'description',
                type: SettingsTileType.navigation,
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              SettingsTileWidget(
                title: 'Contact Support',
                subtitle: 'Get help with the app',
                iconName: 'support_agent',
                type: SettingsTileType.navigation,
                onTap: () {
                  // Navigate to support
                },
                isLast: true,
              ),
            ],
          ),

          // Sign Out Section
          SettingsSectionWidget(
            title: '',
            children: [
              SettingsTileWidget(
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                iconName: 'logout',
                type: SettingsTileType.action,
                isDestructive: true,
                onTap: _handleLogout,
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomImageWidget(
                  imageUrl: _userData["avatar"] as String,
                  width: 16.w,
                  height: 16.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData["name"] as String,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _userData["email"] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _userData["role"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 6.w,
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
