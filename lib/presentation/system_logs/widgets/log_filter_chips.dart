import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogFilterChips extends StatelessWidget {
  final List<String> selectedFilters;
  final ValueChanged<List<String>> onFiltersChanged;

  const LogFilterChips({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  static const List<Map<String, dynamic>> _filterOptions = [
    {
      'label': 'Error',
      'value': 'error',
      'icon': 'error',
      'color': 'error',
    },
    {
      'label': 'Warning',
      'value': 'warning',
      'icon': 'warning',
      'color': 'warning',
    },
    {
      'label': 'Info',
      'value': 'info',
      'icon': 'info',
      'color': 'info',
    },
    {
      'label': 'Debug',
      'value': 'debug',
      'icon': 'bug_report',
      'color': 'debug',
    },
  ];

  Color _getFilterColor(String colorType) {
    switch (colorType) {
      case 'error':
        return AppTheme.lightTheme.colorScheme.error;
      case 'warning':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'info':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'debug':
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _toggleFilter(String filterValue) {
    final List<String> newFilters = List.from(selectedFilters);
    if (newFilters.contains(filterValue)) {
      newFilters.remove(filterValue);
    } else {
      newFilters.add(filterValue);
    }
    onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = selectedFilters.contains(filter['value']);
          final filterColor = _getFilterColor(filter['color']);

          return GestureDetector(
            onTap: () => _toggleFilter(filter['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? filterColor
                    : filterColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: filterColor,
                  width: isSelected ? 0 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: filter['icon'],
                    color: isSelected ? Colors.white : filterColor,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    filter['label'],
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : filterColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
