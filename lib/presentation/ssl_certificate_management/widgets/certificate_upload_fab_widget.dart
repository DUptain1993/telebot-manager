import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CertificateUploadFabWidget extends StatefulWidget {
  final VoidCallback? onCertificateUploaded;

  const CertificateUploadFabWidget({
    super.key,
    this.onCertificateUploaded,
  });

  @override
  State<CertificateUploadFabWidget> createState() =>
      _CertificateUploadFabWidgetState();
}

class _CertificateUploadFabWidgetState
    extends State<CertificateUploadFabWidget> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FloatingActionButton.extended(
      onPressed: () => _showUploadOptions(context),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: CustomIconWidget(
        iconName: 'add',
        color: colorScheme.onPrimary,
        size: 24,
      ),
      label: Text(
        'Add Certificate',
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ),
            SizedBox(height: 3.h),
            Text(
              'Add SSL Certificate',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildUploadOption(
              context,
              'Upload Certificate File',
              'Select .crt, .pem, or .p12 files',
              'file_upload',
              () => _uploadCertificateFile(context),
            ),
            SizedBox(height: 2.h),
            _buildUploadOption(
              context,
              'Scan QR Code',
              'Scan certificate configuration QR code',
              'qr_code_scanner',
              () => _scanQRCode(context),
            ),
            SizedBox(height: 2.h),
            _buildUploadOption(
              context,
              'Generate New Certificate',
              'Create a new SSL certificate',
              'add_circle',
              () => _generateNewCertificate(context),
            ),
            SizedBox(height: 2.h),
            _buildUploadOption(
              context,
              'Import from URL',
              'Import certificate from HTTPS URL',
              'link',
              () => _importFromURL(context),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadCertificateFile(BuildContext context) async {
    Navigator.pop(context);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['crt', 'pem', 'p12', 'pfx', 'cer'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.first;
        List<int>? fileBytes;

        if (kIsWeb) {
          fileBytes = file.bytes;
        } else {
          if (file.path != null) {
            fileBytes = await File(file.path!).readAsBytes();
          }
        }

        if (fileBytes != null) {
          await _processCertificateFile(context, file.name, fileBytes);
        }
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to upload certificate file');
    }
  }

  Future<void> _scanQRCode(BuildContext context) async {
    Navigator.pop(context);

    if (!await _requestCameraPermission()) {
      _showErrorSnackBar(
          context, 'Camera permission is required to scan QR codes');
      return;
    }

    try {
      await _initializeCamera();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _QRScannerScreen(
            cameraController: _cameraController!,
            onQRCodeScanned: (data) => _processQRCodeData(context, data),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to initialize camera');
    }
  }

  Future<void> _generateNewCertificate(BuildContext context) async {
    Navigator.pop(context);
    _showCertificateGenerationWizard(context);
  }

  Future<void> _importFromURL(BuildContext context) async {
    Navigator.pop(context);
    _showURLImportDialog(context);
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    final camera = kIsWeb
        ? _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first)
        : _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first);

    _cameraController = CameraController(
        camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);
    await _cameraController!.initialize();

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _processCertificateFile(
      BuildContext context, String fileName, List<int> fileBytes) async {
    try {
      // Process the certificate file
      final certificateData = {
        'fileName': fileName,
        'size': fileBytes.length,
        'uploadedAt': DateTime.now().toIso8601String(),
        'type': fileName.split('.').last.toUpperCase(),
      };

      _showSuccessSnackBar(
          context, 'Certificate "$fileName" uploaded successfully');
      widget.onCertificateUploaded?.call();
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to process certificate file');
    }
  }

  void _processQRCodeData(BuildContext context, String qrData) {
    try {
      final data = json.decode(qrData);
      _showSuccessSnackBar(
          context, 'Certificate configuration imported from QR code');
      widget.onCertificateUploaded?.call();
    } catch (e) {
      _showErrorSnackBar(context, 'Invalid QR code format');
    }
  }

  void _showCertificateGenerationWizard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => _CertificateGenerationWizard(
          scrollController: scrollController,
          onCertificateGenerated: () {
            Navigator.pop(context);
            widget.onCertificateUploaded?.call();
          },
        ),
      ),
    );
  }

  void _showURLImportDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import from URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the HTTPS URL to import the certificate from:'),
            SizedBox(height: 2.h),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'HTTPS URL',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = urlController.text.trim();
              if (url.isNotEmpty && url.startsWith('https://')) {
                Navigator.pop(context);
                await _importCertificateFromURL(context, url);
              } else {
                _showErrorSnackBar(context, 'Please enter a valid HTTPS URL');
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importCertificateFromURL(
      BuildContext context, String url) async {
    try {
      // Simulate certificate import from URL
      await Future.delayed(const Duration(seconds: 2));
      _showSuccessSnackBar(context, 'Certificate imported from $url');
      widget.onCertificateUploaded?.call();
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to import certificate from URL');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
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
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
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
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _QRScannerScreen extends StatefulWidget {
  final CameraController cameraController;
  final Function(String) onQRCodeScanned;

  const _QRScannerScreen({
    required this.cameraController,
    required this.onQRCodeScanned,
  });

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          CameraPreview(widget.cameraController),
          Center(
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Position QR code within the frame',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => _simulateQRScan(),
                    child: const Text('Simulate Scan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateQRScan() {
    const mockQRData =
        '{"domain": "example.com", "type": "ssl_config", "server": "nginx"}';
    widget.onQRCodeScanned(mockQRData);
    Navigator.pop(context);
  }
}

class _CertificateGenerationWizard extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onCertificateGenerated;

  const _CertificateGenerationWizard({
    required this.scrollController,
    required this.onCertificateGenerated,
  });

  @override
  State<_CertificateGenerationWizard> createState() =>
      _CertificateGenerationWizardState();
}

class _CertificateGenerationWizardState
    extends State<_CertificateGenerationWizard> {
  int _currentStep = 0;
  final _domainController = TextEditingController();
  final _organizationController = TextEditingController();
  String _selectedKeySize = '2048';
  String _selectedValidityPeriod = '1 year';
  bool _isWildcard = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Generate SSL Certificate',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    if (details.stepIndex < 2)
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: const Text('Next'),
                      ),
                    if (details.stepIndex == 2)
                      ElevatedButton(
                        onPressed: () => _generateCertificate(),
                        child: const Text('Generate'),
                      ),
                    SizedBox(width: 2.w),
                    if (details.stepIndex > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text('Domain Information'),
                  content: Column(
                    children: [
                      TextField(
                        controller: _domainController,
                        decoration: const InputDecoration(
                          labelText: 'Domain Name',
                          hintText: 'example.com',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      CheckboxListTile(
                        title: const Text('Wildcard Certificate'),
                        subtitle: const Text('Covers all subdomains'),
                        value: _isWildcard,
                        onChanged: (value) =>
                            setState(() => _isWildcard = value ?? false),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Organization Details'),
                  content: Column(
                    children: [
                      TextField(
                        controller: _organizationController,
                        decoration: const InputDecoration(
                          labelText: 'Organization Name',
                          hintText: 'Your Company Name',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        value: _selectedKeySize,
                        decoration:
                            const InputDecoration(labelText: 'Key Size'),
                        items: ['2048', '4096']
                            .map((size) => DropdownMenuItem(
                                  value: size,
                                  child: Text('$size bit'),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedKeySize = value!),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Certificate Settings'),
                  content: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedValidityPeriod,
                        decoration:
                            const InputDecoration(labelText: 'Validity Period'),
                        items: ['1 year', '2 years', '3 years']
                            .map((period) => DropdownMenuItem(
                                  value: period,
                                  child: Text(period),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedValidityPeriod = value!),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateCertificate() async {
    // Simulate certificate generation
    await Future.delayed(const Duration(seconds: 3));
    widget.onCertificateGenerated();
  }
}
