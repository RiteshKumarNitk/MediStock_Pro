import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:medistock_pro/features/inventory/services/ocr_service.dart';
import 'package:medistock_pro/features/inventory/presentation/ocr_review_screen.dart';



class ScanInvoiceScreen extends ConsumerStatefulWidget {
  const ScanInvoiceScreen({super.key});

  @override
  ConsumerState<ScanInvoiceScreen> createState() => _ScanInvoiceScreenState();
}

class _ScanInvoiceScreenState extends ConsumerState<ScanInvoiceScreen> {

  File? _image;
  bool _isProcessing = false;
  Map<String, dynamic>? _parsedData;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _parsedData = null;
      });
    }
  }

  Future<void> _processInvoice() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate API Call to Supabase Edge Function
      await Future.delayed(const Duration(seconds: 2));
      
      // Using example logic for demonstration
      final rawResult = OCRService.exampleOCRJson;
      final data = OCRService.parseOCRResult(rawResult);
      
      setState(() {
        _parsedData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Invoice Scan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_image != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _processInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Scan & Extract Data'),
              ),
            ],
            if (_parsedData != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Extracted Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                title: const Text('Invoice #'),
                trailing: Text(_parsedData!['invoice_number']),
              ),
              ListTile(
                title: const Text('Vendor'),
                trailing: Text(_parsedData!['customer_name'] ?? 'Unknown'),
              ),
              ListTile(
                title: const Text('Total Amount'),
                trailing: Text('₹${_parsedData!['total_amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(_parsedData!['items'] as List).map((item) => Card(
                child: ListTile(
                  title: Text(item['product_name']),
                  subtitle: Text('Batch: ${item['batch_no']} | Exp: ${item['expiry_date']}'),
                  trailing: Text('Qty: ${item['qty']}'),
                ),
              )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OCRReviewScreen(initialData: _parsedData!),
                    ),
                  );
                },
                child: const Text('Review & Finalize'),
              ),


            ],
          ],
        ),
      ),
    );
  }
}
