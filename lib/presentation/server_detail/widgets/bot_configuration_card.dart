import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BotConfigurationCard extends StatefulWidget {
  final List<Map<String, dynamic>> bots;
  final Function(int, bool)? onModeToggle;
  final VoidCallback? onAddBot;
  final Function(int)? onEditBot;

  const BotConfigurationCard({
    super.key,
    required this.bots,
    this.onModeToggle,
    this.onAddBot,
    this.onEditBot,
  });

  @override
  State<BotConfigurationCard> createState() => _BotConfigurationCardState();
}

class _BotConfigurationCardState extends State<BotConfigurationCard> {
  bool _isExpanded = true;

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
                        iconName: 'smart_toy',
                        size: 24,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Bot Configuration',
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
                          '${widget.bots.length} bots',
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
                  ...widget.bots.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bot = entry.value;
                    return _buildBotItem(bot, index, theme, colorScheme);
                  }),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAddBot,
                      icon: CustomIconWidget(
                        iconName: 'add',
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: const Text('Add New Bot'),
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

  Widget _buildBotItem(
    Map<String, dynamic> bot,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final name = (bot['name'] as String?) ?? 'Unknown Bot';
    final token = (bot['token'] as String?) ?? '';
    final isWebhook = (bot['isWebhook'] as bool?) ?? false;
    final status = (bot['status'] as String?) ?? 'inactive';
    final lastActivity = (bot['lastActivity'] as String?) ?? 'Never';

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
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Token: ${_maskToken(token)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status, colorScheme, theme),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        'Polling',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: !isWebhook
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight:
                              !isWebhook ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Switch(
                        value: isWebhook,
                        onChanged: (value) {
                          widget.onModeToggle?.call(index, value);
                        },
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Webhook',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isWebhook
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight:
                              isWebhook ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => widget.onEditBot?.call(index),
                icon: CustomIconWidget(
                  iconName: 'edit',
                  size: 20,
                  color: colorScheme.primary,
                ),
                tooltip: 'Edit Bot',
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Last activity: $lastActivity',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    String status,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case 'inactive':
        statusColor = Colors.grey;
        statusText = 'Inactive';
        break;
      case 'error':
        statusColor = Colors.red;
        statusText = 'Error';
        break;
      default:
        statusColor = colorScheme.onSurface.withValues(alpha: 0.5);
        statusText = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _maskToken(String token) {
    if (token.isEmpty) return 'Not set';
    if (token.length <= 8) return '••••••••';
    return '${token.substring(0, 4)}••••${token.substring(token.length - 4)}';
  }
}
