import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/alert_banner_widget.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/server_card_widget.dart';
import './widgets/status_indicator_widget.dart';
import 'widgets/alert_banner_widget.dart';
import 'widgets/dashboard_header_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/server_card_widget.dart';
import 'widgets/status_indicator_widget.dart';

class ServerDashboard extends StatefulWidget {
  const ServerDashboard({super.key});

  @override
  State<ServerDashboard> createState() => _ServerDashboardState();
}

class _ServerDashboardState extends State<ServerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  bool _isSecureConnection = true;
  bool _isOnline = true;
  String _currentUser = 'admin@securebot.com';
  List<Map<String, dynamic>> _alerts = [];

  // Mock server data
  final List<Map<String, dynamic>> _servers = [
    {
      "id": 1,
      "name": "Production Bot Server",
      "environment": "prod",
      "status": "healthy",
      "botCount": 5,
      "sslStatus": "valid",
      "lastUpdate": "2 min ago",
      "uptime": "99.9%",
      "location": "US-East-1",
    },
    {
      "id": 2,
      "name": "Development Server",
      "environment": "dev",
      "status": "warning",
      "botCount": 2,
      "sslStatus": "expiring",
      "lastUpdate": "5 min ago",
      "uptime": "98.5%",
      "location": "US-West-2",
    },
    {
      "id": 3,
      "name": "Staging Environment",
      "environment": "staging",
      "status": "healthy",
      "botCount": 3,
      "sslStatus": "valid",
      "lastUpdate": "1 min ago",
      "uptime": "99.2%",
      "location": "EU-Central-1",
    },
    {
      "id": 4,
      "name": "Testing Server",
      "environment": "test",
      "status": "critical",
      "botCount": 1,
      "sslStatus": "expired",
      "lastUpdate": "15 min ago",
      "uptime": "85.3%",
      "location": "Asia-Pacific-1",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeAlerts() {
    _alerts = [
      {
        "id": 1,
        "type": "warning",
        "message": "SSL certificate for Development Server expires in 7 days",
        "actionLabel": "Renew Now",
      },
      {
        "id": 2,
        "type": "critical",
        "message": "Testing Server is experiencing high error rates",
        "actionLabel": "View Logs",
      },
    ];
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        // Update last sync time in servers
        for (var server in _servers) {
          server['lastUpdate'] = 'Just now';
        }
      });

      HapticFeedback.lightImpact();
    }
  }

  void _handleAddServer() {
    HapticFeedback.mediumImpact();
    _showAddServerDialog();
  }

  void _handleServerTap(Map<String, dynamic> server) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/server-detail',
      arguments: server,
    );
  }

  void _handleViewLogs(Map<String, dynamic> server) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/system-logs',
      arguments: {'serverId': server['id']},
    );
  }

  void _handleTestConnection(Map<String, dynamic> server) {
    HapticFeedback.mediumImpact();
    _showConnectionTestDialog(server);
  }

  void _handleEmergencyStop(Map<String, dynamic> server) {
    HapticFeedback.heavyImpact();
    _showEmergencyStopDialog(server);
  }

  void _handleConfigure(Map<String, dynamic> server) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/bot-configuration',
      arguments: {'serverId': server['id']},
    );
  }

  void _handleRemoveServer(Map<String, dynamic> server) {
    HapticFeedback.mediumImpact();
    _showRemoveServerDialog(server);
  }

  void _handleAlertAction(Map<String, dynamic> alert) {
    HapticFeedback.lightImpact();

    switch (alert['type']) {
      case 'warning':
        Navigator.pushNamed(context, '/ssl-certificate-management');
        break;
      case 'critical':
        Navigator.pushNamed(context, '/system-logs');
        break;
    }
  }

  void _handleAlertDismiss(Map<String, dynamic> alert) {
    HapticFeedback.lightImpact();
    setState(() {
      _alerts.removeWhere((a) => a['id'] == alert['id']);
    });
  }

  void _handleTabChange(int index) {
    HapticFeedback.lightImpact();

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/ssl-certificate-management');
        break;
      case 2:
        Navigator.pushNamed(context, '/bot-configuration');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            StatusIndicatorWidget(
              isSecureConnection: _isSecureConnection,
              currentUser: _currentUser,
              isOnline: _isOnline,
            ),
            _buildTabBar(context, colorScheme),
            Expanded(
              child: _buildDashboardContent(context, colorScheme),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, colorScheme),
    );
  }

  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: _handleTabChange,
        tabs: const [
          Tab(
            icon: Icon(Icons.dashboard_outlined),
            text: 'Dashboard',
          ),
          Tab(
            icon: Icon(Icons.security_outlined),
            text: 'Certificates',
          ),
          Tab(
            icon: Icon(Icons.smart_toy_outlined),
            text: 'Bots',
          ),
          Tab(
            icon: Icon(Icons.settings_outlined),
            text: 'Settings',
          ),
        ],
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DashboardHeaderWidget(
              onAddServer: _handleAddServer,
              isConnected: _isOnline,
              onRefresh: _handleRefresh,
            ),
          ),
          if (_alerts.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                children: _alerts
                    .map((alert) => AlertBannerWidget(
                          message: alert['message'],
                          type: alert['type'],
                          actionLabel: alert['actionLabel'],
                          onAction: () => _handleAlertAction(alert),
                          onDismiss: () => _handleAlertDismiss(alert),
                        ))
                    .toList(),
              ),
            ),
          _servers.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    onAddServer: _handleAddServer,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final server = _servers[index];
                      return ServerCardWidget(
                        server: server,
                        onTap: () => _handleServerTap(server),
                        onViewLogs: () => _handleViewLogs(server),
                        onTestConnection: () => _handleTestConnection(server),
                        onEmergencyStop: () => _handleEmergencyStop(server),
                        onConfigure: () => _handleConfigure(server),
                        onRemove: () => _handleRemoveServer(server),
                      );
                    },
                    childCount: _servers.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h), // Bottom padding for FAB
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, ColorScheme colorScheme) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showQuickDeployDialog();
        },
        icon: CustomIconWidget(
          iconName: 'rocket_launch',
          color: colorScheme.onSecondary,
          size: 20,
        ),
        label: Text(
          'Quick Deploy',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      );
    }
    return null;
  }

  void _showAddServerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Server'),
        content: const Text('This will open the server configuration wizard.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to server configuration
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showConnectionTestDialog(Map<String, dynamic> server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Connection'),
        content: Text('Testing connection to ${server['name']}...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyStopDialog(Map<String, dynamic> server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Stop'),
        content: Text(
            'Are you sure you want to stop ${server['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform emergency stop
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Stop Server'),
          ),
        ],
      ),
    );
  }

  void _showRemoveServerDialog(Map<String, dynamic> server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Server'),
        content: Text('Are you sure you want to remove ${server['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _servers.removeWhere((s) => s['id'] == server['id']);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showQuickDeployDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Deploy'),
        content:
            const Text('Deploy a new bot server with default configuration?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform quick deploy
            },
            child: const Text('Deploy'),
          ),
        ],
      ),
    );
  }
}