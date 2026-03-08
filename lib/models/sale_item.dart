class SaleItem {
  int? id;
  int saleId;
  int? productId; // Nullable if an unknown product is added manually just by name in the OCR
  String name; // Added to store the name directly for unknown products
  int quantity;
  double unitPrice;
  double subtotal;
  String? rawOcrText; // To trace back what the OCR actually read

  SaleItem({
    this.id,
    required this.saleId,
    this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.rawOcrText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'raw_ocr_text': rawOcrText,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      name: map['name'],
      quantity: map['quantity'],
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      rawOcrText: map['raw_ocr_text'],
    );
  }
}
