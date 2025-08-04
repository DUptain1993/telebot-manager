import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedFilterModal extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>> onFiltersApplied;

  const AdvancedFilterModal({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<AdvancedFilterModal> createState() => _AdvancedFilterModalState();
}

class _AdvancedFilterModalState extends State<AdvancedFilterModal> {
  late Map<String, dynamic> _filters;
  late TextEditingController _customQueryController;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _customQueryController = TextEditingController(
      text: _filters['customQuery'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _customQueryController.dispose();
    super.dispose();
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _filters['dateRange'] as DateTimeRange?,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filters['dateRange'] = picked;
      });
    }
  }

  void _applyFilters() {
    _filters['customQuery'] = _customQueryController.text;
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _filters = {
        'sources': <String>[],
        'dateRange': null,
        'customQuery': '',
      };
      _customQueryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sources = _filters['sources'] as List<String>? ?? [];
    final dateRange = _filters['dateRange'] as DateTimeRange?;

    return Container(
      height: 80.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Header
          Row(
            children: [
              Text(
                'Advanced Filters',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Section
                  Text(
                    'Date Range',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'date_range',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            dateRange != null
                                ? '${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year} - ${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}'
                                : 'Select date range',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: dateRange != null
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          CustomIconWidget(
                            iconName: 'arrow_drop_down',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Log Sources Section
                  Text(
                    'Log Sources',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      'Server Core',
                      'SSL Manager',
                      'Bot Handler',
                      'Database',
                      'API Gateway',
                      'Security Monitor',
                      'File System',
                      'Network',
                    ].map((source) {
                      final isSelected = sources.contains(source);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              sources.remove(source);
                            } else {
                              sources.add(source);
                            }
                            _filters['sources'] = sources;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            source,
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 3.h),

                  // Custom Query Section
                  Text(
                    'Custom Query',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _customQueryController,
                    maxLines: 3,
                    style: AppTheme.dataTextStyle(isLight: true),
                    decoration: InputDecoration(
                      hintText: 'Enter custom search query (regex supported)',
                      hintStyle:
                          AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
