import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../models/sale_item.dart';
import '../models/product.dart';
import 'product_form_screen.dart';

class ValidationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validar Comanda'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Añadir ítem manualmente',
            onPressed: () {
              _showAddDialog(context);
            },
          )
        ],
      ),
      body: Consumer<SaleProvider>(
        builder: (context, saleProvider, child) {
          final items = saleProvider.currentItems;
          
          if (items.isEmpty) {
            return Center(child: Text('No se detectaron productos en la comanda.'));
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Detectado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${saleProvider.currentTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final bool isUnknown = item.productId == null;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isUnknown ? Colors.red.shade100 : Colors.green.shade100,
                          child: Icon(
                            isUnknown ? Icons.warning_amber_rounded : Icons.check, 
                            color: isUnknown ? Colors.red : Colors.green
                          ),
                        ),
                        title: Text(item.name, style: TextStyle(fontWeight: isUnknown ? FontWeight.bold : FontWeight.normal, color: isUnknown ? Colors.red : Colors.black)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isUnknown) Text('⚠️ Producto no en catálogo', style: TextStyle(color: Colors.red, fontSize: 12)),
                            Text('OCR original: ${item.rawOcrText ?? "N/A"}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('\$${item.unitPrice} ud. | Subtotal: \$${item.subtotal}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () => saleProvider.updateItemQuantity(index, item.quantity - 1),
                            ),
                            Text('${item.quantity}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () => saleProvider.updateItemQuantity(index, item.quantity + 1),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => saleProvider.removeItem(index),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Allow editing or linking the product
                          _showEditDialog(context, index, item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          child: Text('CONFIRMAR Y GUARDAR VENTA', style: TextStyle(fontSize: 18, color: Colors.white)),
          onPressed: () async {
            await Provider.of<SaleProvider>(context, listen: false).saveCurrentSale();
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venta guardada exitosamente')));
          },
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    // Basic dialog to add manual item. For brevity, similar to EditDialog.
  }

  void _showEditDialog(BuildContext context, int index, SaleItem item) {
    // For now a very basic implementation to maybe map to an existing product
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Resolver Producto: ${item.name}'),
          content: Text('¿Deseas guardar este producto en el catálogo base para futuros escaneos?'),
          actions: [
            TextButton(
              child: Text('Crear en Catálogo'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      product: Product(
                        name: item.name, 
                        price: item.unitPrice, 
                        aliasKeywords: item.name // Set the OCR text as an alias
                      )
                    ),
                  ),
                ).then((_) {
                  // Actually, after creating a product we should probably trigger a refresh
                });
              },
            ),
            TextButton(
              child: Text('Cerrar'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        );
      }
    );
  }
}
