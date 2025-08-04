import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogEntryCard extends StatefulWidget {
  final Map<String, dynamic> logEntry;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;
  final VoidCallback? onMarkImportant;
  final VoidCallback? onFilterBySource;

  const LogEntryCard({
    super.key,
    required this.logEntry,
    this.onShare,
    this.onCopy,
    this.onMarkImportant,
    this.onFilterBySource,
  });

  @override
  State<LogEntryCard> createState() => _LogEntryCardState();
}

class _LogEntryCardState extends State<LogEntryCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getSeverityColor() {
    final severity = (widget.logEntry['severity'] as String).toLowerCase();
    switch (severity) {
      case 'error':
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'warning':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'info':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'debug':
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
      default:
        return AppTheme.lightTheme.colorScheme.onSurface;
    }
  }

  IconData _getSeverityIcon() {
    final severity = (widget.logEntry['severity'] as String).toLowerCase();
    switch (severity) {
      case 'error':
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'debug':
        return Icons.bug_report;
      default:
        return Icons.circle;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Share Log Entry',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onShare?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Copy to Clipboard',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onCopy?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'star_border',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 24,
              ),
              title: Text(
                'Mark Important',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onMarkImportant?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'filter_list',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Filter by Source',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onFilterBySource?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(widget.logEntry['timestamp'] as String);
    final message = widget.logEntry['message'] as String;
    final source = widget.logEntry['source'] as String;
    final severity = widget.logEntry['severity'] as String;
    final isImportant = widget.logEntry['isImportant'] as bool? ?? false;
    final isCritical = severity.toLowerCase() == 'critical' ||
        severity.toLowerCase() == 'error';

    return Dismissible(
      key: Key(widget.logEntry['id'].toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Share',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        widget.onShare?.call();
      },
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isCritical
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.error,
                    width: 2,
                  )
                : Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow
                    .withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: _getSeverityColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: _getSeverityIcon().codePoint.toString(),
                        color: _getSeverityColor(),
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor()
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  severity.toUpperCase(),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: _getSeverityColor(),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              if (isImportant)
                                CustomIconWidget(
                                  iconName: 'star',
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                  size: 16,
                                ),
                              const Spacer(),
                              Text(
                                '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _isExpanded
                                ? message
                                : (message.length > 100
                                    ? '${message.substring(0, 100)}...'
                                    : message),
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isCritical
                                  ? AppTheme.lightTheme.colorScheme.error
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            maxLines: _isExpanded ? null : 2,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'source',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                source,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const Spacer(),
                              if (message.length > 100)
                                GestureDetector(
                                  onTap: _toggleExpanded,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isExpanded ? 'Collapse' : 'Expand',
                                          style: AppTheme
                                              .lightTheme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 1.w),
                                        AnimatedRotation(
                                          turns: _isExpanded ? 0.5 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: CustomIconWidget(
                                            iconName: 'expand_more',
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isExpanded && widget.logEntry['details'] != null)
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Details:',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          widget.logEntry['details'] as String,
                          style: AppTheme.dataTextStyle(
                            isLight: true,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
