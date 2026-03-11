import 'dart:io';
import 'package:comandas_ocr/services/comanda_parser_service.dart';
import 'package:comandas_ocr/data/initial_products.dart';

void main() async {
  final text = await File('../comandas_varias_02.md').readAsString();
  
  print('=== STARTING OCR PARSER TEST ===');
  final result = await ComandaParserService.parseTextToSaleItems(text, initialProducts);
  
  print('Date Found: ${result.date}');
  print('Ticket Found: ${result.ticketNumber}');
  print('Items Matched: ${result.items.length}');
  
  for (var item in result.items) {
    print(' - [${item.quantity}] x ${item.name} (${item.unitPrice}) [OCR: ${item.rawOcrText}]');
  }
}
