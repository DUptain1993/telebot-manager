import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DatabaseConnectionCard extends StatelessWidget {
  final Map<String, dynamic> connectionData;
  final VoidCallback? onTestConnection;
  final VoidCallback? onEditConnection;

  const DatabaseConnectionCard({
    super.key,
    required this.connectionData,
    this.onTestConnection,
    this.onEditConnection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final host = (connectionData['host'] as String?) ?? 'localhost';
    final port = (connectionData['port'] as int?) ?? 5432;
    final database = (connectionData['database'] as String?) ?? 'Unknown';
    final username = (connectionData['username'] as String?) ?? 'Unknown';
    final status = (connectionData['status'] as String?) ?? 'disconnected';
    final lastChecked = (connectionData['lastChecked'] as String?) ?? 'Never';
    final responseTime = (connectionData['responseTime'] as int?) ?? 0;

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
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'storage',
                      size: 24,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Database Connection',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _buildConnectionStatus(status, colorScheme, theme),
              ],
            ),
            SizedBox(height: 3.h),
            _buildConnectionDetails(
              host,
              port,
              database,
              username,
              theme,
              colorScheme,
            ),
            SizedBox(height: 3.h),
            _buildConnectionMetrics(
              lastChecked,
              responseTime,
              theme,
              colorScheme,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditConnection,
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: const Text('Edit Connection'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTestConnection,
                    icon: CustomIconWidget(
                      iconName: 'wifi_protected_setup',
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                    label: const Text('Test Connection'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(
    String status,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'connected':
        statusColor = Colors.green;
        statusText = 'Connected';
        statusIcon = Icons.check_circle;
        break;
      case 'disconnected':
        statusColor = Colors.red;
        statusText = 'Disconnected';
        statusIcon = Icons.cancel;
        break;
      case 'connecting':
        statusColor = Colors.orange;
        statusText = 'Connecting';
        statusIcon = Icons.sync;
        break;
      case 'error':
        statusColor = Colors.red;
        statusText = 'Error';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = colorScheme.onSurface.withValues(alpha: 0.5);
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          SizedBox(width: 1.w),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionDetails(
    String host,
    int port,
    String database,
    String username,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Host',
            host,
            CustomIconWidget(
              iconName: 'dns',
              size: 18,
              color: colorScheme.primary,
            ),
            theme,
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            'Port',
            port.toString(),
            CustomIconWidget(
              iconName: 'settings_ethernet',
              size: 18,
              color: colorScheme.primary,
            ),
            theme,
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            'Database',
            database,
            CustomIconWidget(
              iconName: 'folder',
              size: 18,
              color: colorScheme.primary,
            ),
            theme,
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            'Username',
            username,
            CustomIconWidget(
              iconName: 'person',
              size: 18,
              color: colorScheme.primary,
            ),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionMetrics(
    String lastChecked,
    int responseTime,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            'Last Checked',
            lastChecked,
            CustomIconWidget(
              iconName: 'schedule',
              size: 18,
              color: colorScheme.primary,
            ),
            theme,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildMetricItem(
            'Response Time',
            responseTime > 0 ? '${responseTime}ms' : 'N/A',
            CustomIconWidget(
              iconName: 'speed',
              size: 18,
              color: _getResponseTimeColor(responseTime),
            ),
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Widget icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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

  Color _getResponseTimeColor(int responseTime) {
    if (responseTime <= 0) return Colors.grey;
    if (responseTime < 100) return Colors.green;
    if (responseTime < 500) return Colors.orange;
    return Colors.red;
  }
}
