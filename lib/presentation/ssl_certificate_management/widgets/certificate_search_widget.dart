import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CertificateSearchWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final VoidCallback? onClearSearch;

  const CertificateSearchWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    this.onClearSearch,
  });

  @override
  State<CertificateSearchWidget> createState() =>
      _CertificateSearchWidgetState();
}

class _CertificateSearchWidgetState extends State<CertificateSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSearchActive
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: _isSearchActive ? 2 : 1,
                    ),
                    boxShadow: _isSearchActive
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      widget.onSearchChanged(value);
                      setState(() {
                        _isSearchActive = value.isNotEmpty;
                      });
                    },
                    onTap: () => setState(() => _isSearchActive = true),
                    onSubmitted: (value) =>
                        setState(() => _isSearchActive = value.isNotEmpty),
                    decoration: InputDecoration(
                      hintText:
                          'Search certificates by domain or expiration...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color: _isSearchActive
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                      suffixIcon: _isSearchActive
                          ? InkWell(
                              onTap: () {
                                _searchController.clear();
                                widget.onSearchChanged('');
                                widget.onClearSearch?.call();
                                setState(() => _isSearchActive = false);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                  iconName: 'clear',
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  size: 20,
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 3.w,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              InkWell(
                onTap: () => _showFilterOptions(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _selectedFilter != 'all'
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedFilter != 'all'
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'filter_list',
                    color: _selectedFilter != 'all'
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedFilter != 'all') ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'filter_alt',
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Filtered by: ${_getFilterDisplayName(_selectedFilter)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedFilter = 'all');
                      widget.onFilterChanged('all');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(1.w),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: colorScheme.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              margin: EdgeInsets.only(bottom: 3.h),
              alignment: Alignment.center,
            ),
            Text(
              'Filter Certificates',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildFilterOption(
              context,
              'all',
              'All Certificates',
              'Show all certificates',
              'list',
            ),
            _buildFilterOption(
              context,
              'valid',
              'Valid Certificates',
              'Show only valid certificates',
              'verified',
            ),
            _buildFilterOption(
              context,
              'expiring',
              'Expiring Soon',
              'Certificates expiring within 30 days',
              'warning',
            ),
            _buildFilterOption(
              context,
              'expired',
              'Expired Certificates',
              'Show only expired certificates',
              'error',
            ),
            _buildFilterOption(
              context,
              'wildcard',
              'Wildcard Certificates',
              'Show only wildcard certificates',
              'star',
            ),
            _buildFilterOption(
              context,
              'auto_renew',
              'Auto-Renew Enabled',
              'Certificates with auto-renewal',
              'autorenew',
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String value,
    String title,
    String subtitle,
    String iconName,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedFilter == value;

    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = value);
        widget.onFilterChanged(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
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
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.8)
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'valid':
        return 'Valid Certificates';
      case 'expiring':
        return 'Expiring Soon';
      case 'expired':
        return 'Expired Certificates';
      case 'wildcard':
        return 'Wildcard Certificates';
      case 'auto_renew':
        return 'Auto-Renew Enabled';
      default:
        return 'All Certificates';
    }
  }
}
