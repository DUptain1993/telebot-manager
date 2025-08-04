import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EnvironmentVariablesCard extends StatefulWidget {
  final List<Map<String, dynamic>> variables;
  final Function(int)? onEdit;
  final VoidCallback? onAdd;
  final Function(int)? onDelete;

  const EnvironmentVariablesCard({
    super.key,
    required this.variables,
    this.onEdit,
    this.onAdd,
    this.onDelete,
  });

  @override
  State<EnvironmentVariablesCard> createState() =>
      _EnvironmentVariablesCardState();
}

class _EnvironmentVariablesCardState extends State<EnvironmentVariablesCard> {
  bool _isExpanded = true;
  final Set<int> _visibleValues = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        size: 24,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Environment Variables',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.variables.length} vars',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: _isExpanded ? 'expand_less' : 'expand_more',
                        size: 24,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  ...widget.variables.asMap().entries.map((entry) {
                    final index = entry.key;
                    final variable = entry.value;
                    return _buildVariableItem(
                        variable, index, theme, colorScheme);
                  }),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAdd,
                      icon: CustomIconWidget(
                        iconName: 'add',
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: const Text('Add Variable'),
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

  Widget _buildVariableItem(
    Map<String, dynamic> variable,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final key = (variable['key'] as String?) ?? '';
    final value = (variable['value'] as String?) ?? '';
    final isSecret = (variable['isSecret'] as bool?) ?? false;
    final description = (variable['description'] as String?) ?? '';
    final isVisible = _visibleValues.contains(index);

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          key,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSecret) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 1.5.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'SECRET',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: CustomIconWidget(
                  iconName: 'more_vert',
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onSelected: (value) {
                  HapticFeedback.lightImpact();
                  switch (value) {
                    case 'edit':
                      widget.onEdit?.call(index);
                      break;
                    case 'copy':
                      _copyToClipboard(value, context);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context, index);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copy Value'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isSecret && !isVisible ? _maskValue(value) : value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: isSecret && !isVisible
                          ? colorScheme.onSurface.withValues(alpha: 0.6)
                          : colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSecret) ...[
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isVisible) {
                          _visibleValues.remove(index);
                        } else {
                          _visibleValues.add(index);
                        }
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: CustomIconWidget(
                      iconName: isVisible ? 'visibility_off' : 'visibility',
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () => _copyToClipboard(value, context),
                  child: CustomIconWidget(
                    iconName: 'copy',
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskValue(String value) {
    if (value.isEmpty) return '';
    if (value.length <= 8) return '••••••••';
    return '${value.substring(0, 2)}••••••••${value.substring(value.length - 2)}';
  }

  void _copyToClipboard(String value, BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Value copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    HapticFeedback.lightImpact();
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Variable'),
        content: const Text(
            'Are you sure you want to delete this environment variable? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call(index);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
