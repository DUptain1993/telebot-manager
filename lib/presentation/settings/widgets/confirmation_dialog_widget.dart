import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final String? iconName;

  const ConfirmationDialogWidget({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (iconName != null) ...[
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isDestructive
                    ? theme.colorScheme.error.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName!,
                  color: isDestructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(
            cancelText,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            foregroundColor: isDestructive
                ? theme.colorScheme.onError
                : theme.colorScheme.onPrimary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    String? iconName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        iconName: iconName,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
