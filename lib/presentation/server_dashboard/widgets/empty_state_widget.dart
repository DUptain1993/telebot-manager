import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAddServer;

  const EmptyStateWidget({
    super.key,
    this.onAddServer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(context, colorScheme),
            SizedBox(height: 4.h),
            _buildTitle(context, colorScheme),
            SizedBox(height: 2.h),
            _buildDescription(context, colorScheme),
            SizedBox(height: 6.h),
            _buildActionButton(context, colorScheme),
            SizedBox(height: 4.h),
            _buildFeaturesList(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomIconWidget(
            iconName: 'dns',
            color: colorScheme.primary.withValues(alpha: 0.3),
            size: 60,
          ),
          Positioned(
            top: 8.w,
            right: 8.w,
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onSecondary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ColorScheme colorScheme) {
    return Text(
      'Connect Your First Server',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context, ColorScheme colorScheme) {
    return Text(
      'Start managing your Telegram bot servers with secure monitoring, SSL certificate management, and real-time analytics.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onAddServer?.call();
        },
        icon: CustomIconWidget(
          iconName: 'add_circle',
          color: colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'Add Your First Server',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2.0,
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context, ColorScheme colorScheme) {
    final features = [
      {'icon': 'security', 'title': 'SSL Certificate Management'},
      {'icon': 'analytics', 'title': 'Real-time Monitoring'},
      {'icon': 'smart_toy', 'title': 'Bot Configuration'},
      {'icon': 'notifications', 'title': 'Alert Notifications'},
    ];

    return Column(
      children: [
        Text(
          'What you can do:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        ...features.map((feature) => _buildFeatureItem(
              context,
              colorScheme,
              feature['icon']!,
              feature['title']!,
            )),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, ColorScheme colorScheme,
      String iconName, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: colorScheme.secondary,
              size: 18,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
