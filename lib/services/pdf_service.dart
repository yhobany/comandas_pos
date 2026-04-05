import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import 'db_helper.dart';

class PdfService {
  static Future<void> generateAndShareSalesPdf(List<Sale> sales) async {
    final pdf = pw.Document();
    
    // Sort sales by date descending (assuming they are already sorted, but we ensure consistency)
    final sortedSales = List<Sale>.from(sales)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Obtain items for each sale
    Map<int, List<SaleItem>> itemsMap = {};
    for (var sale in sortedSales) {
      if (sale.id != null) {
        final items = await DatabaseHelper.instance.getSaleItemsBySaleId(sale.id!);
        itemsMap[sale.id!] = items;
      }
    }

    double grandTotal = 0;
    for (var sale in sortedSales) {
      grandTotal += sale.totalAmount;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          List<pw.Widget> content = [
            _buildHeader(),
            pw.SizedBox(height: 20),
          ];

          for (var sale in sortedSales) {
            content.addAll([
              _buildSaleHeader(sale),
              _buildSaleItemsTable(itemsMap[sale.id!] ?? []),
              _buildSaleTotal(sale),
              pw.SizedBox(height: 15),
              pw.Divider(color: PdfColors.grey400, thickness: 0.5),
              pw.SizedBox(height: 15),
            ]);
          }

          content.add(_buildGrandTotal(grandTotal));

          return content;
        },
      ),
    );

    final bytes = await pdf.save();
    
    // Format timestamp for filename
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await Printing.sharePdf(bytes: bytes, filename: 'Reporte_Ventas_$timestamp.pdf');
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Reporte de Ventas Consolidadas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
        pw.SizedBox(height: 8),
        pw.Text('Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blueGrey800),
      ],
    );
  }

  static pw.Widget _buildSaleHeader(Sale sale) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            sale.ticketNumber != null ? 'Comanda N°${sale.ticketNumber}' : 'Comanda Interna V-${sale.id}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy HH:mm').format(sale.date),
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ],
      )
    );
  }

  static pw.Widget _buildSaleItemsTable(List<SaleItem> items) {
    if (items.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Text('Sin ítems registrados.', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
      );
    }

    final tableHeaders = ['Producto', 'Cant.', 'Precio Unit.', 'Subtotal'];
    
    return pw.TableHelper.fromTextArray(
      headers: tableHeaders,
      data: items.map((item) => [
        item.name,
        item.quantity.toString(),
        '\$${item.unitPrice.toStringAsFixed(2)}',
        '\$${item.subtotal.toStringAsFixed(2)}',
      ]).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey600),
      cellStyle: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
    );
  }

  static pw.Widget _buildSaleTotal(Sale sale) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6),
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Venta Total: \$${sale.totalAmount.toStringAsFixed(2)}',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
      ),
    );
  }

  static pw.Widget _buildGrandTotal(double grandTotal) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey800, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('TOTAL CONSOLIDADO:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          pw.Text('\$${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
        ],
      )
    );
  }
}
