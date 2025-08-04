import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum SettingsTileType {
  navigation,
  toggle,
  selection,
  action,
  info,
}

class SettingsTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? iconName;
  final SettingsTileType type;
  final VoidCallback? onTap;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final String? trailingText;
  final Color? iconColor;
  final bool isDestructive;
  final bool isFirst;
  final bool isLast;

  const SettingsTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.iconName,
    this.type = SettingsTileType.navigation,
    this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.trailingText,
    this.iconColor,
    this.isDestructive = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            if (onTap != null) {
              HapticFeedback.lightImpact();
              onTap!();
            }
          },
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                if (iconName != null) ...[
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: iconColor ??
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: iconName!,
                        color: iconColor ?? theme.colorScheme.primary,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDestructive
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildTrailing(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, ThemeData theme) {
    switch (type) {
      case SettingsTileType.toggle:
        return Switch(
          value: switchValue ?? false,
          onChanged: onSwitchChanged,
          activeColor: theme.colorScheme.primary,
        );
      case SettingsTileType.selection:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(width: 2.w),
            ],
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 5.w,
            ),
          ],
        );
      case SettingsTileType.info:
        return trailingText != null
            ? Text(
                trailingText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            : const SizedBox.shrink();
      case SettingsTileType.action:
        return const SizedBox.shrink();
      case SettingsTileType.navigation:
      default:
        return CustomIconWidget(
          iconName: 'chevron_right',
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          size: 5.w,
        );
    }
  }
}
