import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.io) 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ExportImportWidget extends StatefulWidget {
  const ExportImportWidget({super.key});

  @override
  State<ExportImportWidget> createState() => _ExportImportWidgetState();
}

class _ExportImportWidgetState extends State<ExportImportWidget> {
  bool _isExporting = false;
  bool _isImporting = false;

  // Mock configuration data
  final Map<String, dynamic> _mockConfigData = {
    "app_version": "1.0.0",
    "export_date": "2025-08-04T21:24:39.221006",
    "user_preferences": {
      "theme": "system",
      "biometric_enabled": true,
      "notifications_enabled": true,
      "auto_refresh_interval": 30,
      "certificate_alerts": true,
      "server_alerts": true
    },
    "server_configurations": [
      {
        "id": "server_001",
        "name": "Production Bot Server",
        "host": "bot.securecompany.com",
        "port": 443,
        "ssl_enabled": true,
        "webhook_url": "https://bot.securecompany.com/webhook",
        "environment": "production"
      },
      {
        "id": "server_002",
        "name": "Development Bot Server",
        "host": "dev-bot.securecompany.com",
        "port": 8443,
        "ssl_enabled": true,
        "webhook_url": "https://dev-bot.securecompany.com/webhook",
        "environment": "development"
      }
    ],
    "ssl_certificates": [
      {
        "id": "cert_001",
        "domain": "bot.securecompany.com",
        "issuer": "Let's Encrypt",
        "expires": "2025-11-04T00:00:00.000Z",
        "status": "active"
      },
      {
        "id": "cert_002",
        "domain": "dev-bot.securecompany.com",
        "issuer": "Let's Encrypt",
        "expires": "2025-10-15T00:00:00.000Z",
        "status": "active"
      }
    ]
  };

  Future<void> _exportConfiguration() async {
    setState(() => _isExporting = true);

    try {
      final configJson = jsonEncode(_mockConfigData);
      final fileName =
          'securebot_config_${DateTime.now().millisecondsSinceEpoch}.json';

      await _downloadFile(configJson, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Configuration exported successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to export configuration'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importConfiguration() async {
    setState(() => _isImporting = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        String configContent;

        if (kIsWeb) {
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            configContent = utf8.decode(bytes);
          } else {
            throw Exception('Failed to read file content');
          }
        } else {
          final file = File(result.files.first.path!);
          configContent = await file.readAsString();
        }

        // Validate JSON structure
        final configData = jsonDecode(configContent) as Map<String, dynamic>;

        if (configData.containsKey('app_version') &&
            configData.containsKey('user_preferences')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Configuration imported successfully'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        } else {
          throw Exception('Invalid configuration file format');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import configuration: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          _buildExportTile(context, theme),
          _buildImportTile(context, theme),
        ],
      ),
    );
  }

  Widget _buildExportTile(BuildContext context, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isExporting ? null : _exportConfiguration,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: _isExporting
                      ? SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'file_upload',
                          color: theme.colorScheme.primary,
                          size: 5.w,
                        ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Configuration',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Save your settings and server configurations',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportTile(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isImporting ? null : _importConfiguration,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: _isImporting
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.secondary,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'file_download',
                            color: theme.colorScheme.secondary,
                            size: 5.w,
                          ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Configuration',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Restore settings from a backup file',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
