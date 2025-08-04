import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/bot_configuration_card.dart';
import './widgets/database_connection_card.dart';
import './widgets/environment_variables_card.dart';
import './widgets/server_actions_card.dart';
import './widgets/server_status_card.dart';
import './widgets/ssl_certificate_card.dart';

class ServerDetail extends StatefulWidget {
  const ServerDetail({super.key});

  @override
  State<ServerDetail> createState() => _ServerDetailState();
}

class _ServerDetailState extends State<ServerDetail>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String _selectedEnvironment = 'production';

  // Mock server data
  final Map<String, dynamic> _serverData = {
    'id': 'srv-001',
    'name': 'TelegramBot-Production',
    'status': 'online',
    'uptime': '15d 8h 32m',
    'memoryUsage': 0.68,
    'cpuUsage': 0.34,
    'lastUpdated': '2 minutes ago',
    'environment': 'production',
  };

  // Mock SSL certificate data
  final Map<String, dynamic> _certificateData = {
    'domain': 'api.securebot.com',
    'expirationDate': '03/15/2025',
    'daysUntilExpiry': 45,
    'isValid': true,
    'issuer': 'Let\'s Encrypt Authority X3',
  };

  // Mock bot configuration data
  final List<Map<String, dynamic>> _botsData = [
    {
      'name': 'SecureBot Main',
      'token': '1234567890:AAEhBOweik6ad6PsVMRxjeQKQ67WbIhyaDI',
      'isWebhook': true,
      'status': 'active',
      'lastActivity': '5 minutes ago',
    },
    {
      'name': 'Notification Bot',
      'token': '9876543210:BBFhCPxfjl7be7QsWNSykfRLR78XcJizeBJ',
      'isWebhook': false,
      'status': 'active',
      'lastActivity': '12 minutes ago',
    },
    {
      'name': 'Analytics Bot',
      'token': '5555555555:CCGiDQyglm8cf8RtXOTzlgSMS89YdKjafCK',
      'isWebhook': true,
      'status': 'inactive',
      'lastActivity': '2 hours ago',
    },
  ];

  // Mock environment variables data
  final List<Map<String, dynamic>> _environmentVariables = [
    {
      'key': 'BOT_TOKEN',
      'value': '1234567890:AAEhBOweik6ad6PsVMRxjeQKQ67WbIhyaDI',
      'isSecret': true,
      'description': 'Main Telegram bot token for authentication',
    },
    {
      'key': 'VENICE_API_KEY',
      'value': 'vk_live_abc123def456ghi789jkl012mno345pqr',
      'isSecret': true,
      'description': 'Venice AI API key for natural language processing',
    },
    {
      'key': 'DATABASE_URL',
      'value': 'postgresql://user:pass@localhost:5432/securebot_db',
      'isSecret': true,
      'description': 'PostgreSQL database connection string',
    },
    {
      'key': 'WEBHOOK_URL',
      'value': 'https://api.securebot.com/webhook',
      'isSecret': false,
      'description': 'Public webhook endpoint for Telegram callbacks',
    },
    {
      'key': 'LOG_LEVEL',
      'value': 'INFO',
      'isSecret': false,
      'description': 'Application logging level configuration',
    },
  ];

  // Mock database connection data
  final Map<String, dynamic> _databaseData = {
    'host': 'db.securebot.com',
    'port': 5432,
    'database': 'securebot_production',
    'username': 'securebot_user',
    'status': 'connected',
    'lastChecked': '1 minute ago',
    'responseTime': 45,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_serverData['name'] ?? 'Server Detail'),
        actions: [
          _buildEnvironmentToggle(theme, colorScheme),
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              size: 24,
              color: colorScheme.onPrimary,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Server Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clone',
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 8),
                    Text('Clone Server'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Server', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ServerStatusCard(
                serverData: _serverData,
                onRefresh: _refreshServerStatus,
              ),
              SslCertificateCard(
                certificateData: _certificateData,
                onRenew: _renewCertificate,
                onViewDetails: _viewCertificateDetails,
              ),
              BotConfigurationCard(
                bots: _botsData,
                onModeToggle: _toggleBotMode,
                onAddBot: _addNewBot,
                onEditBot: _editBot,
              ),
              EnvironmentVariablesCard(
                variables: _environmentVariables,
                onEdit: _editEnvironmentVariable,
                onAdd: _addEnvironmentVariable,
                onDelete: _deleteEnvironmentVariable,
              ),
              DatabaseConnectionCard(
                connectionData: _databaseData,
                onTestConnection: _testDatabaseConnection,
                onEditConnection: _editDatabaseConnection,
              ),
              ServerActionsCard(
                onRestartServer: _restartServer,
                onDeployChanges: _deployChanges,
                onViewLogs: _viewServerLogs,
                onBackupServer: _backupServer,
                isLoading: _isLoading,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentToggle(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(right: 3.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEnvironment,
          icon: CustomIconWidget(
            iconName: 'arrow_drop_down',
            size: 20,
            color: colorScheme.onPrimary,
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: colorScheme.surface,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedEnvironment = value;
              });
              _switchEnvironment(value);
            }
          },
          items: ['development', 'staging', 'production'].map((env) {
            return DropdownMenuItem(
              value: env,
              child: Text(
                env.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12.sp,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    HapticFeedback.lightImpact();
    switch (action) {
      case 'refresh':
        _refreshData();
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'clone':
        _showCloneServerDialog();
        break;
      case 'delete':
        _showDeleteServerDialog();
        break;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _serverData['lastUpdated'] = 'Just now';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server data refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _refreshServerStatus() {
    HapticFeedback.lightImpact();
    setState(() {
      _serverData['lastUpdated'] = 'Just now';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Server status refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _switchEnvironment(String environment) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $environment environment'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _renewCertificate() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/ssl-certificate-management');
  }

  void _viewCertificateDetails() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildCertificateDetailsSheet(),
    );
  }

  void _toggleBotMode(int index, bool isWebhook) {
    HapticFeedback.lightImpact();
    setState(() {
      _botsData[index]['isWebhook'] = isWebhook;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bot mode changed to ${isWebhook ? 'Webhook' : 'Polling'}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewBot() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/bot-configuration');
  }

  void _editBot(int index) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/bot-configuration');
  }

  void _editEnvironmentVariable(int index) {
    HapticFeedback.lightImpact();
    _showEditVariableDialog(_environmentVariables[index], index);
  }

  void _addEnvironmentVariable() {
    HapticFeedback.lightImpact();
    _showEditVariableDialog(null, -1);
  }

  void _deleteEnvironmentVariable(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _environmentVariables.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Environment variable deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _testDatabaseConnection() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _databaseData['status'] = 'connected';
          _databaseData['lastChecked'] = 'Just now';
          _databaseData['responseTime'] = 42;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database connection test successful'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _editDatabaseConnection() {
    HapticFeedback.lightImpact();
    _showEditDatabaseDialog();
  }

  void _restartServer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _serverData['status'] = 'online';
          _serverData['uptime'] = '0h 1m';
          _serverData['lastUpdated'] = 'Just now';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server restarted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _deployChanges() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes deployed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _viewServerLogs() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/system-logs');
  }

  void _backupServer() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Server backup initiated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildCertificateDetailsSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 70.h,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Certificate Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  size: 24,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Domain', _certificateData['domain'], theme),
                  _buildDetailItem('Issuer', _certificateData['issuer'], theme),
                  _buildDetailItem('Expiration Date',
                      _certificateData['expirationDate'], theme),
                  _buildDetailItem('Days Until Expiry',
                      '${_certificateData['daysUntilExpiry']} days', theme),
                  _buildDetailItem('Status',
                      _certificateData['isValid'] ? 'Valid' : 'Invalid', theme),
                  _buildDetailItem(
                      'Serial Number', 'A1:B2:C3:D4:E5:F6:G7:H8', theme),
                  _buildDetailItem(
                      'Signature Algorithm', 'SHA256withRSA', theme),
                  _buildDetailItem('Key Size', '2048 bits', theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditVariableDialog(Map<String, dynamic>? variable, int index) {
    final keyController = TextEditingController(text: variable?['key'] ?? '');
    final valueController =
        TextEditingController(text: variable?['value'] ?? '');
    final descriptionController =
        TextEditingController(text: variable?['description'] ?? '');
    bool isSecret = variable?['isSecret'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(variable == null ? 'Add Variable' : 'Edit Variable'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    hintText: 'VARIABLE_NAME',
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'variable_value',
                  ),
                  obscureText: isSecret,
                ),
                SizedBox(height: 2.h),
                TextField(
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
                    Switch(
                      value: isSecret,
                      onChanged: (value) {
                        setDialogState(() {
                          isSecret = value;
                        });
                      },
                    ),
                    SizedBox(width: 2.w),
                    const Text('Mark as secret'),
                  ],
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
                final newVariable = {
                  'key': keyController.text,
                  'value': valueController.text,
                  'description': descriptionController.text,
                  'isSecret': isSecret,
                };

                setState(() {
                  if (index == -1) {
                    _environmentVariables.add(newVariable);
                  } else {
                    _environmentVariables[index] = newVariable;
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      variable == null ? 'Variable added' : 'Variable updated',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(variable == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDatabaseDialog() {
    final hostController = TextEditingController(text: _databaseData['host']);
    final portController =
        TextEditingController(text: _databaseData['port'].toString());
    final databaseController =
        TextEditingController(text: _databaseData['database']);
    final usernameController =
        TextEditingController(text: _databaseData['username']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Database Connection'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  hintText: 'localhost',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: portController,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  hintText: '5432',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: databaseController,
                decoration: const InputDecoration(
                  labelText: 'Database',
                  hintText: 'database_name',
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'db_user',
                ),
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
              setState(() {
                _databaseData['host'] = hostController.text;
                _databaseData['port'] =
                    int.tryParse(portController.text) ?? 5432;
                _databaseData['database'] = databaseController.text;
                _databaseData['username'] = usernameController.text;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Database connection updated'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showCloneServerDialog() {
    final nameController =
        TextEditingController(text: '${_serverData['name']}-Clone');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clone Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Create a copy of this server configuration with a new name.'),
            SizedBox(height: 2.h),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'New Server Name',
                hintText: 'Enter server name',
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Server "${nameController.text}" cloned successfully'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clone'),
          ),
        ],
      ),
    );
  }

  void _showDeleteServerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              size: 24,
              color: Colors.red,
            ),
            SizedBox(width: 2.w),
            const Text('Delete Server'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this server? This action cannot be undone and will permanently remove all server data, configurations, and associated bots.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to server list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Server deleted successfully'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
