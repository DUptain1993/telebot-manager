import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTabBarVariant {
  primary,
  secondary,
  segmented,
  pills,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CustomTab> tabs;
  final TabController? controller;
  final CustomTabBarVariant variant;
  final bool isScrollable;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double? indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onTap;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.variant = CustomTabBarVariant.primary,
    this.isScrollable = false,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight,
    this.labelPadding,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomTabBarVariant.primary:
        return _buildPrimaryTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.secondary:
        return _buildSecondaryTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context, theme, colorScheme);
    }
  }

  Widget _buildPrimaryTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      color: backgroundColor ?? colorScheme.primary,
      padding: padding,
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => Tab(
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                  text: tab.label,
                  child: tab.child,
                ))
            .toList(),
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.onPrimary,
        labelColor: labelColor ?? colorScheme.onPrimary,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onPrimary.withValues(alpha: 0.7),
        indicatorWeight: indicatorWeight ?? 3.0,
        labelPadding: labelPadding,
        labelStyle: theme.tabBarTheme.labelStyle,
        unselectedLabelStyle: theme.tabBarTheme.unselectedLabelStyle,
        onTap: (index) {
          HapticFeedback.lightImpact();
          onTap?.call(index);
        },
      ),
    );
  }

  Widget _buildSecondaryTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => Tab(
                  icon: tab.icon != null ? Icon(tab.icon) : null,
                  text: tab.label,
                  child: tab.child,
                ))
            .toList(),
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorWeight: indicatorWeight ?? 2.0,
        labelPadding: labelPadding,
        labelStyle: theme.tabBarTheme.labelStyle,
        unselectedLabelStyle: theme.tabBarTheme.unselectedLabelStyle,
        onTap: (index) {
          HapticFeedback.lightImpact();
          onTap?.call(index);
        },
      ),
    );
  }

  Widget _buildSegmentedTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      color: backgroundColor ?? colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: TabBar(
          controller: controller,
          tabs: tabs
              .map((tab) => Tab(
                    icon: tab.icon != null ? Icon(tab.icon) : null,
                    text: tab.label,
                    child: tab.child,
                  ))
              .toList(),
          isScrollable: isScrollable,
          indicator: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(6.0),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: labelColor ?? colorScheme.onPrimary,
          unselectedLabelColor: unselectedLabelColor ??
              colorScheme.onSurface.withValues(alpha: 0.6),
          labelPadding: labelPadding,
          labelStyle: theme.tabBarTheme.labelStyle,
          unselectedLabelStyle: theme.tabBarTheme.unselectedLabelStyle,
          dividerColor: Colors.transparent,
          onTap: (index) {
            HapticFeedback.lightImpact();
            onTap?.call(index);
          },
        ),
      ),
    );
  }

  Widget _buildPillsTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: backgroundColor ?? colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = controller?.index == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller?.animateTo(index);
                  onTap?.call(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (indicatorColor ?? colorScheme.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isSelected
                          ? (indicatorColor ?? colorScheme.primary)
                          : colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: 16.0,
                          color: isSelected
                              ? (labelColor ?? colorScheme.onPrimary)
                              : (unselectedLabelColor ??
                                  colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        if (tab.label != null) const SizedBox(width: 4.0),
                      ],
                      if (tab.label != null)
                        Text(
                          tab.label!,
                          style: (isSelected
                                  ? theme.tabBarTheme.labelStyle
                                  : theme.tabBarTheme.unselectedLabelStyle)
                              ?.copyWith(
                            color: isSelected
                                ? (labelColor ?? colorScheme.onPrimary)
                                : (unselectedLabelColor ??
                                    colorScheme.onSurface
                                        .withValues(alpha: 0.6)),
                          ),
                        ),
                      if (tab.child != null) tab.child!,
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomTab {
  final String? label;
  final IconData? icon;
  final Widget? child;

  const CustomTab({
    this.label,
    this.icon,
    this.child,
  }) : assert(label != null || icon != null || child != null,
            'At least one of label, icon, or child must be provided');
}

// Predefined tab configurations for common use cases
class CustomTabConfigurations {
  static const List<CustomTab> serverManagementTabs = [
    CustomTab(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
    ),
    CustomTab(
      label: 'Performance',
      icon: Icons.analytics_outlined,
    ),
    CustomTab(
      label: 'Security',
      icon: Icons.security_outlined,
    ),
    CustomTab(
      label: 'Logs',
      icon: Icons.article_outlined,
    ),
  ];

  static const List<CustomTab> certificateManagementTabs = [
    CustomTab(
      label: 'Active',
      icon: Icons.verified_outlined,
    ),
    CustomTab(
      label: 'Expiring',
      icon: Icons.warning_outlined,
    ),
    CustomTab(
      label: 'Expired',
      icon: Icons.error_outline,
    ),
    CustomTab(
      label: 'All',
      icon: Icons.list_outlined,
    ),
  ];

  static const List<CustomTab> systemLogsTabs = [
    CustomTab(
      label: 'Application',
      icon: Icons.apps_outlined,
    ),
    CustomTab(
      label: 'System',
      icon: Icons.computer_outlined,
    ),
    CustomTab(
      label: 'Security',
      icon: Icons.shield_outlined,
    ),
    CustomTab(
      label: 'Errors',
      icon: Icons.bug_report_outlined,
    ),
  ];

  static const List<CustomTab> botConfigurationTabs = [
    CustomTab(
      label: 'General',
      icon: Icons.settings_outlined,
    ),
    CustomTab(
      label: 'Notifications',
      icon: Icons.notifications_outlined,
    ),
    CustomTab(
      label: 'Integrations',
      icon: Icons.extension_outlined,
    ),
    CustomTab(
      label: 'Advanced',
      icon: Icons.tune_outlined,
    ),
  ];
}