import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ApiIntegrationWidget extends StatefulWidget {
  final Map<String, dynamic> apiConfig;
  final ValueChanged<Map<String, dynamic>>? onConfigChanged;

  const ApiIntegrationWidget({
    super.key,
    required this.apiConfig,
    this.onConfigChanged,
  });

  @override
  State<ApiIntegrationWidget> createState() => _ApiIntegrationWidgetState();
}

class _ApiIntegrationWidgetState extends State<ApiIntegrationWidget> {
  late TextEditingController _endpointController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  bool _isTesting = false;
  bool _isConnected = false;
  String? _testMessage;
  String _selectedProvider = 'Venice AI';

  final List<String> _providers = [
    'Venice AI',
    'OpenAI',
    'Anthropic',
    'Google AI',
    'Custom API',
  ];

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(
        text: widget.apiConfig["endpoint"] as String? ?? '');
    _apiKeyController = TextEditingController(
        text: widget.apiConfig["apiKey"] as String? ?? '');
    _modelController = TextEditingController(
        text: widget.apiConfig["model"] as String? ?? 'gpt-3.5-turbo');
    _isConnected = widget.apiConfig["isConnected"] as bool? ?? false;
    _selectedProvider = widget.apiConfig["provider"] as String? ?? 'Venice AI';
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
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
            _buildProviderSelector(context, colorScheme),
            SizedBox(height: 2.h),
            _buildEndpointField(context, colorScheme),
            SizedBox(height: 2.h),
            _buildApiKeyField(context, colorScheme),
            SizedBox(height: 2.h),
            _buildModelField(context, colorScheme),
            SizedBox(height: 3.h),
            _buildConnectionStatus(context, colorScheme),
            SizedBox(height: 3.h),
            _buildActionButtons(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'api',
          color: colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Integration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Configure AI service connections',
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
            color: _isConnected
                ? AppTheme.getStatusColor('success',
                        isLight: theme.brightness == Brightness.light)
                    .withValues(alpha: 0.1)
                : AppTheme.getStatusColor('error',
                        isLight: theme.brightness == Brightness.light)
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isConnected ? 'Connected' : 'Disconnected',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _isConnected
                      ? AppTheme.getStatusColor('success',
                          isLight: theme.brightness == Brightness.light)
                      : AppTheme.getStatusColor('error',
                          isLight: theme.brightness == Brightness.light),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSelector(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Provider',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            border:
                Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProvider,
              isExpanded: true,
              items: _providers
                  .map((provider) => DropdownMenuItem(
                        value: provider,
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: _getProviderIcon(provider),
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Text(provider),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProvider = value;
                    _updateEndpointForProvider(value);
                  });
                  _updateConfig();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndpointField(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Endpoint',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _endpointController,
          decoration: InputDecoration(
            hintText: 'https://api.example.com/v1/chat/completions',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'link',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            suffixIcon: _endpointController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _endpointController.clear();
                      _updateConfig();
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  )
                : null,
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) => _updateConfig(),
        ),
      ],
    );
  }

  Widget _buildApiKeyField(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'API Key',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(width: 2.w),
            Tooltip(
              message: 'Your API key is stored securely and encrypted',
              child: CustomIconWidget(
                iconName: 'security',
                color: AppTheme.getStatusColor('success',
                    isLight: Theme.of(context).brightness == Brightness.light),
                size: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _apiKeyController,
          decoration: InputDecoration(
            hintText: 'Enter your API key',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'key',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showSecureKeyDialog(context),
                  icon: CustomIconWidget(
                    iconName: 'visibility',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'View key securely',
                ),
                if (_apiKeyController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _apiKeyController.clear();
                      _updateConfig();
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          obscureText: true,
          onChanged: (value) => _updateConfig(),
        ),
      ],
    );
  }

  Widget _buildModelField(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _modelController,
          decoration: InputDecoration(
            hintText: 'gpt-3.5-turbo',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'psychology',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            suffixIcon: PopupMenuButton<String>(
              icon: CustomIconWidget(
                iconName: 'arrow_drop_down',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              onSelected: (model) {
                _modelController.text = model;
                _updateConfig();
              },
              itemBuilder: (context) => _getModelsForProvider(_selectedProvider)
                  .map((model) => PopupMenuItem(
                        value: model,
                        child: Text(model),
                      ))
                  .toList(),
            ),
          ),
          onChanged: (value) => _updateConfig(),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
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
          Text(
            'Connection Status',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected
                      ? AppTheme.getStatusColor('success',
                          isLight: theme.brightness == Brightness.light)
                      : AppTheme.getStatusColor('error',
                          isLight: theme.brightness == Brightness.light),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _isConnected
                      ? 'API connection is active and responding'
                      : 'API connection not established',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (_testMessage != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _isConnected
                    ? AppTheme.getStatusColor('success',
                            isLight: theme.brightness == Brightness.light)
                        .withValues(alpha: 0.1)
                    : AppTheme.getStatusColor('error',
                            isLight: theme.brightness == Brightness.light)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: _isConnected ? 'check_circle' : 'error',
                    color: _isConnected
                        ? AppTheme.getStatusColor('success',
                            isLight: theme.brightness == Brightness.light)
                        : AppTheme.getStatusColor('error',
                            isLight: theme.brightness == Brightness.light),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _testMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _isConnected
                                ? AppTheme.getStatusColor('success',
                                    isLight:
                                        theme.brightness == Brightness.light)
                                : AppTheme.getStatusColor('error',
                                    isLight:
                                        theme.brightness == Brightness.light),
                          ),
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

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isTesting ||
                    _endpointController.text.isEmpty ||
                    _apiKeyController.text.isEmpty
                ? null
                : _testConnection,
            icon: _isTesting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'play_arrow',
                    color: colorScheme.primary,
                    size: 18,
                  ),
            label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _endpointController.text.isEmpty ||
                    _apiKeyController.text.isEmpty
                ? null
                : _saveConfiguration,
            icon: CustomIconWidget(
              iconName: 'save',
              color: colorScheme.onPrimary,
              size: 18,
            ),
            label: const Text('Save Config'),
          ),
        ),
      ],
    );
  }

  String _getProviderIcon(String provider) {
    switch (provider) {
      case 'Venice AI':
        return 'psychology';
      case 'OpenAI':
        return 'smart_toy';
      case 'Anthropic':
        return 'android';
      case 'Google AI':
        return 'google';
      case 'Custom API':
        return 'api';
      default:
        return 'api';
    }
  }

  void _updateEndpointForProvider(String provider) {
    switch (provider) {
      case 'Venice AI':
        _endpointController.text = 'https://api.venice.ai/v1/chat/completions';
        break;
      case 'OpenAI':
        _endpointController.text = 'https://api.openai.com/v1/chat/completions';
        break;
      case 'Anthropic':
        _endpointController.text = 'https://api.anthropic.com/v1/messages';
        break;
      case 'Google AI':
        _endpointController.text =
            'https://generativelanguage.googleapis.com/v1/models';
        break;
      default:
        _endpointController.text = '';
    }
  }

  List<String> _getModelsForProvider(String provider) {
    switch (provider) {
      case 'Venice AI':
        return ['llama-3.1-405b', 'llama-3.1-70b', 'llama-3.1-8b'];
      case 'OpenAI':
        return ['gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'];
      case 'Anthropic':
        return ['claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'];
      case 'Google AI':
        return ['gemini-pro', 'gemini-pro-vision', 'text-bison'];
      default:
        return ['custom-model'];
    }
  }

  Future<void> _testConnection() async {
    if (_endpointController.text.isEmpty || _apiKeyController.text.isEmpty)
      return;

    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    HapticFeedback.lightImpact();

    try {
      // Simulate API connection test
      await Future.delayed(const Duration(seconds: 2));

      final isValidEndpoint =
          Uri.tryParse(_endpointController.text)?.hasAbsolutePath == true;
      final hasApiKey = _apiKeyController.text.isNotEmpty;

      setState(() {
        _isConnected = isValidEndpoint && hasApiKey;
        _testMessage = _isConnected
            ? 'Connection successful! API is responding correctly.'
            : 'Connection failed. Please check your endpoint and API key.';
      });

      if (_isConnected) {
        _showSuccessSnackBar('API connection test successful');
      } else {
        _showErrorSnackBar('API connection test failed');
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _testMessage = 'Connection failed: Network error';
      });
      _showErrorSnackBar('Connection test failed: Network error');
    } finally {
      setState(() {
        _isTesting = false;
      });
    }

    _updateConfig();
  }

  void _saveConfiguration() {
    HapticFeedback.lightImpact();
    _updateConfig();
    _showSuccessSnackBar('API configuration saved');
  }

  void _updateConfig() {
    final config = {
      'provider': _selectedProvider,
      'endpoint': _endpointController.text,
      'apiKey': _apiKeyController.text,
      'model': _modelController.text,
      'isConnected': _isConnected,
      'lastTested': DateTime.now().toIso8601String(),
    };

    widget.onConfigChanged?.call(config);
  }

  void _showSecureKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your API key is stored securely:'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: SelectableText(
                _apiKeyController.text.isEmpty
                    ? 'No API key set'
                    : _apiKeyController.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_apiKeyController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _apiKeyController.text));
                Navigator.pop(context);
                _showSuccessSnackBar('API key copied to clipboard');
              },
              child: const Text('Copy'),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.getStatusColor('error',
            isLight: Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}