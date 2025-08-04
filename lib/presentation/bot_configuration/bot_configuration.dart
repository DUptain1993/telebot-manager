import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/api_integration_widget.dart';
import './widgets/bot_card_widget.dart';
import './widgets/environment_variables_widget.dart';
import './widgets/performance_analytics_widget.dart';
import './widgets/webhook_config_widget.dart';

class BotConfiguration extends StatefulWidget {
  const BotConfiguration({super.key});

  @override
  State<BotConfiguration> createState() => _BotConfigurationState();
}

class _BotConfigurationState extends State<BotConfiguration>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 2; // Bot Configuration tab index

  // Mock data for bots
  final List<Map<String, dynamic>> _bots = [
    {
      "id": 1,
      "name": "Customer Support Bot",
      "token": "1234567890:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw",
      "description":
          "Handles customer inquiries and support tickets with AI-powered responses",
      "status": "Active",
      "mode": "Webhook",
      "messageCount": 1247,
      "lastActivity": "2 min ago",
    },
    {
      "id": 2,
      "name": "Sales Assistant Bot",
      "token": "9876543210:BBGdqTcvCH1vGWJxfSeofSAs0K5PALDsaw",
      "description": "Assists with product information and sales inquiries",
      "status": "Inactive",
      "mode": "Polling",
      "messageCount": 892,
      "lastActivity": "1 hour ago",
    },
    {
      "id": 3,
      "name": "Analytics Bot",
      "token": "5555555555:CCHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw",
      "description":
          "Provides real-time analytics and reporting for business metrics",
      "status": "Active",
      "mode": "Webhook",
      "messageCount": 2156,
      "lastActivity": "Just now",
    },
  ];

  // Mock webhook configuration
  Map<String, dynamic> _webhookConfig = {
    "url": "https://api.securebot.com/webhook/telegram",
    "secret": "webhook_secret_token_12345",
    "isValid": true,
    "sslValid": true,
    "lastValidated": "2025-01-04T21:15:00.000Z",
  };

  // Mock API integration configuration
  Map<String, dynamic> _apiConfig = {
    "provider": "Venice AI",
    "endpoint": "https://api.venice.ai/v1/chat/completions",
    "apiKey": "va_1234567890abcdef",
    "model": "llama-3.1-405b",
    "isConnected": true,
    "lastTested": "2025-01-04T21:10:00.000Z",
  };

  // Mock environment variables
  List<Map<String, dynamic>> _environmentVariables = [
    {
      "key": "TELEGRAM_BOT_TOKEN",
      "value": "1234567890:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw",
      "description": "Main Telegram bot authentication token",
      "isSecret": true,
      "createdAt": "2025-01-04T10:00:00.000Z",
    },
    {
      "key": "VENICE_API_KEY",
      "value": "va_1234567890abcdef",
      "description": "Venice AI API key for natural language processing",
      "isSecret": true,
      "createdAt": "2025-01-04T10:05:00.000Z",
    },
    {
      "key": "DATABASE_URL",
      "value": "postgresql://user:pass@localhost:5432/botdb",
      "description": "PostgreSQL database connection string",
      "isSecret": true,
      "createdAt": "2025-01-04T10:10:00.000Z",
    },
    {
      "key": "LOG_LEVEL",
      "value": "INFO",
      "description": "Application logging level",
      "isSecret": false,
      "createdAt": "2025-01-04T10:15:00.000Z",
    },
  ];

  // Mock analytics data
  final Map<String, dynamic> _analyticsData = {
    "metrics": {
      "totalMessages": 4295,
      "avgResponseTime": 245,
      "errorRate": 1.2,
    },
    "throughputData": [
      {"hour": 0, "messages": 45},
      {"hour": 1, "messages": 32},
      {"hour": 2, "messages": 28},
      {"hour": 3, "messages": 15},
      {"hour": 4, "messages": 12},
      {"hour": 5, "messages": 18},
      {"hour": 6, "messages": 35},
      {"hour": 7, "messages": 67},
      {"hour": 8, "messages": 89},
      {"hour": 9, "messages": 124},
      {"hour": 10, "messages": 156},
      {"hour": 11, "messages": 178},
      {"hour": 12, "messages": 195},
      {"hour": 13, "messages": 187},
      {"hour": 14, "messages": 165},
      {"hour": 15, "messages": 142},
      {"hour": 16, "messages": 134},
      {"hour": 17, "messages": 128},
      {"hour": 18, "messages": 98},
      {"hour": 19, "messages": 76},
      {"hour": 20, "messages": 54},
      {"hour": 21, "messages": 42},
      {"hour": 22, "messages": 38},
      {"hour": 23, "messages": 31},
    ],
    "responseTimeData": [
      {"range": "0-50ms", "count": 65},
      {"range": "50-100ms", "count": 45},
      {"range": "100-200ms", "count": 25},
      {"range": "200ms+", "count": 8},
    ],
    "errorData": [
      {"hour": 0, "errorRate": 0.8},
      {"hour": 2, "errorRate": 1.2},
      {"hour": 4, "errorRate": 0.5},
      {"hour": 6, "errorRate": 1.8},
      {"hour": 8, "errorRate": 2.1},
      {"hour": 10, "errorRate": 1.5},
      {"hour": 12, "errorRate": 0.9},
      {"hour": 14, "errorRate": 1.1},
      {"hour": 16, "errorRate": 0.7},
      {"hour": 18, "errorRate": 1.3},
      {"hour": 20, "errorRate": 0.6},
      {"hour": 22, "errorRate": 0.4},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context, colorScheme),
      body: Column(
        children: [
          _buildTabBar(context, colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBotsTab(context),
                _buildWebhookTab(context),
                _buildIntegrationTab(context),
                _buildAnalyticsTab(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _tabController.index == 0
          ? _buildFloatingActionButton(context, colorScheme)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      title: const Text('Bot Configuration'),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showBotStatusDialog(context);
          },
          icon: CustomIconWidget(
            iconName: 'info',
            color: colorScheme.onPrimary,
            size: 24,
          ),
          tooltip: 'Bot Status Info',
        ),
        PopupMenuButton<String>(
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: colorScheme.onPrimary,
            size: 24,
          ),
          onSelected: (value) {
            HapticFeedback.lightImpact();
            switch (value) {
              case 'refresh':
                _refreshAllData();
                break;
              case 'export':
                _exportConfiguration();
                break;
              case 'import':
                _importConfiguration();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'refresh',
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  const Text('Refresh All'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'download',
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  const Text('Export Config'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'upload',
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  const Text('Import Config'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: colorScheme.primary,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'smart_toy',
              color: _tabController.index == 0
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            text: 'Bots',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'webhook',
              color: _tabController.index == 1
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            text: 'Webhook',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'api',
              color: _tabController.index == 2
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            text: 'Integration',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: _tabController.index == 3
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            text: 'Analytics',
          ),
        ],
        onTap: (index) {
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Widget _buildBotsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(seconds: 1));
        _showSuccessSnackBar('Bots refreshed');
      },
      child: _bots.isEmpty
          ? _buildEmptyBotsState(context)
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              itemCount: _bots.length,
              itemBuilder: (context, index) {
                final bot = _bots[index];
                return BotCardWidget(
                  bot: bot,
                  onTap: () => _showBotDetails(context, bot),
                  onStart: () => _startBot(bot),
                  onStop: () => _stopBot(bot),
                  onRestart: () => _restartBot(bot),
                  onEdit: () => _editBot(context, bot),
                  onDelete: () => _deleteBot(bot),
                  onModeToggle: (isWebhook) => _toggleBotMode(bot, isWebhook),
                );
              },
            ),
    );
  }

  Widget _buildWebhookTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          WebhookConfigWidget(
            webhookConfig: _webhookConfig,
            onConfigChanged: (config) {
              setState(() {
                _webhookConfig = config;
              });
            },
          ),
          SizedBox(height: 2.h),
          EnvironmentVariablesWidget(
            variables: _environmentVariables
                .where((v) => (v["key"] as String).contains("WEBHOOK"))
                .toList(),
            onVariablesChanged: (variables) {
              setState(() {
                // Update webhook-related environment variables
                _environmentVariables.removeWhere(
                    (v) => (v["key"] as String).contains("WEBHOOK"));
                _environmentVariables.addAll(variables);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          ApiIntegrationWidget(
            apiConfig: _apiConfig,
            onConfigChanged: (config) {
              setState(() {
                _apiConfig = config;
              });
            },
          ),
          SizedBox(height: 2.h),
          EnvironmentVariablesWidget(
            variables: _environmentVariables,
            onVariablesChanged: (variables) {
              setState(() {
                _environmentVariables = variables;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: PerformanceAnalyticsWidget(
        analyticsData: _analyticsData,
      ),
    );
  }

  Widget _buildEmptyBotsState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'smart_toy',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Bots Configured',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Add your first Telegram bot to get started with automated conversations and AI-powered responses.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () => _showAddBotDialog(context),
              icon: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Add Your First Bot'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
      BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: () => _showAddBotDialog(context),
      tooltip: 'Add Bot',
      child: CustomIconWidget(
        iconName: 'add',
        color: colorScheme.onSecondary,
        size: 24,
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != _currentBottomNavIndex) {
          HapticFeedback.lightImpact();
          _navigateToTab(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: _currentBottomNavIndex == 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'security',
            color: _currentBottomNavIndex == 1
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'SSL Certs',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'smart_toy',
            color: _currentBottomNavIndex == 2
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Bot Config',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'article',
            color: _currentBottomNavIndex == 3
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Logs',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'settings',
            color: _currentBottomNavIndex == 4
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
            size: 24,
          ),
          label: 'Settings',
        ),
      ],
    );
  }

  void _navigateToTab(int index) {
    final routes = [
      '/server-dashboard',
      '/ssl-certificate-management',
      '/bot-configuration',
      '/system-logs',
      '/settings',
    ];

    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  void _showAddBotDialog(BuildContext context) {
    final nameController = TextEditingController();
    final tokenController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Bot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Bot Name',
                  hintText: 'My Awesome Bot',
                ),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'Bot Token',
                  hintText: '1234567890:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw',
                ),
                obscureText: true,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of bot functionality',
                ),
                maxLines: 3,
              ),
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
              if (nameController.text.isNotEmpty &&
                  tokenController.text.isNotEmpty) {
                final newBot = {
                  "id": _bots.length + 1,
                  "name": nameController.text,
                  "token": tokenController.text,
                  "description": descriptionController.text.isEmpty
                      ? 'No description provided'
                      : descriptionController.text,
                  "status": "Inactive",
                  "mode": "Polling",
                  "messageCount": 0,
                  "lastActivity": "Never",
                };

                setState(() {
                  _bots.add(newBot);
                });

                Navigator.pop(context);
                _showSuccessSnackBar('Bot added successfully');
              }
            },
            child: const Text('Add Bot'),
          ),
        ],
      ),
    );
  }

  void _showBotDetails(BuildContext context, Map<String, dynamic> bot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: EdgeInsets.only(bottom: 3.h),
                alignment: Alignment.center,
              ),
              Text(
                bot["name"] as String,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailItem('Status', bot["status"] as String),
                    _buildDetailItem('Mode', bot["mode"] as String),
                    _buildDetailItem(
                        'Messages', (bot["messageCount"] as int).toString()),
                    _buildDetailItem(
                        'Last Activity', bot["lastActivity"] as String),
                    _buildDetailItem(
                        'Description', bot["description"] as String),
                    _buildDetailItem(
                        'Token', _maskToken(bot["token"] as String)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showBotStatusDialog(BuildContext context) {
    final activeBots = _bots
        .where((bot) => (bot["status"] as String).toLowerCase() == "active")
        .length;
    final totalBots = _bots.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bot Status Overview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Bots: $totalBots'),
            Text('Active Bots: $activeBots'),
            Text('Inactive Bots: ${totalBots - activeBots}'),
            SizedBox(height: 2.h),
            Text(
              'All active bots are monitored in real-time for performance and availability.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startBot(Map<String, dynamic> bot) {
    setState(() {
      bot["status"] = "Active";
      bot["lastActivity"] = "Just now";
    });
    _showSuccessSnackBar('${bot["name"]} started successfully');
  }

  void _stopBot(Map<String, dynamic> bot) {
    setState(() {
      bot["status"] = "Inactive";
    });
    _showSuccessSnackBar('${bot["name"]} stopped');
  }

  void _restartBot(Map<String, dynamic> bot) {
    setState(() {
      bot["status"] = "Active";
      bot["lastActivity"] = "Just now";
    });
    _showSuccessSnackBar('${bot["name"]} restarted');
  }

  void _editBot(BuildContext context, Map<String, dynamic> bot) {
    final nameController = TextEditingController(text: bot["name"] as String);
    final descriptionController =
        TextEditingController(text: bot["description"] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Bot Name'),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                bot["name"] = nameController.text;
                bot["description"] = descriptionController.text;
              });
              Navigator.pop(context);
              _showSuccessSnackBar('Bot updated successfully');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBot(Map<String, dynamic> bot) {
    setState(() {
      _bots.remove(bot);
    });
    _showSuccessSnackBar('${bot["name"]} deleted');
  }

  void _toggleBotMode(Map<String, dynamic> bot, bool isWebhook) {
    setState(() {
      bot["mode"] = isWebhook ? "Webhook" : "Polling";
    });
    _showSuccessSnackBar('${bot["name"]} switched to ${bot["mode"]} mode');
  }

  void _refreshAllData() {
    _showSuccessSnackBar('All data refreshed');
  }

  void _exportConfiguration() {
    _showSuccessSnackBar('Configuration exported successfully');
  }

  void _importConfiguration() {
    _showSuccessSnackBar('Configuration imported successfully');
  }

  String _maskToken(String token) {
    if (token.length <= 8) return token;
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
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
