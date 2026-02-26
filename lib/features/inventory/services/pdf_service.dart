import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:medistock_pro/features/inventory/models/invoice.dart';
import 'package:medistock_pro/features/inventory/models/sales.dart';

class PDFService {
  static Future<File> generatePurchaseInvoicePDF(Invoice invoice, List<InvoiceItem> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('PURCHASE INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: ${invoice.createdAt?.toString().split(' ')[0] ?? ''}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Invoice #: ${invoice.invoiceNumber}'),
              pw.Text('Vendor: ${invoice.customerName ?? 'N/A'}'),
              pw.Text('GSTIN: ${invoice.gstin ?? 'N/A'}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(

                context: context,
                data: <List<String>>[
                  <String>['Product', 'Batch', 'Qty', 'Rate', 'Value'],
                  ...items.map((item) => [
                    item.productName,
                    item.batchNo ?? '',
                    item.qty.toString(),
                    item.rate.toStringAsFixed(2),
                    item.taxableValue.toStringAsFixed(2),
                  ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Tax Amount: ₹${invoice.taxAmount.toStringAsFixed(2)}'),
                      pw.Text('Total Amount: ₹${invoice.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/purchase_${invoice.invoiceNumber}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateSalesInvoicePDF(SalesInvoice invoice, List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Date: ${invoice.createdAt?.toString().split(' ')[0] ?? ''}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.customerName ?? 'Walk-in Customer'),
                      pw.Text(invoice.customerPhone ?? ''),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${invoice.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Payment Mode: ${invoice.paymentMode.toUpperCase()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(

                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                data: <List<String>>[
                  <String>['Sl', 'Description', 'Batch', 'Qty', 'Rate', 'CGST', 'SGST', 'Amount'],
                  ...items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return [
                      idx.toString(),
                      item['product_name'] ?? 'N/A',
                      item['batch_no'] ?? 'N/A',
                      item['qty'].toString(),
                      item['unit_price'].toStringAsFixed(2),
                      item['cgst'].toStringAsFixed(2),
                      item['sgst'].toStringAsFixed(2),
                      (item['taxable_value'] + item['cgst'] + item['sgst']).toStringAsFixed(2),
                    ];
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Tax Amount:'),
                            pw.Text('₹${invoice.taxAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Payable:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                            pw.Text('₹${invoice.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.blue900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Center(child: pw.Text('*** THANK YOU - VISIT AGAIN ***', style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/sale_${invoice.invoiceNumber}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
