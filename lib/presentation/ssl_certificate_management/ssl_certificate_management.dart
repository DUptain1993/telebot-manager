import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/certificate_card_widget.dart';
import './widgets/certificate_empty_state_widget.dart';
import './widgets/certificate_health_overview_widget.dart';
import './widgets/certificate_search_widget.dart';
import './widgets/certificate_upload_fab_widget.dart';

class SslCertificateManagement extends StatefulWidget {
  const SslCertificateManagement({super.key});

  @override
  State<SslCertificateManagement> createState() =>
      _SslCertificateManagementState();
}

class _SslCertificateManagementState extends State<SslCertificateManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Map<String, dynamic>> _allCertificates = [];
  List<Map<String, dynamic>> _filteredCertificates = [];
  Map<String, int> _healthStats = {};
  String _searchQuery = '';
  String _currentFilter = 'all';
  bool _isLoading = true;
  bool _showExpirationBanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadCertificates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final filters = ['all', 'valid', 'expiring', 'expired'];
      _currentFilter = filters[_tabController.index];
      _applyFilters();
    }
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final mockCertificates = [
      {
        'id': 1,
        'domain': 'api.securebot.com',
        'issuer': 'Let\'s Encrypt Authority X3',
        'status': 'valid',
        'expiryDate': DateTime.now().add(const Duration(days: 45)),
        'keySize': 2048,
        'algorithm': 'RSA',
        'autoRenew': true,
        'wildcardCert': false,
      },
      {
        'id': 2,
        'domain': '*.example.com',
        'issuer': 'DigiCert Inc',
        'status': 'expiring',
        'expiryDate': DateTime.now().add(const Duration(days: 15)),
        'keySize': 2048,
        'algorithm': 'RSA',
        'autoRenew': false,
        'wildcardCert': true,
      },
      {
        'id': 3,
        'domain': 'old-service.company.com',
        'issuer': 'GlobalSign',
        'status': 'expired',
        'expiryDate': DateTime.now().subtract(const Duration(days: 5)),
        'keySize': 2048,
        'algorithm': 'RSA',
        'autoRenew': false,
        'wildcardCert': false,
      },
      {
        'id': 4,
        'domain': 'secure.payment.com',
        'issuer': 'Comodo CA Limited',
        'status': 'valid',
        'expiryDate': DateTime.now().add(const Duration(days: 120)),
        'keySize': 4096,
        'algorithm': 'RSA',
        'autoRenew': true,
        'wildcardCert': false,
      },
      {
        'id': 5,
        'domain': 'test.staging.com',
        'issuer': 'Let\'s Encrypt Authority X3',
        'status': 'expiring',
        'expiryDate': DateTime.now().add(const Duration(days: 8)),
        'keySize': 2048,
        'algorithm': 'RSA',
        'autoRenew': true,
        'wildcardCert': false,
      },
    ];

    _allCertificates = mockCertificates;
    _calculateHealthStats();
    _applyFilters();

    setState(() => _isLoading = false);
  }

  void _calculateHealthStats() {
    final now = DateTime.now();
    int total = _allCertificates.length;
    int valid = 0;
    int expiring = 0;
    int expired = 0;

    for (final cert in _allCertificates) {
      final expiryDate = cert['expiryDate'] as DateTime;
      final daysUntilExpiry = expiryDate.difference(now).inDays;

      if (daysUntilExpiry < 0) {
        expired++;
      } else if (daysUntilExpiry <= 30) {
        expiring++;
      } else {
        valid++;
      }
    }

    _healthStats = {
      'total': total,
      'valid': valid,
      'expiring': expiring,
      'expired': expired,
    };

    _showExpirationBanner = expiring > 0 || expired > 0;
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allCertificates);

    // Apply status filter
    if (_currentFilter != 'all') {
      filtered = filtered.where((cert) {
        switch (_currentFilter) {
          case 'valid':
            return cert['status'] == 'valid';
          case 'expiring':
            return cert['status'] == 'expiring';
          case 'expired':
            return cert['status'] == 'expired';
          case 'wildcard':
            return cert['wildcardCert'] == true;
          case 'auto_renew':
            return cert['autoRenew'] == true;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cert) {
        final domain = (cert['domain'] as String).toLowerCase();
        final issuer = (cert['issuer'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return domain.contains(query) || issuer.contains(query);
      }).toList();
    }

    setState(() {
      _filteredCertificates = filtered;
    });
  }

  Future<void> _refreshCertificates() async {
    await _loadCertificates();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    _currentFilter = filter;
    _applyFilters();
  }

  void _onCertificateAction(String action, Map<String, dynamic> certificate) {
    final domain = certificate['domain'] as String;

    switch (action) {
      case 'renew':
        _showActionSnackBar('Renewing certificate for $domain...');
        break;
      case 'download':
        _showActionSnackBar('Downloading certificate for $domain...');
        break;
      case 'test':
        _showActionSnackBar('Testing certificate validation for $domain...');
        break;
      case 'delete':
        _showActionSnackBar('Certificate for $domain deleted');
        _removeCertificate(certificate['id']);
        break;
      case 'export':
        _showActionSnackBar('Exporting certificate for $domain...');
        break;
    }
  }

  void _removeCertificate(int id) {
    setState(() {
      _allCertificates.removeWhere((cert) => cert['id'] == id);
      _calculateHealthStats();
      _applyFilters();
    });
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCertificateDetails(Map<String, dynamic> certificate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _CertificateDetailsSheet(
          certificate: certificate,
          scrollController: scrollController,
          onAction: (action) => _onCertificateAction(action, certificate),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('SSL Certificates'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _refreshIndicatorKey.currentState?.show(),
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: colorScheme.onPrimary,
              size: 24,
            ),
            onSelected: (value) {
              switch (value) {
                case 'export_all':
                  _showActionSnackBar('Exporting all certificates...');
                  break;
                case 'import_bulk':
                  _showActionSnackBar('Bulk import feature coming soon...');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_bulk',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Bulk Import'),
                  ],
                ),
              ),
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
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Valid'),
            Tab(text: 'Expiring'),
            Tab(text: 'Expired'),
          ],
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshCertificates,
        child: Column(
          children: [
            if (_showExpirationBanner) _buildExpirationBanner(),
            CertificateHealthOverviewWidget(
              healthStats: _healthStats,
              onRefresh: _refreshCertificates,
            ),
            CertificateSearchWidget(
              onSearchChanged: _onSearchChanged,
              onFilterChanged: _onFilterChanged,
              onClearSearch: () {
                _searchQuery = '';
                _applyFilters();
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCertificates.isEmpty
                      ? CertificateEmptyStateWidget(
                          isSearchResult: _searchQuery.isNotEmpty ||
                              _currentFilter != 'all',
                          searchQuery: _searchQuery,
                          onImportCertificate: () {
                            // Trigger FAB action
                          },
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 20.h),
                          itemCount: _filteredCertificates.length,
                          itemBuilder: (context, index) {
                            final certificate = _filteredCertificates[index];
                            return CertificateCardWidget(
                              certificate: certificate,
                              onTap: () => _showCertificateDetails(certificate),
                              onRenew: () =>
                                  _onCertificateAction('renew', certificate),
                              onDownload: () =>
                                  _onCertificateAction('download', certificate),
                              onTest: () =>
                                  _onCertificateAction('test', certificate),
                              onDelete: () =>
                                  _onCertificateAction('delete', certificate),
                              onExport: () =>
                                  _onCertificateAction('export', certificate),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: CertificateUploadFabWidget(
        onCertificateUploaded: _refreshCertificates,
      ),
    );
  }

  Widget _buildExpirationBanner() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expiredCount = _healthStats['expired'] ?? 0;
    final expiringCount = _healthStats['expiring'] ?? 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: (expiredCount > 0 ? colorScheme.error : Colors.orange)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (expiredCount > 0 ? colorScheme.error : Colors.orange)
              .withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: expiredCount > 0 ? 'error' : 'warning',
            color: expiredCount > 0 ? colorScheme.error : Colors.orange,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expiredCount > 0
                      ? 'Critical: Expired Certificates'
                      : 'Warning: Certificates Expiring Soon',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: expiredCount > 0 ? colorScheme.error : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  expiredCount > 0
                      ? '$expiredCount certificate${expiredCount > 1 ? 's have' : ' has'} expired and need${expiredCount > 1 ? '' : 's'} immediate renewal'
                      : '$expiringCount certificate${expiringCount > 1 ? 's are' : ' is'} expiring within 30 days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        (expiredCount > 0 ? colorScheme.error : Colors.orange)
                            .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _tabController.animateTo(expiredCount > 0 ? 3 : 2);
            },
            child: Text(
              'View All',
              style: TextStyle(
                color: expiredCount > 0 ? colorScheme.error : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> certificate;
  final ScrollController scrollController;
  final Function(String) onAction;

  const _CertificateDetailsSheet({
    required this.certificate,
    required this.scrollController,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expiryDate = certificate['expiryDate'] as DateTime;
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Certificate Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildDetailItem('Domain', certificate['domain']),
                _buildDetailItem('Issuer', certificate['issuer']),
                _buildDetailItem('Status', certificate['status']),
                _buildDetailItem('Expires',
                    '${expiryDate.day}/${expiryDate.month}/${expiryDate.year} ($daysUntilExpiry days)'),
                _buildDetailItem('Key Size', '${certificate['keySize']} bit'),
                _buildDetailItem('Algorithm', certificate['algorithm']),
                _buildDetailItem('Auto-Renew',
                    certificate['autoRenew'] ? 'Enabled' : 'Disabled'),
                _buildDetailItem(
                    'Wildcard', certificate['wildcardCert'] ? 'Yes' : 'No'),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onAction('download');
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onAction('renew');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Renew'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
