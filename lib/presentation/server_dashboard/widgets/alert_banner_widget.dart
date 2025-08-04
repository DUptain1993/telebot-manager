import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AlertBannerWidget extends StatelessWidget {
  final String message;
  final String type;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final String? actionLabel;

  const AlertBannerWidget({
    super.key,
    required this.message,
    required this.type,
    this.onAction,
    this.onDismiss,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color alertColor = _getAlertColor(type, isDark);
    final IconData alertIcon = _getAlertIcon(type);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: _getIconName(alertIcon),
              color: alertColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getAlertTitle(type),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: alertColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(width: 2.w),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: alertColor,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
                child: Text(
                  actionLabel!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: alertColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              SizedBox(width: 1.w),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDismiss?.call();
                },
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 18,
                ),
                constraints: BoxConstraints(
                  minWidth: 8.w,
                  minHeight: 8.w,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(String type, bool isDark) {
    switch (type.toLowerCase()) {
      case 'critical':
      case 'error':
        return isDark ? AppTheme.errorDark : AppTheme.errorLight;
      case 'warning':
        return isDark ? AppTheme.warningDark : AppTheme.warningLight;
      case 'success':
        return isDark ? AppTheme.successDark : AppTheme.successLight;
      case 'info':
      default:
        return isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'critical':
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      case 'info':
      default:
        return Icons.info;
    }
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.error) return 'error';
    if (icon == Icons.warning) return 'warning';
    if (icon == Icons.check_circle) return 'check_circle';
    return 'info';
  }

  String _getAlertTitle(String type) {
    switch (type.toLowerCase()) {
      case 'critical':
        return 'Critical Alert';
      case 'error':
        return 'Error';
      case 'warning':
        return 'Warning';
      case 'success':
        return 'Success';
      case 'info':
      default:
        return 'Information';
    }
  }
}
