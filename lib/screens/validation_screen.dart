import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../models/sale_item.dart';
import '../models/product.dart';
import 'product_form_screen.dart';

class ValidationScreen extends StatefulWidget {
  @override
  _ValidationScreenState createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final TextEditingController _ticketController = TextEditingController();
  bool _initialized = false;
  
  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

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
          
          if (!_initialized) {
            _ticketController.text = saleProvider.detectedTicketNumber ?? '';
            _initialized = true;
          }
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, size: 80, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text('Comanda en blanco', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Añadir Producto Manualmente'),
                    onPressed: () => _showAddDialog(context),
                  )
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Detectado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('\$${saleProvider.currentTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _ticketController,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                               setState(() {}); // Forzar repintado para evaluar obligatoriedad 
                            },
                            decoration: InputDecoration(
                              labelText: 'Comanda N# (OBLIGATORIA)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.receipt),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () async {
                              final current = saleProvider.saleDate ?? DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: current,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (picked != null) {
                                saleProvider.setSaleDate(picked);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month, size: 20, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      (saleProvider.saleDate != null)
                                          ? "${saleProvider.saleDate!.day.toString().padLeft(2, '0')}/${saleProvider.saleDate!.month.toString().padLeft(2, '0')}/${saleProvider.saleDate!.year}"
                                          : 'Hoy',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (saleProvider.detectedTicketNumber == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(child: Text('El OCR no detectó el número. Ingréselo manualmente.', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                      )
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
            ),
            child: Text('CONFIRMAR Y GUARDAR VENTA', style: TextStyle(fontSize: 18, color: Colors.white)),
            onPressed: () async {
              // Validar estrepitosamente que no se guarde una venta sin comanda física adjunta
              String? ticketToSave = _ticketController.text.trim();
              if (ticketToSave.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('⚠️ ERROR: Debe ingresar el número de la Comanda antes de guardar'),
                     backgroundColor: Colors.red,
                   )
                 );
                 return; // Abortar guardado
              }
              
              await Provider.of<SaleProvider>(context, listen: false).saveCurrentSaleWithTicket(ticketToSave);
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venta guardada exitosamente'), backgroundColor: Colors.green));
            },
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _priceController = TextEditingController();
    final TextEditingController _qtyController = TextEditingController(text: '1');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_business, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text('Añadir Item Manual', overflow: TextOverflow.visible)),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre del Producto', hintText: 'Ej: Coca Cola 350ml'),
                validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Precio Unit.', prefixText: '\$'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || double.tryParse(val) == null ? 'Inválido' : null,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: InputDecoration(labelText: 'Cant.'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || int.tryParse(val) == null || int.parse(val) < 1 ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newItem = SaleItem(
                  saleId: 0,
                  productId: null, // Es manual, no en catálogo inicialmente
                  name: _nameController.text.trim(),
                  quantity: int.parse(_qtyController.text),
                  unitPrice: double.parse(_priceController.text),
                  subtotal: int.parse(_qtyController.text) * double.parse(_priceController.text),
                  rawOcrText: 'MANUAL',
                );
                Provider.of<SaleProvider>(context, listen: false).addItem(newItem);
                Navigator.pop(ctx);
              }
            },
            child: Text('Añadir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              onPressed: () async {
                Navigator.of(ctx).pop();
                
                // Si el ítem es desconocido, usamos el OCR crudo para el formulario. 
                // Si es un ítem ya en catálogo que el usuario quiere duplicar/recrear, usamos rawOcrText también si está disponible.
                String defaultName = item.rawOcrText ?? item.name;
                
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(
                      product: Product(
                        name: defaultName, 
                        price: item.unitPrice, 
                        aliasKeywords: defaultName
                      )
                    ),
                  ),
                );

                if (result != null && result is Product) {
                  // Si se creó con éxito, vinculamos el ítem de la venta actual al nuevo producto
                  final updatedItem = SaleItem(
                    id: item.id,
                    saleId: item.saleId,
                    productId: result.id,
                    name: result.name, // Usar el nombre oficial guardado
                    quantity: item.quantity,
                    unitPrice: result.price, // Usar el precio oficial guardado
                    subtotal: item.quantity * result.price,
                    rawOcrText: item.rawOcrText,
                  );
                  
                  Provider.of<SaleProvider>(context, listen: false).updateItem(index, updatedItem);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Ítem vinculado al catálogo: ${result.name}'),
                      backgroundColor: Colors.green,
                    )
                  );
                }
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
