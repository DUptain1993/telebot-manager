import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServerCardWidget extends StatelessWidget {
  final Map<String, dynamic> server;
  final VoidCallback? onTap;
  final VoidCallback? onViewLogs;
  final VoidCallback? onTestConnection;
  final VoidCallback? onEmergencyStop;
  final VoidCallback? onConfigure;
  final VoidCallback? onRemove;

  const ServerCardWidget({
    super.key,
    required this.server,
    this.onTap,
    this.onViewLogs,
    this.onTestConnection,
    this.onEmergencyStop,
    this.onConfigure,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final String status = (server['status'] as String?) ?? 'unknown';
    final Color statusColor = _getStatusColor(status, isDark);
    final String serverName = (server['name'] as String?) ?? 'Unknown Server';
    final String environment = (server['environment'] as String?) ?? 'dev';
    final int botCount = (server['botCount'] as int?) ?? 0;
    final String sslStatus = (server['sslStatus'] as String?) ?? 'unknown';
    final String lastUpdate = (server['lastUpdate'] as String?) ?? 'Never';

    return Dismissible(
      key: Key('server_${server['id']}'),
      background: _buildLeftSwipeBackground(context, colorScheme),
      secondaryBackground: _buildRightSwipeBackground(context, colorScheme),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          // Left swipe actions
          _showQuickActionsSheet(context);
        } else {
          // Right swipe actions
          _showConfigurationSheet(context);
        }
        return false; // Don't actually dismiss
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showContextMenu(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(context, colorScheme, statusColor, serverName,
                  environment, status),
              _buildCardContent(context, colorScheme, botCount, sslStatus),
              _buildCardFooter(context, colorScheme, lastUpdate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(
    BuildContext context,
    ColorScheme colorScheme,
    Color statusColor,
    String serverName,
    String environment,
    String status,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serverName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildEnvironmentBadge(context, colorScheme, environment),
                    SizedBox(width: 2.w),
                    Text(
                      status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'chevron_right',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentBadge(
      BuildContext context, ColorScheme colorScheme, String environment) {
    final Color badgeColor = environment.toLowerCase() == 'prod'
        ? colorScheme.error
        : colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        environment.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ColorScheme colorScheme,
      int botCount, String sslStatus) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoItem(
              context,
              colorScheme,
              'smart_toy',
              'Bots',
              botCount.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 4.h,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildInfoItem(
              context,
              colorScheme,
              'security',
              'SSL',
              sslStatus.toUpperCase(),
              statusColor: _getSSLStatusColor(
                  sslStatus, Theme.of(context).brightness == Brightness.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    ColorScheme colorScheme,
    String iconName,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: statusColor ?? colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: statusColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(
      BuildContext context, ColorScheme colorScheme, String lastUpdate) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'access_time',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Last updated: $lastUpdate',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSwipeBackground(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          SizedBox(width: 6.w),
          CustomIconWidget(
            iconName: 'visibility',
            color: colorScheme.onPrimary,
            size: 24,
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: 'wifi',
            color: colorScheme.onPrimary,
            size: 24,
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: 'stop_circle',
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildRightSwipeBackground(
      BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomIconWidget(
            iconName: 'settings',
            color: colorScheme.onSecondary,
            size: 24,
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: 'delete',
            color: colorScheme.onSecondary,
            size: 24,
          ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('View Logs'),
              onTap: () {
                Navigator.pop(context);
                onViewLogs?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'wifi',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Test Connection'),
              onTap: () {
                Navigator.pop(context);
                onTestConnection?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'stop_circle',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Emergency Stop'),
              onTap: () {
                Navigator.pop(context);
                onEmergencyStop?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigurationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Configure'),
              onTap: () {
                Navigator.pop(context);
                onConfigure?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Remove Server'),
              onTap: () {
                Navigator.pop(context);
                onRemove?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Server Details'),
              onTap: () {
                Navigator.pop(context);
                onTap?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('View Logs'),
              onTap: () {
                Navigator.pop(context);
                onViewLogs?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'wifi',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Test Connection'),
              onTap: () {
                Navigator.pop(context);
                onTestConnection?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Configure'),
              onTap: () {
                Navigator.pop(context);
                onConfigure?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'stop_circle',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Emergency Stop'),
              onTap: () {
                Navigator.pop(context);
                onEmergencyStop?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Remove Server'),
              onTap: () {
                Navigator.pop(context);
                onRemove?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'running':
        return isDark ? AppTheme.successDark : AppTheme.successLight;
      case 'warning':
      case 'degraded':
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
      case 'critical':
      case 'error':
      case 'stopped':
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      default:
        return isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }

  Color _getSSLStatusColor(String sslStatus, bool isDark) {
    switch (sslStatus.toLowerCase()) {
      case 'valid':
      case 'active':
        return isDark ? AppTheme.successDark : AppTheme.successLight;
      case 'expiring':
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
      case 'expired':
      case 'invalid':
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      default:
        return isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight;
    }
  }
}
