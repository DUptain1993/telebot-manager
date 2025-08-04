import 'package:flutter/material.dart';
import '../presentation/settings/settings.dart';
import '../presentation/server_detail/server_detail.dart';
import '../presentation/system_logs/system_logs.dart';
import '../presentation/bot_configuration/bot_configuration.dart';
import '../presentation/server_dashboard/server_dashboard.dart';
import '../presentation/ssl_certificate_management/ssl_certificate_management.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String settings = '/settings';
  static const String serverDetail = '/server-detail';
  static const String systemLogs = '/system-logs';
  static const String botConfiguration = '/bot-configuration';
  static const String serverDashboard = '/server-dashboard';
  static const String sslCertificateManagement = '/ssl-certificate-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const Settings(),
    settings: (context) => const Settings(),
    serverDetail: (context) => const ServerDetail(),
    systemLogs: (context) => const SystemLogs(),
    botConfiguration: (context) => const BotConfiguration(),
    serverDashboard: (context) => const ServerDashboard(),
    sslCertificateManagement: (context) => const SslCertificateManagement(),
    // TODO: Add your other routes here
  };
}