import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/services/db_helper.dart';
import '../lib/models/product.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  var dbHelper = DatabaseHelper.instance;

  // Insert test cases
  List<String> namesToTest = [
    "Normal Name",
    "Name with ' quote",
    "Name with \" double quote",
    "Name with emoji 🍔",
    "Name with \n newline",
    "Name with \t tab",
    "Name with \u0000 null byte",
    "Name with leading/trailing space ",
  ];

  for (var name in namesToTest) {
    try {
      int id = await dbHelper.insertProduct(Product(name: name, price: 1000, category: 'General', aliasKeywords: name));
      print('Inserted: ID=$id for $name');
    } catch (e) {
      print('Failed to insert $name: $e');
    }
  }

  var products = await dbHelper.getAllProducts();
  print('Total products: ${products.length}');
  
  for (var p in products.where((p) => namesToTest.contains(p.name))) {
    print('Found: ${p.id} - ${p.name}');
  }
}
