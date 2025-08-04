import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/advanced_filter_modal.dart';
import './widgets/auto_scroll_toggle.dart';
import './widgets/log_entry_card.dart';
import './widgets/log_filter_chips.dart';
import './widgets/log_search_bar.dart';
import './widgets/time_range_selector.dart';

class SystemLogs extends StatefulWidget {
  const SystemLogs({super.key});

  @override
  State<SystemLogs> createState() => _SystemLogsState();
}

class _SystemLogsState extends State<SystemLogs> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];

  // Filter states
  List<String> _selectedSeverityFilters = [];
  String _selectedTimeRange = 'today';
  String _searchQuery = '';
  Map<String, dynamic> _advancedFilters = {
    'sources': <String>[],
    'dateRange': null,
    'customQuery': '',
  };

  // UI states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isAutoScrollEnabled = true;
  bool _isLiveStreaming = false;
  int _currentPage = 1;
  bool _hasMoreLogs = true;

  @override
  void initState() {
    super.initState();
    _initializeLogs();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeLogs() {
    setState(() {
      _isLoading = true;
    });

    // Mock log data
    final List<Map<String, dynamic>> mockLogs = [
      {
        "id": 1,
        "timestamp": "2025-08-04T21:15:30.357Z",
        "severity": "Error",
        "source": "SSL Manager",
        "message":
            "Certificate validation failed for domain secure-bot.example.com. Certificate expired on 2025-08-01.",
        "details":
            "SSL certificate chain validation error: Certificate has expired. Please renew the certificate immediately to maintain secure connections.",
        "isImportant": true,
      },
      {
        "id": 2,
        "timestamp": "2025-08-04T21:14:15.123Z",
        "severity": "Warning",
        "source": "Bot Handler",
        "message":
            "High memory usage detected: 85% of allocated memory in use.",
        "details":
            "Memory usage has exceeded the warning threshold. Consider optimizing bot processes or increasing memory allocation.",
        "isImportant": false,
      },
      {
        "id": 3,
        "timestamp": "2025-08-04T21:13:45.789Z",
        "severity": "Info",
        "source": "Server Core",
        "message":
            "Server health check completed successfully. All systems operational.",
        "details":
            "Health check results: CPU: 45%, Memory: 62%, Disk: 34%, Network: Optimal",
        "isImportant": false,
      },
      {
        "id": 4,
        "timestamp": "2025-08-04T21:12:30.456Z",
        "severity": "Critical",
        "source": "Security Monitor",
        "message":
            "Multiple failed authentication attempts detected from IP 192.168.1.100.",
        "details":
            "Security alert: 15 failed login attempts in the last 5 minutes. IP has been temporarily blocked for security purposes.",
        "isImportant": true,
      },
      {
        "id": 5,
        "timestamp": "2025-08-04T21:11:20.234Z",
        "severity": "Debug",
        "source": "API Gateway",
        "message": "Processing webhook request from Telegram servers.",
        "details":
            "Webhook payload received and validated. Processing bot update with message ID: 12345",
        "isImportant": false,
      },
      {
        "id": 6,
        "timestamp": "2025-08-04T21:10:15.678Z",
        "severity": "Info",
        "source": "Database",
        "message":
            "Database connection pool optimized. Current active connections: 12/50.",
        "details":
            "Connection pool status: Active: 12, Idle: 8, Max: 50, Average response time: 45ms",
        "isImportant": false,
      },
      {
        "id": 7,
        "timestamp": "2025-08-04T21:09:45.321Z",
        "severity": "Warning",
        "source": "File System",
        "message": "Disk space usage at 78% on /var/log partition.",
        "details":
            "Disk usage warning: /var/log partition is approaching capacity. Consider log rotation or cleanup.",
        "isImportant": false,
      },
      {
        "id": 8,
        "timestamp": "2025-08-04T21:08:30.987Z",
        "severity": "Error",
        "source": "Network",
        "message":
            "Timeout occurred while connecting to Venice AI API endpoint.",
        "details":
            "Network timeout: Failed to establish connection to api.venice.ai within 30 seconds. Retrying with exponential backoff.",
        "isImportant": true,
      },
      {
        "id": 9,
        "timestamp": "2025-08-04T21:07:15.654Z",
        "severity": "Info",
        "source": "Bot Handler",
        "message":
            "Bot configuration updated successfully. Webhook mode enabled.",
        "details":
            "Configuration changes applied: Webhook URL updated, polling disabled, SSL verification enabled.",
        "isImportant": false,
      },
      {
        "id": 10,
        "timestamp": "2025-08-04T21:06:00.432Z",
        "severity": "Debug",
        "source": "Server Core",
        "message":
            "Scheduled maintenance task completed: Log rotation and cleanup.",
        "details":
            "Maintenance results: 15 old log files archived, 2.3GB disk space freed, next rotation in 24 hours.",
        "isImportant": false,
      },
    ];

    _allLogs.addAll(mockLogs);
    _applyFilters();

    setState(() {
      _isLoading = false;
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMoreLogs) {
          _loadMoreLogs();
        }
      }
    });
  }

  void _loadMoreLogs() {
    if (_isLoadingMore || !_hasMoreLogs) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more logs
    Future.delayed(const Duration(seconds: 2), () {
      final List<Map<String, dynamic>> moreLogs = List.generate(10, (index) {
        final id = _allLogs.length + index + 1;
        final severities = ['Info', 'Warning', 'Error', 'Debug'];
        final sources = [
          'Server Core',
          'SSL Manager',
          'Bot Handler',
          'Database',
          'API Gateway'
        ];

        return {
          "id": id,
          "timestamp": DateTime.now()
              .subtract(Duration(minutes: id * 2))
              .toIso8601String(),
          "severity": severities[index % severities.length],
          "source": sources[index % sources.length],
          "message": "Historical log entry #$id - System operation completed.",
          "details":
              "Additional details for log entry #$id with extended information.",
          "isImportant": index % 5 == 0,
        };
      });

      _allLogs.addAll(moreLogs);
      _applyFilters();

      setState(() {
        _isLoadingMore = false;
        _currentPage++;
        if (_currentPage >= 5) {
          _hasMoreLogs = false;
        }
      });
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allLogs);

    // Apply severity filters
    if (_selectedSeverityFilters.isNotEmpty) {
      filtered = filtered.where((log) {
        final severity = (log['severity'] as String).toLowerCase();
        return _selectedSeverityFilters.any((filter) => severity == filter);
      }).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        final message = (log['message'] as String).toLowerCase();
        final source = (log['source'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return message.contains(query) || source.contains(query);
      }).toList();
    }

    // Apply time range filter
    final now = DateTime.now();
    DateTime? startTime;

    switch (_selectedTimeRange) {
      case 'hour':
        startTime = now.subtract(const Duration(hours: 1));
        break;
      case 'today':
        startTime = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startTime = now.subtract(const Duration(days: 7));
        break;
    }

    if (startTime != null) {
      filtered = filtered.where((log) {
        final logTime = DateTime.parse(log['timestamp'] as String);
        return logTime.isAfter(startTime!);
      }).toList();
    }

    // Apply advanced filters
    final sources = _advancedFilters['sources'] as List<String>;
    if (sources.isNotEmpty) {
      filtered = filtered.where((log) {
        return sources.contains(log['source'] as String);
      }).toList();
    }

    final dateRange = _advancedFilters['dateRange'] as DateTimeRange?;
    if (dateRange != null) {
      filtered = filtered.where((log) {
        final logTime = DateTime.parse(log['timestamp'] as String);
        return logTime.isAfter(dateRange.start) &&
            logTime.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) {
      final timeA = DateTime.parse(a['timestamp'] as String);
      final timeB = DateTime.parse(b['timestamp'] as String);
      return timeB.compareTo(timeA);
    });

    setState(() {
      _filteredLogs = filtered;
    });

    if (_isAutoScrollEnabled && _filteredLogs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _refreshLogs() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));

    // Add some new mock logs
    final newLogs = List.generate(3, (index) {
      final id = _allLogs.length + index + 1;
      return {
        "id": id,
        "timestamp": DateTime.now()
            .subtract(Duration(seconds: index * 30))
            .toIso8601String(),
        "severity": ['Info', 'Warning', 'Error'][index],
        "source": ['Server Core', 'Bot Handler', 'SSL Manager'][index],
        "message": "New log entry #$id - Recent system activity detected.",
        "details": "Fresh log details for entry #$id with current timestamp.",
        "isImportant": index == 2,
      };
    });

    _allLogs.insertAll(0, newLogs);
    _applyFilters();

    setState(() {
      _isLoading = false;
    });
  }

  void _exportLogs() async {
    try {
      final logsJson = jsonEncode(_filteredLogs);
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'system_logs_$timestamp.json';

      if (kIsWeb) {
        final bytes = utf8.encode(logsJson);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile platforms, you would typically use path_provider
        // This is a simplified example
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logs exported successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export logs'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _shareLogEntry(Map<String, dynamic> logEntry) {
    final logText = '''
Log Entry Details:
Time: ${logEntry['timestamp']}
Severity: ${logEntry['severity']}
Source: ${logEntry['source']}
Message: ${logEntry['message']}
${logEntry['details'] != null ? 'Details: ${logEntry['details']}' : ''}
''';

    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log entry copied to clipboard'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _copyLogEntry(Map<String, dynamic> logEntry) {
    final logText =
        '${logEntry['timestamp']} [${logEntry['severity']}] ${logEntry['source']}: ${logEntry['message']}';
    Clipboard.setData(ClipboardData(text: logText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log entry copied to clipboard'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _markLogImportant(Map<String, dynamic> logEntry) {
    setState(() {
      logEntry['isImportant'] = !(logEntry['isImportant'] as bool? ?? false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(logEntry['isImportant']
            ? 'Marked as important'
            : 'Removed from important'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _filterBySource(Map<String, dynamic> logEntry) {
    final source = logEntry['source'] as String;
    setState(() {
      _advancedFilters['sources'] = [source];
    });
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtered by source: $source'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterModal(
        currentFilters: _advancedFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _advancedFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _advancedFilters['dateRange'] as DateTimeRange?,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTimeRange = 'custom';
        _advancedFilters['dateRange'] = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'System Logs',
        variant: CustomAppBarVariant.primary,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'download',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: _exportLogs,
            tooltip: 'Export Logs',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
            onPressed: _showAdvancedFilters,
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          LogSearchBar(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
              _applyFilters();
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
              _applyFilters();
            },
          ),

          // Filter Chips
          LogFilterChips(
            selectedFilters: _selectedSeverityFilters,
            onFiltersChanged: (filters) {
              setState(() {
                _selectedSeverityFilters = filters;
              });
              _applyFilters();
            },
          ),

          // Time Range Selector
          TimeRangeSelector(
            selectedRange: _selectedTimeRange,
            onRangeChanged: (range) {
              setState(() {
                _selectedTimeRange = range;
                if (range != 'custom') {
                  _advancedFilters['dateRange'] = null;
                }
              });
              _applyFilters();
            },
            onCustomDatePicker: _showCustomDatePicker,
          ),

          // Auto-scroll Toggle
          AutoScrollToggle(
            isAutoScrollEnabled: _isAutoScrollEnabled,
            isLiveStreaming: _isLiveStreaming,
            onToggle: (enabled) {
              setState(() {
                _isAutoScrollEnabled = enabled;
                _isLiveStreaming = enabled;
              });
            },
          ),

          // Results Count
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              '${_filteredLogs.length} log entries found',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),

          // Log Entries List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshLogs(),
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: _filteredLogs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'search_off',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                  size: 64,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No logs found',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Try adjusting your filters or search query',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                _filteredLogs.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _filteredLogs.length) {
                                return Container(
                                  padding: EdgeInsets.all(4.w),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                );
                              }

                              final logEntry = _filteredLogs[index];
                              return LogEntryCard(
                                logEntry: logEntry,
                                onShare: () => _shareLogEntry(logEntry),
                                onCopy: () => _copyLogEntry(logEntry),
                                onMarkImportant: () =>
                                    _markLogImportant(logEntry),
                                onFilterBySource: () =>
                                    _filterBySource(logEntry),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: CustomBottomBar.getIndexForRoute('/system-logs'),
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }
}