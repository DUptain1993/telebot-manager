import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ServerStatusCard extends StatelessWidget {
  final Map<String, dynamic> serverData;
  final VoidCallback? onRefresh;

  const ServerStatusCard({
    super.key,
    required this.serverData,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = (serverData['status'] as String?) ?? 'unknown';
    final uptime = (serverData['uptime'] as String?) ?? '0h 0m';
    final memoryUsage = (serverData['memoryUsage'] as double?) ?? 0.0;
    final cpuUsage = (serverData['cpuUsage'] as double?) ?? 0.0;
    final lastUpdated = (serverData['lastUpdated'] as String?) ?? 'Never';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Server Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _buildStatusIndicator(status, colorScheme),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: onRefresh,
                      child: CustomIconWidget(
                        iconName: 'refresh',
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Uptime',
                    uptime,
                    CustomIconWidget(
                      iconName: 'schedule',
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    theme,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildMetricItem(
                    'Status',
                    _getStatusText(status),
                    CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      size: 20,
                      color: _getStatusColor(status, colorScheme),
                    ),
                    theme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildProgressMetric(
              'Memory Usage',
              memoryUsage,
              '${(memoryUsage * 100).toStringAsFixed(1)}%',
              theme,
              colorScheme,
            ),
            SizedBox(height: 2.h),
            _buildProgressMetric(
              'CPU Usage',
              cpuUsage,
              '${(cpuUsage * 100).toStringAsFixed(1)}%',
              theme,
              colorScheme,
            ),
            SizedBox(height: 2.h),
            Text(
              'Last updated: $lastUpdated',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, ColorScheme colorScheme) {
    return Container(
      width: 3.w,
      height: 3.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(status, colorScheme),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Widget icon,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressMetric(
    String label,
    double value,
    String displayValue,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: value,
          backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(value, colorScheme),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'Online';
      case 'offline':
        return 'Offline';
      case 'maintenance':
        return 'Maintenance';
      case 'error':
        return 'Error';
      default:
        return 'Unknown';
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'check_circle';
      case 'offline':
        return 'cancel';
      case 'maintenance':
        return 'build';
      case 'error':
        return 'error';
      default:
        return 'help';
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'maintenance':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }

  Color _getProgressColor(double value, ColorScheme colorScheme) {
    if (value < 0.5) {
      return Colors.green;
    } else if (value < 0.8) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
