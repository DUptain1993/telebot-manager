import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class WebhookConfigWidget extends StatefulWidget {
  final Map<String, dynamic> webhookConfig;
  final ValueChanged<Map<String, dynamic>>? onConfigChanged;

  const WebhookConfigWidget({
    super.key,
    required this.webhookConfig,
    this.onConfigChanged,
  });

  @override
  State<WebhookConfigWidget> createState() => _WebhookConfigWidgetState();
}

class _WebhookConfigWidgetState extends State<WebhookConfigWidget> {
  late TextEditingController _urlController;
  late TextEditingController _secretController;
  bool _isValidating = false;
  bool _isUrlValid = false;
  bool _isSslValid = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
        text: widget.webhookConfig["url"] as String? ?? '');
    _secretController = TextEditingController(
        text: widget.webhookConfig["secret"] as String? ?? '');
    _isUrlValid = widget.webhookConfig["isValid"] as bool? ?? false;
    _isSslValid = widget.webhookConfig["sslValid"] as bool? ?? false;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _secretController.dispose();
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
            _buildUrlField(context, colorScheme),
            SizedBox(height: 2.h),
            _buildSecretField(context, colorScheme),
            SizedBox(height: 3.h),
            _buildValidationSection(context, colorScheme),
            SizedBox(height: 3.h),
            _buildActionButtons(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'webhook',
          color: colorScheme.primary,
          size: 24,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Webhook Configuration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Configure webhook URL and security settings',
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
            color: _isUrlValid && _isSslValid
                ? AppTheme.getStatusColor('success',
                        isLight: Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1)
                : AppTheme.getStatusColor('warning',
                        isLight: Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isUrlValid && _isSslValid ? 'Valid' : 'Needs Setup',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _isUrlValid && _isSslValid
                      ? AppTheme.getStatusColor('success',
                          isLight: Theme.of(context).brightness == Brightness.light)
                      : AppTheme.getStatusColor('warning',
                          isLight: Theme.of(context).brightness == Brightness.light),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlField(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook URL',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'https://your-domain.com/webhook',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'link',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            suffixIcon: _urlController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _urlController.clear();
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a webhook URL';
            }
            final uri = Uri.tryParse(value);
            if (uri?.hasAbsolutePath != true) {
              return 'Please enter a valid URL';
            }
            if (!value.startsWith('https://')) {
              return 'Webhook URL must use HTTPS';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSecretField(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Secret Token',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(width: 2.w),
            Tooltip(
              message: 'Optional secret token for webhook verification',
              child: CustomIconWidget(
                iconName: 'info',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _secretController,
          decoration: InputDecoration(
            hintText: 'Optional secret token',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'security',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _generateSecret,
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  tooltip: 'Generate random secret',
                ),
                if (_secretController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _secretController.clear();
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

  Widget _buildValidationSection(
      BuildContext context, ColorScheme colorScheme) {
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
            'Validation Status',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 2.h),
          _buildValidationItem(
            context,
            colorScheme,
            'URL Reachability',
            _isUrlValid,
            'URL is accessible and responds correctly',
          ),
          SizedBox(height: 1.h),
          _buildValidationItem(
            context,
            colorScheme,
            'SSL Certificate',
            _isSslValid,
            'SSL certificate is valid and trusted',
          ),
          if (_validationMessage != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.getStatusColor('warning',
                        isLight: Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.getStatusColor('warning',
                        isLight: Theme.of(context).brightness == Brightness.light),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _validationMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.getStatusColor('warning',
                                isLight: Theme.of(context).brightness == Brightness.light),
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

  Widget _buildValidationItem(BuildContext context, ColorScheme colorScheme,
      String title, bool isValid, String description) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isValid
                ? AppTheme.getStatusColor('success',
                    isLight: Theme.of(context).brightness == Brightness.light)
                : AppTheme.getStatusColor('error',
                    isLight: Theme.of(context).brightness == Brightness.light),
          ),
          child: CustomIconWidget(
            iconName: isValid ? 'check' : 'close',
            color: Colors.white,
            size: 12,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isValidating ? null : _validateWebhook,
            icon: _isValidating
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
                    iconName: 'verified',
                    color: colorScheme.primary,
                    size: 18,
                  ),
            label: Text(_isValidating ? 'Validating...' : 'Test Webhook'),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _urlController.text.isEmpty ? null : _saveConfiguration,
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

  void _generateSecret() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final secret =
        List.generate(32, (index) => chars[(random + index) % chars.length])
            .join();

    setState(() {
      _secretController.text = secret;
    });

    HapticFeedback.lightImpact();
    _updateConfig();
  }

  Future<void> _validateWebhook() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });

    HapticFeedback.lightImpact();

    try {
      // Simulate webhook validation
      await Future.delayed(const Duration(seconds: 2));

      final url = _urlController.text;
      final isHttps = url.startsWith('https://');
      final isValidUrl = Uri.tryParse(url)?.hasAbsolutePath == true;

      setState(() {
        _isUrlValid = isValidUrl && isHttps;
        _isSslValid = isHttps;

        if (!isValidUrl) {
          _validationMessage = 'Invalid URL format';
        } else if (!isHttps) {
          _validationMessage = 'HTTPS is required for webhooks';
        } else {
          _validationMessage = null;
        }
      });

      if (_isUrlValid && _isSslValid) {
        _showSuccessSnackBar('Webhook validation successful');
      } else {
        _showErrorSnackBar('Webhook validation failed');
      }
    } catch (e) {
      setState(() {
        _isUrlValid = false;
        _isSslValid = false;
        _validationMessage = 'Failed to validate webhook: Network error';
      });
      _showErrorSnackBar('Validation failed: Network error');
    } finally {
      setState(() {
        _isValidating = false;
      });
    }

    _updateConfig();
  }

  void _saveConfiguration() {
    HapticFeedback.lightImpact();
    _updateConfig();
    _showSuccessSnackBar('Webhook configuration saved');
  }

  void _updateConfig() {
    final config = {
      'url': _urlController.text,
      'secret': _secretController.text,
      'isValid': _isUrlValid,
      'sslValid': _isSslValid,
      'lastValidated': DateTime.now().toIso8601String(),
    };

    widget.onConfigChanged?.call(config);
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