import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/db_helper.dart';

class SaleProvider with ChangeNotifier {
  List<SaleItem> _currentItems = [];
  DateTime? _saleDate;
  String? _detectedTicketNumber;

  List<SaleItem> get currentItems => _currentItems;
  DateTime? get saleDate => _saleDate;
  String? get detectedTicketNumber => _detectedTicketNumber;
  
  double get currentTotal {
    return _currentItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  void setCurrentItems(List<SaleItem> items, {DateTime? parsedDate, String? ticketNumber}) {
    _currentItems = items;
    _saleDate = parsedDate;
    _detectedTicketNumber = ticketNumber;
    notifyListeners();
  }

  void updateItemQuantity(int index, int newQuantity) {
    if (newQuantity < 1) return;
    final item = _currentItems[index];
    item.quantity = newQuantity;
    item.subtotal = item.quantity * item.unitPrice;
    notifyListeners();
  }

  void removeItem(int index) {
    _currentItems.removeAt(index);
    notifyListeners();
  }

  void addItem(SaleItem item) {
    _currentItems.add(item);
    notifyListeners();
  }

  void updateItem(int index, SaleItem newItem) {
    _currentItems[index] = newItem;
    notifyListeners();
  }

  Future<void> saveCurrentSale() async {
    await saveCurrentSaleWithTicket(null);
  }

  Future<void> saveCurrentSaleWithTicket(String? ticketNumber) async {
    if (_currentItems.isEmpty) return;

    final sale = Sale(
      date: _saleDate ?? DateTime.now(),
      totalAmount: currentTotal,
      ticketNumber: ticketNumber, // Nuevo soporte
    );

    final saleId = await DatabaseHelper.instance.insertSale(sale);

    for (var item in _currentItems) {
      item.saleId = saleId;
      await DatabaseHelper.instance.insertSaleItem(item);
    }
    
    // Clear after save
    _currentItems.clear();
    _saleDate = null;
    _detectedTicketNumber = null;
    notifyListeners();
  }
}
