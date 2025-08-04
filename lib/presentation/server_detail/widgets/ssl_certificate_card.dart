import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SslCertificateCard extends StatelessWidget {
  final Map<String, dynamic> certificateData;
  final VoidCallback? onRenew;
  final VoidCallback? onViewDetails;

  const SslCertificateCard({
    super.key,
    required this.certificateData,
    this.onRenew,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final domain = (certificateData['domain'] as String?) ?? 'Unknown Domain';
    final expirationDate =
        (certificateData['expirationDate'] as String?) ?? 'Unknown';
    final daysUntilExpiry = (certificateData['daysUntilExpiry'] as int?) ?? 0;
    final isValid = (certificateData['isValid'] as bool?) ?? false;
    final issuer = (certificateData['issuer'] as String?) ?? 'Unknown Issuer';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SSL Certificate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildValidationBadge(isValid, colorScheme, theme),
              ],
            ),
            SizedBox(height: 3.h),
            _buildCertificateInfo(domain, issuer, theme, colorScheme),
            SizedBox(height: 3.h),
            _buildExpirationInfo(
              expirationDate,
              daysUntilExpiry,
              theme,
              colorScheme,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: CustomIconWidget(
                      iconName: 'visibility',
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    label: const Text('View Details'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRenew,
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                    label: const Text('Renew'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationBadge(
    bool isValid,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: isValid ? 'verified' : 'error',
            size: 16,
            color: isValid ? Colors.green : Colors.red,
          ),
          SizedBox(width: 1.w),
          Text(
            isValid ? 'Valid' : 'Invalid',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isValid ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateInfo(
    String domain,
    String issuer,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          'Domain',
          domain,
          CustomIconWidget(
            iconName: 'language',
            size: 20,
            color: colorScheme.primary,
          ),
          theme,
        ),
        SizedBox(height: 2.h),
        _buildInfoRow(
          'Issuer',
          issuer,
          CustomIconWidget(
            iconName: 'business',
            size: 20,
            color: colorScheme.primary,
          ),
          theme,
        ),
      ],
    );
  }

  Widget _buildExpirationInfo(
    String expirationDate,
    int daysUntilExpiry,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isExpiringSoon = daysUntilExpiry <= 30;
    final isExpired = daysUntilExpiry <= 0;

    Color statusColor;
    String statusText;

    if (isExpired) {
      statusColor = Colors.red;
      statusText = 'Expired';
    } else if (isExpiringSoon) {
      statusColor = Colors.orange;
      statusText = 'Expires Soon';
    } else {
      statusColor = Colors.green;
      statusText = 'Valid';
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                size: 20,
                color: statusColor,
              ),
              SizedBox(width: 2.w),
              Text(
                'Expiration',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: $expirationDate',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                isExpired ? 'Expired' : '$daysUntilExpiry days left',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Widget icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
