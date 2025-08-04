import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;
  final VoidCallback? onCustomDatePicker;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.onCustomDatePicker,
  });

  static const List<Map<String, String>> _timeRanges = [
    {'label': 'Last Hour', 'value': 'hour'},
    {'label': 'Today', 'value': 'today'},
    {'label': 'Week', 'value': 'week'},
    {'label': 'Custom', 'value': 'custom'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _timeRanges.length,
              separatorBuilder: (context, index) => SizedBox(width: 2.w),
              itemBuilder: (context, index) {
                final range = _timeRanges[index];
                final isSelected = selectedRange == range['value'];

                return GestureDetector(
                  onTap: () {
                    if (range['value'] == 'custom') {
                      onCustomDatePicker?.call();
                    } else {
                      onRangeChanged(range['value']!);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                      range['label']!,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
