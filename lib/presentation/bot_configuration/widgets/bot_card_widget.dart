import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BotCardWidget extends StatelessWidget {
  final Map<String, dynamic> bot;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onRestart;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onModeToggle;

  const BotCardWidget({
    super.key,
    required this.bot,
    this.onTap,
    this.onStart,
    this.onStop,
    this.onRestart,
    this.onEdit,
    this.onDelete,
    this.onModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = (bot["status"] as String).toLowerCase() == "active";
    final isWebhookMode = (bot["mode"] as String).toLowerCase() == "webhook";
    final messageCount = bot["messageCount"] as int;
    final lastActivity = bot["lastActivity"] as String;
    final tokenPreview = _maskToken(bot["token"] as String);

    return Dismissible(
      key: Key(bot["id"].toString()),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          _showActionBottomSheet(context);
        } else {
          _showEditDeleteBottomSheet(context);
        }
        return false;
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showContextMenu(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, colorScheme, isActive),
                SizedBox(height: 2.h),
                _buildBotInfo(context, colorScheme, tokenPreview),
                SizedBox(height: 2.h),
                _buildModeToggle(context, colorScheme, isWebhookMode),
                SizedBox(height: 2.h),
                _buildMetrics(context, colorScheme, messageCount, lastActivity),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ColorScheme colorScheme, bool isActive) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppTheme.getStatusColor('success',
                    isLight: Theme.of(context).brightness == Brightness.light)
                : AppTheme.getStatusColor('error',
                    isLight: Theme.of(context).brightness == Brightness.light),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            bot["name"] as String,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.getStatusColor('success',
                        isLight:
                            Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1)
                : AppTheme.getStatusColor('error',
                        isLight:
                            Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bot["status"] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? AppTheme.getStatusColor('success',
                          isLight:
                              Theme.of(context).brightness == Brightness.light)
                      : AppTheme.getStatusColor('error',
                          isLight:
                              Theme.of(context).brightness == Brightness.light),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotInfo(
      BuildContext context, ColorScheme colorScheme, String tokenPreview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'key',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              'Token: $tokenPreview',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'description',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 16,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                bot["description"] as String,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeToggle(
      BuildContext context, ColorScheme colorScheme, bool isWebhookMode) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isWebhookMode ? 'webhook' : 'sync',
            color: colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWebhookMode ? 'Webhook Mode' : 'Polling Mode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  isWebhookMode
                      ? 'Real-time message handling'
                      : 'Periodic message checking',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isWebhookMode,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onModeToggle?.call(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(BuildContext context, ColorScheme colorScheme,
      int messageCount, String lastActivity) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            context,
            colorScheme,
            'messages',
            'Messages',
            messageCount.toString(),
          ),
        ),
        Container(
          width: 1,
          height: 4.h,
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        Expanded(
          child: _buildMetricItem(
            context,
            colorScheme,
            'schedule',
            'Last Activity',
            lastActivity,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(BuildContext context, ColorScheme colorScheme,
      String iconName, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft
            ? AppTheme.getStatusColor('error',
                isLight: Theme.of(context).brightness == Brightness.light)
            : AppTheme.getStatusColor('success',
                isLight: Theme.of(context).brightness == Brightness.light),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'delete' : 'play_arrow',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'Delete' : 'Actions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    final isActive = (bot["status"] as String).toLowerCase() == "active";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Bot Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            if (!isActive)
              _buildActionTile(context, 'play_arrow', 'Start Bot', onStart),
            if (isActive) ...[
              _buildActionTile(context, 'stop', 'Stop Bot', onStop),
              _buildActionTile(context, 'refresh', 'Restart Bot', onRestart),
            ],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showEditDeleteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Bot Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildActionTile(context, 'edit', 'Edit Bot', onEdit),
            _buildActionTile(
              context,
              'delete',
              'Delete Bot',
              () => _showDeleteConfirmation(context),
              isDestructive: true,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Advanced Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildActionTile(context, 'analytics', 'View Analytics', () {}),
            _buildActionTile(context, 'settings', 'Bot Settings', () {}),
            _buildActionTile(context, 'code', 'View Logs', () {}),
            _buildActionTile(context, 'share', 'Export Config', () {}),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context, String iconName, String title, VoidCallback? onTap,
      {bool isDestructive = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive
            ? AppTheme.getStatusColor('error',
                isLight: Theme.of(context).brightness == Brightness.light)
            : colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDestructive
                  ? AppTheme.getStatusColor('error',
                      isLight: Theme.of(context).brightness == Brightness.light)
                  : colorScheme.onSurface,
            ),
      ),
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
        onTap?.call();
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bot'),
        content: Text(
            'Are you sure you want to delete "${bot["name"]}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getStatusColor('error',
                  isLight: Theme.of(context).brightness == Brightness.light),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _maskToken(String token) {
    if (token.length <= 8) return token;
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }
}
