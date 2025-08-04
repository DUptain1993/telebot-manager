import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum ThemeMode {
  system,
  light,
  dark,
}

class ThemeSelectionWidget extends StatefulWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ThemeSelectionWidget({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSelectionWidget> createState() => _ThemeSelectionWidgetState();
}

class _ThemeSelectionWidgetState extends State<ThemeSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            theme,
            'System',
            'Follow device settings',
            'brightness_auto',
            ThemeMode.system,
            isFirst: true,
          ),
          _buildThemeOption(
            context,
            theme,
            'Light',
            'Always use light theme',
            'light_mode',
            ThemeMode.light,
          ),
          _buildThemeOption(
            context,
            theme,
            'Dark',
            'Always use dark theme',
            'dark_mode',
            ThemeMode.dark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    String iconName,
    ThemeMode themeMode, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = widget.currentTheme == themeMode;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isFirst
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 0.5,
                ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onThemeChanged(themeMode);
          },
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: theme.colorScheme.primary,
                      size: 5.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.primary,
                    size: 6.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
