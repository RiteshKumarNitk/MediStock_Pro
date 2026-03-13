import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:medistock_pro/core/api_client.dart';

class OCRService {
  /// Extract information from image using AI backend
  static Future<Map<String, dynamic>> extractFromImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await ApiClient.post('/ai/extract', {
        'image': base64Image,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to extract data: ${response.body}');
      }

      return json.decode(response.body);
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  /// Parses the raw OCR result into a structured Invoice and its Items.
  static Map<String, dynamic> parseOCRResult(dynamic result) {
    if (result is String) {
      return json.decode(result);
    }
    return result as Map<String, dynamic>;
  }

  /// Example of what the OCR output should look like (deprecated)
  static String get exampleOCRJson => '''
  {
    "invoice_number": "INV-MOCK-001",
    "customer_name": "Mock Pharmacy",
    "gstin": "27AAACR1234A1Z5",
    "items": [],
    "total_amount": 0,
    "tax_amount": 0
  }
  ''';
}
