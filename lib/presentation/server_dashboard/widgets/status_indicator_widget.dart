import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatusIndicatorWidget extends StatelessWidget {
  final bool isSecureConnection;
  final String currentUser;
  final bool isOnline;

  const StatusIndicatorWidget({
    super.key,
    required this.isSecureConnection,
    required this.currentUser,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildSecurityIndicator(context, colorScheme, isDark),
          SizedBox(width: 4.w),
          _buildNetworkIndicator(context, colorScheme, isDark),
          const Spacer(),
          _buildUserInfo(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSecurityIndicator(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    final Color securityColor = isSecureConnection
        ? (isDark ? AppTheme.successDark : AppTheme.successLight)
        : (isDark ? AppTheme.errorDark : AppTheme.errorLight);

    return Row(
      children: [
        CustomIconWidget(
          iconName: isSecureConnection ? 'lock' : 'lock_open',
          color: securityColor,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          isSecureConnection ? 'SECURE' : 'UNSECURE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: securityColor,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
        ),
      ],
    );
  }

  Widget _buildNetworkIndicator(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    final Color networkColor = isOnline
        ? (isDark ? AppTheme.successDark : AppTheme.successLight)
        : (isDark ? AppTheme.errorDark : AppTheme.errorLight);

    return Row(
      children: [
        CustomIconWidget(
          iconName: isOnline ? 'wifi' : 'wifi_off',
          color: networkColor,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          isOnline ? 'ONLINE' : 'OFFLINE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: networkColor,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: CustomIconWidget(
            iconName: 'person',
            color: colorScheme.primary,
            size: 16,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          currentUser,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
