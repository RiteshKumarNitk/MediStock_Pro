import 'dart:convert';
class OCRService {

  /// Parses the raw OCR result into a structured Invoice and its Items.
  /// This logic would typically live in a Supabase Edge Function,
  /// but we provide the client-side parsing/interface here.
  static Map<String, dynamic> parseOCRResult(String rawJson) {
    try {
      final decoded = json.decode(rawJson);
      // Ensure the structure matches our expected format
      return decoded;
    } catch (e) {
      throw Exception('Failed to parse OCR JSON: $e');
    }
  }

  /// Example of what the OCR output should look like
  static String get exampleOCRJson => '''
  {
    "invoice_number": "INV-2024-001",
    "customer_name": "Apollo Pharmacy",
    "gstin": "27AAACR1234A1Z5",
    "items": [
      {
        "product_name": "Paracetamol 500mg",
        "batch_no": "B12345",
        "expiry_date": "2026-12-31",
        "qty": 100,
        "rate": 15.5,
        "discount": 10.0,
        "taxable_value": 1395.0
      }
    ],
    "total_amount": 1562.4,
    "tax_amount": 167.4
  }
  ''';
}
