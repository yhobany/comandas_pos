import '../models/product.dart';
import '../models/sale_item.dart';

class ParsedComanda {
  final DateTime? date;
  final String? ticketNumber;
  final List<SaleItem> items;

  ParsedComanda({this.date, this.ticketNumber, required this.items});
}

class ComandaParserService {
  
  static Future<ParsedComanda> parseTextToSaleItems(String text, List<Product> availableProducts) async {
    final List<SaleItem> items = [];
    final lines = text.split('\n');
    DateTime? receiptDate;
    String? ticketNumber;

    // Busca: 04/03/2026 09:46:00p. m.
    final dateRegex = RegExp(r'(\d{2})/(\d{2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})\s*([apm\. ]+)', caseSensitive: false);
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (receiptDate == null) {
        final dateMatch = dateRegex.firstMatch(line);
        if (dateMatch != null) {
          try {
            int day = int.parse(dateMatch.group(1)!);
            int month = int.parse(dateMatch.group(2)!);
            int year = int.parse(dateMatch.group(3)!);
            int hour = int.parse(dateMatch.group(4)!);
            int minute = int.parse(dateMatch.group(5)!);
            
            String ampm = dateMatch.group(7)!.toLowerCase().replaceAll(' ', '').replaceAll('.', '');
            
            if (ampm == 'pm' && hour < 12) hour += 12;
            if (ampm == 'am' && hour == 12) hour = 0;
            
            receiptDate = DateTime(year, month, day, hour, minute);
          } catch(e) {}
        }
      }

      // Busca: Comanda No. 4
      if (ticketNumber == null) {
        final ticketRegex = RegExp(r'Comanda\s+N[o\.]*\s*(\d+)', caseSensitive: false);
        final ticketMatch = ticketRegex.firstMatch(line);
        if (ticketMatch != null) {
          ticketNumber = ticketMatch.group(1);
        }
      }

      // El recibo muestra las filas como: [Pers] [Cantidad] [Producto]
      // Ejemplo: "1   2 L NATURAL" -> Verde = 2, Amarillo = "L NATURAL"
      final itemRegex = RegExp(r'^(\d+)\s+(\d+)\s+(.+)');
      final match = itemRegex.firstMatch(line);

      int quantity = 1;
      String productNameStr = line;

      if (match != null) {
        // match.group(1) es la primer columna (Personas)
        // match.group(2) es la columna en verde (Cantidad)
        // match.group(3) es la columna amarilla (Producto)
        quantity = int.tryParse(match.group(2)!) ?? 1;
        productNameStr = match.group(3)!.trim();
      } else {
        // Algunas veces el OCR puede comerse el espacio entre Pers y Cantidad: "12 L NATURAL"
        // Si no cumple el formato estricto, aplicamos regla dura: omitimos la linea o buscamos un solo numero
        final regexFallback = RegExp(r'^(\d+)\s+(.+)');
        final matchFB = regexFallback.firstMatch(line);
        if (matchFB != null) {
           quantity = int.tryParse(matchFB.group(1)!) ?? 1;
           // si la cantidad leída es muy alta (ej: 12), probablemente leyó junta "Pers 1 y Cant 2"
           if (quantity > 10) {
              String qtyStr = quantity.toString();
              quantity = int.tryParse(qtyStr.substring(qtyStr.length - 1)) ?? 1;
           }
           productNameStr = matchFB.group(2)!.trim();
        } else {
           continue; // Si no arranca con número, la descartamos definitivamente (así ignoramos basura/totales)
        }
      }

      if (productNameStr.length < 3) continue;

      // Filtrar basura conocida por si el regex falló
      final lowerLine = productNameStr.toLowerCase();
      if (lowerLine.contains('comanda') || lowerLine.contains('total') || 
          lowerLine.contains('efectivo') || lowerLine.contains('cambio') || 
          lowerLine.contains('fecha')) {
        continue;
      }
      
      productNameStr = productNameStr.replaceAll(RegExp(r'\s+'), ' ');

      Product? matchedProduct = _findBestMatch(productNameStr, availableProducts);

      // Si no hay Match (como "Coca Cola" no precargada, o "1 SIN AZUCAR"), la descartamos.
      if (matchedProduct == null) continue;

      items.add(SaleItem(
        saleId: 0,
        productId: matchedProduct.id,
        name: matchedProduct.name,
        quantity: quantity,
        unitPrice: matchedProduct.price,
        subtotal: matchedProduct.price * quantity,
        rawOcrText: line,
      ));
    }

    return ParsedComanda(date: receiptDate, ticketNumber: ticketNumber, items: items);
  }

  static int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;
    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);
    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        int min = v1[j] + 1;
        if (v0[j + 1] + 1 < min) min = v0[j + 1] + 1;
        if (v0[j] + cost < min) min = v0[j] + cost;
        v1[j + 1] = min;
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }

  static Product? _findBestMatch(String ocrText, List<Product> products) {
    ocrText = _normalize(ocrText);
    if (ocrText.isEmpty) return null;
    
    Product? bestMatch;
    double highestSimilarity = 0.0;

    for (var product in products) {
      List<String> variants = [_normalize(product.name)];
      if (product.aliasKeywords != null && product.aliasKeywords!.isNotEmpty) {
        variants.addAll(product.aliasKeywords!.split(',').map((e) => _normalize(e)));
      }

      for (var variant in variants) {
        if (variant.isEmpty) continue;
        
        int maxLen = ocrText.length > variant.length ? ocrText.length : variant.length;
        if (maxLen == 0) continue;
        
        int dist = _levenshtein(ocrText, variant);
        double similarity = 1.0 - (dist / maxLen);

        // Si el texto del OCR contiene perfectamente el nombre/alias, lo consideramos altamente válido
        if (ocrText.contains(variant) && variant.length >= 4) {
          similarity = similarity < 0.85 ? 0.85 : similarity;
        }

        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          bestMatch = product;
        }
      }
    }

    // Umbral de 70% de exactitud mínima para aprobar el producto
    if (highestSimilarity >= 0.70) {
      return bestMatch;
    }
    return null;
  }

  static String _normalize(String input) {
    var str = input.toLowerCase().trim();
    str = str.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    str = str.replaceAll(RegExp(r'[^a-z0-9\s]'), ''); 
    str = str.replaceAll(RegExp(r'\s+'), ' ');
    return str;
  }
}
