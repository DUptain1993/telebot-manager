import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CertificateHealthOverviewWidget extends StatelessWidget {
  final Map<String, int> healthStats;
  final VoidCallback? onRefresh;

  const CertificateHealthOverviewWidget({
    super.key,
    required this.healthStats,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalCerts = healthStats['total'] ?? 0;
    final validCerts = healthStats['valid'] ?? 0;
    final expiringCerts = healthStats['expiring'] ?? 0;
    final expiredCerts = healthStats['expired'] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Certificate Health Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onRefresh,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildHealthStat(
                  context,
                  'Total',
                  totalCerts.toString(),
                  colorScheme.primary,
                  'security',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildHealthStat(
                  context,
                  'Valid',
                  validCerts.toString(),
                  Colors.green,
                  'verified',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildHealthStat(
                  context,
                  'Expiring',
                  expiringCerts.toString(),
                  Colors.orange,
                  'warning',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildHealthStat(
                  context,
                  'Expired',
                  expiredCerts.toString(),
                  colorScheme.error,
                  'error',
                ),
              ),
            ],
          ),
          if (expiringCerts > 0 || expiredCerts > 0) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (expiredCerts > 0 ? colorScheme.error : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (expiredCerts > 0 ? colorScheme.error : Colors.orange)
                      .withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: expiredCerts > 0 ? 'error' : 'warning',
                    color: expiredCerts > 0 ? colorScheme.error : Colors.orange,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      expiredCerts > 0
                          ? 'You have $expiredCerts expired certificate${expiredCerts > 1 ? 's' : ''} that need immediate attention'
                          : 'You have $expiringCerts certificate${expiringCerts > 1 ? 's' : ''} expiring within 30 days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: expiredCerts > 0
                            ? colorScheme.error
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 1.h),
          _buildHealthProgress(context, validCerts, totalCerts),
        ],
      ),
    );
  }

  Widget _buildHealthStat(
    BuildContext context,
    String label,
    String value,
    Color color,
    String iconName,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProgress(
      BuildContext context, int validCerts, int totalCerts) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final healthPercentage = totalCerts > 0 ? (validCerts / totalCerts) : 0.0;

    Color progressColor;
    String healthStatus;

    if (healthPercentage >= 0.8) {
      progressColor = Colors.green;
      healthStatus = 'Excellent';
    } else if (healthPercentage >= 0.6) {
      progressColor = Colors.orange;
      healthStatus = 'Good';
    } else if (healthPercentage >= 0.4) {
      progressColor = Colors.orange;
      healthStatus = 'Fair';
    } else {
      progressColor = colorScheme.error;
      healthStatus = 'Poor';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Health: $healthStatus',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(healthPercentage * 100).toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: healthPercentage,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
