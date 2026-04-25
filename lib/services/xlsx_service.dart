import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import 'db_helper.dart';

class XlsxService {
  static Future<void> generateAndShareSalesXlsx(List<Sale> sales) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Ventas'];
    excel.delete('Sheet1'); // Remove default sheet

    // Header Style
    CellStyle headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: '#455A64',
      fontColorHex: '#FFFFFF',
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );

    CellStyle saleHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: '#ECEFF1',
      fontSize: 11,
    );

    CellStyle totalStyle = CellStyle(
      bold: true,
      fontColorHex: '#2E7D32',
      fontSize: 11,
    );

    // Main Header
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0));
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    cell.value = 'Reporte de Ventas Consolidadas';
    cell.cellStyle = headerStyle;

    sheet.appendRow(['Generado el:', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), '', '']);

    int currentRow = 3;
    double grandTotal = 0;

    for (var sale in sales) {
      grandTotal += sale.totalAmount;
      final items = await DatabaseHelper.instance.getSaleItemsBySaleId(sale.id!);

      // Sale separator
      sheet.appendRow(['']); currentRow++;
      
      // Sale Header
      final ticketText = sale.ticketNumber != null ? 'Comanda N°${sale.ticketNumber}' : 'Venta Ref: V-${sale.id}';
      final dateText = DateFormat('dd/MM/yyyy HH:mm').format(sale.date);
      
      var headerCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      headerCell.value = '$ticketText - $dateText';
      headerCell.cellStyle = saleHeaderStyle;
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow), 
                 CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
      currentRow++;

      // Table Headers
      sheet.appendRow(['Producto', 'Cantidad', 'Precio Unit.', 'Subtotal']);
      // Apply style to table headers manually if needed, or just append
      currentRow++;

      // Items
      for (var item in items) {
        sheet.appendRow([
          item.name,
          item.quantity,
          item.unitPrice,
          item.subtotal
        ]);
        currentRow++;
      }

      // Sale Total
      var totalCellLabel = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));
      totalCellLabel.value = 'Total:';
      totalCellLabel.cellStyle = CellStyle(bold: true);

      var totalCellValue = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
      totalCellValue.value = sale.totalAmount;
      totalCellValue.cellStyle = totalStyle;
      currentRow++;
    }

    // Grand Total
    sheet.appendRow(['']); currentRow++;
    sheet.appendRow(['']); currentRow++;
    
    var grandTotalLabel = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    grandTotalLabel.value = 'TOTAL CONSOLIDADO';
    grandTotalLabel.cellStyle = headerStyle;
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow), 
               CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));

    var grandTotalValue = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
    grandTotalValue.value = grandTotal;
    grandTotalValue.cellStyle = CellStyle(bold: true, fontSize: 14, fontColorHex: '#1B5E20');

    // Save and Share
    final bytes = excel.save();
    if (bytes == null) return;

    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final filePath = '${directory.path}/Reporte_Ventas_$timestamp.xlsx';
    final file = File(filePath);

    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(filePath)], text: 'Reporte de Ventas');
  }
}
