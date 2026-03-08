class Product {
  int? id;
  String name;
  double price;
  String? category;
  String? aliasKeywords; // Comma separated aliases for fuzzy matching

  Product({
    this.id,
    required this.name,
    required this.price,
    this.category,
    this.aliasKeywords,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'alias_keywords': aliasKeywords,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      category: map['category'],
      aliasKeywords: map['alias_keywords'],
    );
  }
}
