import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EnvironmentVariablesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> variables;
  final ValueChanged<List<Map<String, dynamic>>>? onVariablesChanged;

  const EnvironmentVariablesWidget({
    super.key,
    required this.variables,
    this.onVariablesChanged,
  });

  @override
  State<EnvironmentVariablesWidget> createState() =>
      _EnvironmentVariablesWidgetState();
}

class _EnvironmentVariablesWidgetState
    extends State<EnvironmentVariablesWidget> {
  late List<Map<String, dynamic>> _variables;
  final Map<int, bool> _visibilityStates = {};

  @override
  void initState() {
    super.initState();
    _variables = List.from(widget.variables);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, colorScheme),
            SizedBox(height: 3.h),
            if (_variables.isEmpty)
              _buildEmptyState(context, colorScheme)
            else
              _buildVariablesList(context, colorScheme),
            SizedBox(height: 3.h),
            _buildAddButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'settings',
          color: colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Environment Variables',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Manage bot-specific configuration variables',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_variables.length} vars',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'code',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Environment Variables',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add environment variables to configure your bot',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVariablesList(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: _variables.asMap().entries.map((entry) {
        final index = entry.key;
        final variable = entry.value;
        return _buildVariableItem(context, colorScheme, variable, index);
      }).toList(),
    );
  }

  Widget _buildVariableItem(BuildContext context, ColorScheme colorScheme,
      Map<String, dynamic> variable, int index) {
    final isSecret = variable["isSecret"] as bool? ?? false;
    final isVisible = _visibilityStates[index] ?? false;
    final key = variable["key"] as String;
    final value = variable["value"] as String;
    final description = variable["description"] as String? ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: isSecret ? 'lock' : 'code',
                          color: isSecret
                              ? AppTheme.getStatusColor('warning',
                                  isLight: Theme.of(context).brightness ==
                                      Brightness.light)
                              : colorScheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            key,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: CustomIconWidget(
                  iconName: 'more_vert',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                onSelected: (action) =>
                    _handleVariableAction(context, action, index),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: colorScheme.onSurface,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'copy',
                          color: colorScheme.onSurface,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        const Text('Copy Value'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'delete',
                          color: AppTheme.getStatusColor('error',
                              isLight: Theme.of(context).brightness ==
                                  Brightness.light),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: AppTheme.getStatusColor('error',
                                isLight: Theme.of(context).brightness ==
                                    Brightness.light),
                          ),
                        ),
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
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isSecret && !isVisible ? '•' * 12 : value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: isSecret && !isVisible
                              ? colorScheme.onSurface.withValues(alpha: 0.4)
                              : colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSecret)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _visibilityStates[index] = !isVisible;
                      });
                      HapticFeedback.lightImpact();
                    },
                    icon: CustomIconWidget(
                      iconName: isVisible ? 'visibility_off' : 'visibility',
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: isVisible ? 'Hide value' : 'Show value',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddVariableDialog(context),
        icon: CustomIconWidget(
          iconName: 'add',
          color: colorScheme.primary,
          size: 20,
        ),
        label: const Text('Add Variable'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 3.h),
        ),
      ),
    );
  }

  void _handleVariableAction(BuildContext context, String action, int index) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'edit':
        _showEditVariableDialog(context, index);
        break;
      case 'copy':
        _copyVariableValue(index);
        break;
      case 'delete':
        _showDeleteConfirmation(context, index);
        break;
    }
  }

  void _showAddVariableDialog(BuildContext context) {
    _showVariableDialog(context, isEdit: false);
  }

  void _showEditVariableDialog(BuildContext context, int index) {
    _showVariableDialog(context, isEdit: true, index: index);
  }

  void _showVariableDialog(BuildContext context,
      {required bool isEdit, int? index}) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isSecret = false;

    if (isEdit && index != null) {
      final variable = _variables[index];
      keyController.text = variable["key"] as String;
      valueController.text = variable["value"] as String;
      descriptionController.text = variable["description"] as String? ?? '';
      isSecret = variable["isSecret"] as bool? ?? false;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Variable' : 'Add Variable'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Variable Name',
                    hintText: 'API_KEY',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'Enter variable value',
                  ),
                  obscureText: isSecret,
                  maxLines: isSecret ? 1 : 3,
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief description of this variable',
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Checkbox(
                      value: isSecret,
                      onChanged: (value) {
                        setDialogState(() {
                          isSecret = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            isSecret = !isSecret;
                          });
                        },
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'security',
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            const Text('Secret Variable'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSecret) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Secret variables are encrypted and masked by default',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  final variable = {
                    'key': keyController.text.toUpperCase(),
                    'value': valueController.text,
                    'description': descriptionController.text,
                    'isSecret': isSecret,
                    'createdAt': DateTime.now().toIso8601String(),
                  };

                  setState(() {
                    if (isEdit && index != null) {
                      _variables[index] = variable;
                    } else {
                      _variables.add(variable);
                    }
                  });

                  widget.onVariablesChanged?.call(_variables);
                  Navigator.pop(context);

                  _showSuccessSnackBar(
                      isEdit ? 'Variable updated' : 'Variable added');
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyVariableValue(int index) {
    final value = _variables[index]["value"] as String;
    Clipboard.setData(ClipboardData(text: value));
    _showSuccessSnackBar('Variable value copied to clipboard');
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    final variableName = _variables[index]["key"] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Variable'),
        content: Text(
            'Are you sure you want to delete "$variableName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _variables.removeAt(index);
                _visibilityStates.remove(index);
              });

              widget.onVariablesChanged?.call(_variables);
              Navigator.pop(context);

              HapticFeedback.mediumImpact();
              _showSuccessSnackBar('Variable deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getStatusColor('error',
                  isLight: Theme.of(context).brightness == Brightness.light),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.getStatusColor('success',
            isLight: Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
