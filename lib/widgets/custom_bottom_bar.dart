import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final CustomBottomBarVariant variant;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    this.variant = CustomBottomBarVariant.standard,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
  });

  static const List<_BottomNavItem> _navItems = [
    _BottomNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/server-dashboard',
    ),
    _BottomNavItem(
      icon: Icons.security_outlined,
      selectedIcon: Icons.security,
      label: 'SSL Certs',
      route: '/ssl-certificate-management',
    ),
    _BottomNavItem(
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy,
      label: 'Bot Config',
      route: '/bot-configuration',
    ),
    _BottomNavItem(
      icon: Icons.article_outlined,
      selectedIcon: Icons.article,
      label: 'Logs',
      route: '/system-logs',
    ),
    _BottomNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomBottomBarVariant.standard:
        return _buildStandardBottomBar(context, theme, colorScheme);
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, colorScheme);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      selectedItemColor: selectedItemColor ?? colorScheme.primary,
      unselectedItemColor:
          unselectedItemColor ?? colorScheme.onSurface.withValues(alpha: 0.6),
      elevation: elevation ?? 8.0,
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
      unselectedLabelStyle: theme.bottomNavigationBarTheme.unselectedLabelStyle,
      items: _navItems
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.selectedIcon),
                label: item.label,
                tooltip: item.label,
              ))
          .toList(),
    );
  }

  Widget _buildFloatingBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _handleTap(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: selectedItemColor ?? colorScheme.primary,
          unselectedItemColor: unselectedItemColor ??
              colorScheme.onSurface.withValues(alpha: 0.6),
          elevation: 0.0,
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
          unselectedLabelStyle:
              theme.bottomNavigationBarTheme.unselectedLabelStyle,
          items: _navItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.selectedIcon),
                    label: item.label,
                    tooltip: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => _handleTap(context, index),
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected
                          ? (selectedItemColor ?? colorScheme.primary)
                          : (unselectedItemColor ??
                              colorScheme.onSurface.withValues(alpha: 0.6)),
                      size: 24.0,
                    ),
                    if (showLabels) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        item.label,
                        style: (isSelected
                                ? theme
                                    .bottomNavigationBarTheme.selectedLabelStyle
                                : theme.bottomNavigationBarTheme
                                    .unselectedLabelStyle)
                            ?.copyWith(
                          color: isSelected
                              ? (selectedItemColor ?? colorScheme.primary)
                              : (unselectedItemColor ??
                                  colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    HapticFeedback.lightImpact();

    if (onTap != null) {
      onTap!(index);
    } else {
      // Default navigation behavior
      final route = _navItems[index].route;
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }

  static int getIndexForRoute(String? routeName) {
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].route == routeName) {
        return i;
      }
    }
    return 0; // Default to dashboard
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
