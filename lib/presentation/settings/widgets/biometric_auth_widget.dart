import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricAuthWidget extends StatefulWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const BiometricAuthWidget({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget> {
  bool _isAuthenticating = false;

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      // Enable biometric authentication
      setState(() => _isAuthenticating = true);

      try {
        // Simulate biometric authentication check
        await Future.delayed(const Duration(milliseconds: 500));

        // In a real app, you would use local_auth package here
        // final LocalAuthentication auth = LocalAuthentication();
        // final bool canCheckBiometrics = await auth.canCheckBiometrics;
        // final bool didAuthenticate = await auth.authenticate(
        //   localizedReason: 'Please authenticate to enable biometric login',
        //   options: const AuthenticationOptions(
        //     biometricOnly: true,
        //   ),
        // );

        // For demo purposes, we'll assume authentication succeeds
        widget.onChanged(true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Biometric authentication enabled'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to enable biometric authentication'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isAuthenticating = false);
        }
      }
    } else {
      // Disable biometric authentication
      widget.onChanged(false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Biometric authentication disabled'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
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
                  iconName: 'fingerprint',
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
                    'Biometric Authentication',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Use fingerprint or face recognition to unlock the app',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (_isAuthenticating)
              SizedBox(
                width: 6.w,
                height: 6.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            else
              Switch(
                value: widget.isEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  _handleBiometricToggle(value);
                },
                activeColor: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
