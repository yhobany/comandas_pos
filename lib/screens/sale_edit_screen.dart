import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/db_helper.dart';

class SaleEditScreen extends StatefulWidget {
  final Sale sale;
  const SaleEditScreen({Key? key, required this.sale}) : super(key: key);

  @override
  _SaleEditScreenState createState() => _SaleEditScreenState();
}

class _SaleEditScreenState extends State<SaleEditScreen> {
  late Sale _sale;
  List<SaleItem> _items = [];
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _sale = widget.sale;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await DatabaseHelper.instance.getSaleItemsBySaleId(_sale.id!);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  double get _recalculatedTotal =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> _changeQuantity(int index, int delta) async {
    final item = _items[index];
    final newQty = item.quantity + delta;
    if (newQty < 1) return;

    final updated = SaleItem(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      name: item.name,
      quantity: newQty,
      unitPrice: item.unitPrice,
      subtotal: newQty * item.unitPrice,
      rawOcrText: item.rawOcrText,
    );

    setState(() {
      _items[index] = updated;
      _hasChanges = true;
    });
  }

  Future<void> _changeName(int index, String newName) async {
    final item = _items[index];
    final updated = SaleItem(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      name: newName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      subtotal: item.subtotal,
      rawOcrText: item.rawOcrText,
    );

    setState(() {
      _items[index] = updated;
      _hasChanges = true;
    });
  }

  Future<void> _deleteItem(int index) async {
    if (_items.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ No se puede eliminar el único ítem. Borra la venta completa desde Reportes.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar ítem'),
        content: Text('¿Eliminar "${_items[index].name}" de esta venta?'),
        actions: [
          TextButton(child: Text('Cancelar'), onPressed: () => Navigator.pop(ctx, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _items.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    // Recalcular y persistir cada ítem
    for (final item in _items) {
      await DatabaseHelper.instance.updateSaleItem(item);
    }

    // Actualizar el total de la venta padre
    final newTotal = _recalculatedTotal;
    await DatabaseHelper.instance.updateSaleTotalAmount(_sale.id!, newTotal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Comanda actualizada correctamente'), backgroundColor: Colors.green),
    );

    setState(() {
      _isLoading = false;
      _hasChanges = false;
      _sale = Sale(
        id: _sale.id,
        date: _sale.date,
        totalAmount: newTotal,
        ticketNumber: _sale.ticketNumber,
      );
    });

    // Indicar al caller que hubo cambios para refrescar la lista
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _sale.ticketNumber != null
        ? 'Comanda N°${_sale.ticketNumber}'
        : 'Venta Ref: V-${_sale.id}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(DateFormat('dd/MM/yyyy').format(_sale.date),
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Resumen compacto
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _hasChanges ? Colors.orange.shade700 : Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _hasChanges ? 'Total (modificado)' : 'Total Registrado',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '\$${_recalculatedTotal.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (_hasChanges)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 16),
                        SizedBox(width: 6),
                        Text('Tienes cambios sin guardar', style: TextStyle(color: Colors.orange.shade800, fontSize: 12)),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Row(
                            children: [
                              // Info del ítem
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      initialValue: item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16,
                                        color: Colors.blue.shade900,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                                        border: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.blue, width: 2),
                                        ),
                                        hintText: 'Nombre del producto',
                                        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                      ),
                                      onChanged: (val) => _changeName(index, val),
                                    ),
                                    Text(
                                      '\$${item.unitPrice.toStringAsFixed(0)} c/u  →  Subtotal: \$${item.subtotal.toStringAsFixed(0)}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              // Controles +/-
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.orange, size: 28),
                                    onPressed: () => _changeQuantity(index, -1),
                                  ),
                                  Container(
                                    width: 32,
                                    alignment: Alignment.center,
                                    child: Text('${item.quantity}',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: Colors.green, size: 28),
                                    onPressed: () => _changeQuantity(index, 1),
                                  ),
                                  SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 28),
                                    onPressed: () => _deleteItem(index),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _hasChanges
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text('GUARDAR CAMBIOS', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saveChanges,
                ),
              ),
            )
          : null,
    );
  }
}
