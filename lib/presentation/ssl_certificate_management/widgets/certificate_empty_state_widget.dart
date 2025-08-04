import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CertificateEmptyStateWidget extends StatelessWidget {
  final VoidCallback? onImportCertificate;
  final bool isSearchResult;
  final String? searchQuery;

  const CertificateEmptyStateWidget({
    super.key,
    this.onImportCertificate,
    this.isSearchResult = false,
    this.searchQuery,
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
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isSearchResult ? 'search_off' : 'security',
                  color: colorScheme.primary,
                  size: 20.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              isSearchResult ? 'No certificates found' : 'No SSL Certificates',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              isSearchResult
                  ? searchQuery != null && searchQuery!.isNotEmpty
                      ? 'No certificates match "$searchQuery". Try adjusting your search terms or filters.'
                      : 'No certificates match your current filters. Try adjusting your filter criteria.'
                  : 'Secure your applications with SSL certificates. Import your first certificate to get started with encrypted connections.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            if (!isSearchResult) ...[
              ElevatedButton.icon(
                onPressed: onImportCertificate,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text(
                  'Import Your First Certificate',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              _buildSecurityFeatures(context, theme, colorScheme),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    label: const Text('Clear Search'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  ElevatedButton.icon(
                    onPressed: onImportCertificate,
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                    label: const Text('Add Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFeatures(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'SSL Certificate Benefits',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        _buildFeatureItem(
          context,
          theme,
          colorScheme,
          'Enhanced Security',
          'Encrypt data transmission between servers and clients',
          'lock',
        ),
        SizedBox(height: 1.5.h),
        _buildFeatureItem(
          context,
          theme,
          colorScheme,
          'Trust & Credibility',
          'Build user confidence with verified SSL certificates',
          'verified_user',
        ),
        SizedBox(height: 1.5.h),
        _buildFeatureItem(
          context,
          theme,
          colorScheme,
          'SEO Benefits',
          'Improve search engine rankings with HTTPS',
          'trending_up',
        ),
        SizedBox(height: 1.5.h),
        _buildFeatureItem(
          context,
          theme,
          colorScheme,
          'Compliance Ready',
          'Meet industry standards and regulatory requirements',
          'gavel',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String description,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
