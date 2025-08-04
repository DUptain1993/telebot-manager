import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CertificateCardWidget extends StatelessWidget {
  final Map<String, dynamic> certificate;
  final VoidCallback? onTap;
  final VoidCallback? onRenew;
  final VoidCallback? onDownload;
  final VoidCallback? onTest;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;

  const CertificateCardWidget({
    super.key,
    required this.certificate,
    this.onTap,
    this.onRenew,
    this.onDownload,
    this.onTest,
    this.onDelete,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = certificate['status'] as String;
    final expiryDate = certificate['expiryDate'] as DateTime;
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(certificate['id'].toString()),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Quick actions
          _showQuickActions(context);
        } else {
          // Swipe left - Delete/Export actions
          _showDeleteExportActions(context);
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getStatusColor(status, colorScheme).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate['domain'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            certificate['issuer'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status, colorScheme),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: _getExpiryColor(daysUntilExpiry, colorScheme),
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _getExpiryText(daysUntilExpiry),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getExpiryColor(daysUntilExpiry, colorScheme),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (certificate['autoRenew'] == true) ...[
                      CustomIconWidget(
                        iconName: 'autorenew',
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Auto-renew',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${certificate['keySize']} bit ${certificate['algorithm']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    if (certificate['wildcardCert'] == true) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Wildcard',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? colorScheme.error : colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeft
                ? [
                    CustomIconWidget(
                      iconName: 'delete',
                      color: colorScheme.onError,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'file_download',
                      color: colorScheme.onError,
                      size: 24,
                    ),
                  ]
                : [
                    CustomIconWidget(
                      iconName: 'refresh',
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'download',
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'verified',
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(status, colorScheme);
    final statusText = status.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'valid':
        return Colors.green;
      case 'expiring':
        return Colors.orange;
      case 'expired':
        return colorScheme.error;
      case 'revoked':
        return colorScheme.error;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  Color _getExpiryColor(int daysUntilExpiry, ColorScheme colorScheme) {
    if (daysUntilExpiry < 0) {
      return colorScheme.error;
    } else if (daysUntilExpiry <= 30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getExpiryText(int daysUntilExpiry) {
    if (daysUntilExpiry < 0) {
      return 'Expired ${(-daysUntilExpiry)} days ago';
    } else if (daysUntilExpiry == 0) {
      return 'Expires today';
    } else if (daysUntilExpiry == 1) {
      return 'Expires tomorrow';
    } else if (daysUntilExpiry <= 30) {
      return 'Expires in $daysUntilExpiry days';
    } else {
      return 'Expires in $daysUntilExpiry days';
    }
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'refresh',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Renew Certificate'),
              onTap: () {
                Navigator.pop(context);
                onRenew?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Download Certificate'),
              onTap: () {
                Navigator.pop(context);
                onDownload?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'verified',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Test Validation'),
              onTap: () {
                Navigator.pop(context);
                onTest?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteExportActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Export Certificate'),
              onTap: () {
                Navigator.pop(context);
                onExport?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Delete Certificate'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text(
            'Are you sure you want to delete the certificate for ${certificate['domain']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
