import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomAppBarVariant {
  primary,
  secondary,
  transparent,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.primary,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.systemOverlayStyle,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color effectiveBackgroundColor;
    Color effectiveForegroundColor;
    double effectiveElevation;
    SystemUiOverlayStyle effectiveSystemOverlayStyle;

    switch (variant) {
      case CustomAppBarVariant.primary:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
        effectiveElevation = elevation ?? 2.0;
        effectiveSystemOverlayStyle = systemOverlayStyle ??
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
        break;
      case CustomAppBarVariant.secondary:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
        effectiveElevation = elevation ?? 1.0;
        effectiveSystemOverlayStyle = systemOverlayStyle ??
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
        break;
      case CustomAppBarVariant.transparent:
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
        effectiveElevation = elevation ?? 0.0;
        effectiveSystemOverlayStyle = systemOverlayStyle ??
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
        break;
    }

    return AppBar(
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: effectiveForegroundColor,
        ),
      ),
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: effectiveElevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      systemOverlayStyle: effectiveSystemOverlayStyle,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                )
              : null),
      actions: _buildActions(context),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) {
      return actions;
    }

    // Default actions based on current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (currentRoute) {
      case '/server-dashboard':
        return [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh dashboard data
              HapticFeedback.lightImpact();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
              HapticFeedback.lightImpact();
            },
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              HapticFeedback.lightImpact();
              switch (value) {
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
                case 'logs':
                  Navigator.pushNamed(context, '/system-logs');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logs',
                child: Row(
                  children: [
                    Icon(Icons.article_outlined),
                    SizedBox(width: 8),
                    Text('System Logs'),
                  ],
                ),
              ),
            ],
          ),
        ];
      case '/server-detail':
        return [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Edit server configuration
            },
            tooltip: 'Edit Server',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show server actions menu
            },
            tooltip: 'More Actions',
          ),
        ];
      case '/ssl-certificate-management':
        return [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Add new certificate
            },
            tooltip: 'Add Certificate',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Filter certificates
            },
            tooltip: 'Filter',
          ),
        ];
      case '/bot-configuration':
        return [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Save configuration
            },
            tooltip: 'Save Configuration',
          ),
        ];
      case '/system-logs':
        return [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Export logs
            },
            tooltip: 'Export Logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Clear logs
            },
            tooltip: 'Clear Logs',
          ),
        ];
      case '/settings':
        return [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show help
            },
            tooltip: 'Help',
          ),
        ];
      default:
        return null;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
