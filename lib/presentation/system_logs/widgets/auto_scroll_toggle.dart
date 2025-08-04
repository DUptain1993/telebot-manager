import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AutoScrollToggle extends StatelessWidget {
  final bool isAutoScrollEnabled;
  final ValueChanged<bool> onToggle;
  final bool isLiveStreaming;

  const AutoScrollToggle({
    super.key,
    required this.isAutoScrollEnabled,
    required this.onToggle,
    this.isLiveStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: isAutoScrollEnabled
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: isAutoScrollEnabled ? 'play_arrow' : 'pause',
              color: isAutoScrollEnabled
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-scroll',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAutoScrollEnabled
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                if (isLiveStreaming)
                  Row(
                    children: [
                      Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Live streaming',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Switch(
            value: isAutoScrollEnabled,
            onChanged: onToggle,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            inactiveThumbColor: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
            inactiveTrackColor: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}
