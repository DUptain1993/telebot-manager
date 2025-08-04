import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ServerActionsCard extends StatelessWidget {
  final VoidCallback? onRestartServer;
  final VoidCallback? onDeployChanges;
  final VoidCallback? onViewLogs;
  final VoidCallback? onBackupServer;
  final bool isLoading;

  const ServerActionsCard({
    super.key,
    this.onRestartServer,
    this.onDeployChanges,
    this.onViewLogs,
    this.onBackupServer,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildActionGrid(context, theme, colorScheme),
            SizedBox(height: 3.h),
            _buildCriticalActions(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'View Logs',
            'article',
            colorScheme.primary,
            onViewLogs,
            theme,
            colorScheme,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildActionButton(
            context,
            'Backup',
            'backup',
            Colors.blue,
            onBackupServer,
            theme,
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalActions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                isLoading ? null : () => _showDeployConfirmation(context),
            icon: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'rocket_launch',
                    size: 18,
                    color: colorScheme.onPrimary,
                  ),
            label: Text(isLoading ? 'Deploying...' : 'Deploy Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 3.h),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                isLoading ? null : () => _showRestartConfirmation(context),
            icon: CustomIconWidget(
              iconName: 'restart_alt',
              size: 18,
              color: Colors.orange,
            ),
            label: const Text('Restart Server'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: EdgeInsets.symmetric(vertical: 3.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback? onPressed,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onPressed != null && !isLoading
          ? () {
              HapticFeedback.lightImpact();
              onPressed();
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: iconName,
                size: 24,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isLoading
                    ? colorScheme.onSurface.withValues(alpha: 0.5)
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRestartConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              size: 24,
              color: Colors.orange,
            ),
            SizedBox(width: 2.w),
            const Text('Restart Server'),
          ],
        ),
        content: const Text(
          'Are you sure you want to restart the server? This will temporarily interrupt all bot services and may take a few minutes to complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRestartServer?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showDeployConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'rocket_launch',
              size: 24,
              color: Colors.green,
            ),
            SizedBox(width: 2.w),
            const Text('Deploy Changes'),
          ],
        ),
        content: const Text(
          'This will deploy all pending configuration changes to the server. The deployment process may take several minutes and will restart affected services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeployChanges?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deploy'),
          ),
        ],
      ),
    );
  }
}
