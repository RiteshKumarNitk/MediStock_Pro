import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:medistock_pro/features/inventory/services/ocr_service.dart';
import 'package:medistock_pro/features/inventory/presentation/ocr_review_screen.dart';

import 'package:medistock_pro/core/app_theme.dart';

class ScanInvoiceScreen extends ConsumerStatefulWidget {
  const ScanInvoiceScreen({super.key});

  @override
  ConsumerState<ScanInvoiceScreen> createState() => _ScanInvoiceScreenState();
}

class _ScanInvoiceScreenState extends ConsumerState<ScanInvoiceScreen> {
  XFile? _image;
  Uint8List? _imageBytes;
  bool _isProcessing = false;
  Map<String, dynamic>? _parsedData;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
        _parsedData = null;
      });
    }
  }

  Future<void> _processInvoice() async {
    if (_image == null) return;

    setState(() => _isProcessing = true);

    try {
      final data = await OCRService.extractFromImage(_image!);
      setState(() => _parsedData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Extraction Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Scanner'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Image Preview Holder
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
                image: _imageBytes != null
                    ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                    : null,
              ),
              child: _imageBytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_rounded, size: 80, color: AppTheme.primaryColor.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        const Text('No Document Selected', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    )
                  : const SizedBox(),
            ),
            const SizedBox(height: 40),
            // Source Buttons
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    context,
                    'Camera',
                    Icons.camera_alt_rounded,
                    () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceButton(
                    context,
                    'Gallery',
                    Icons.photo_library_rounded,
                    () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_image != null) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 64),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('EXTRACT DATA WITH AI', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
            if (_parsedData != null) ...[
              const SizedBox(height: 48),
              _buildModernResultCard(context),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OCRReviewScreen(initialData: _parsedData!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text('REVIEW & FINALIZE'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernResultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text('Extraction Complete', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultItem('Vendor', _parsedData!['customer_name']?.toString() ?? 'N/A'),
          _buildResultItem('Total', '₹${_parsedData!['total_amount'] ?? 0}'),
          _buildResultItem('Items Found', '${(_parsedData!['items'] as List?)?.length ?? 0} items'),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
