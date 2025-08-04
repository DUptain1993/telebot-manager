import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final VoidCallback? onAddServer;
  final bool isConnected;
  final VoidCallback? onRefresh;

  const DashboardHeaderWidget({
    super.key,
    this.onAddServer,
    required this.isConnected,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Server Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    _buildConnectionIndicator(context, colorScheme, isDark),
                    SizedBox(width: 4.w),
                    Text(
                      'Last sync: ${_getLastSyncTime()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    final Color indicatorColor = isConnected
        ? (isDark ? AppTheme.successDark : AppTheme.successLight)
        : (isDark ? AppTheme.errorDark : AppTheme.errorLight);

    return Row(
      children: [
        Container(
          width: 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onRefresh?.call();
          },
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            size: 20,
          ),
          tooltip: 'Refresh',
        ),
        SizedBox(width: 2.w),
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onAddServer?.call();
          },
          icon: CustomIconWidget(
            iconName: 'add',
            color: colorScheme.onPrimary,
            size: 18,
          ),
          label: Text(
            'Add Server',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }

  String _getLastSyncTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
