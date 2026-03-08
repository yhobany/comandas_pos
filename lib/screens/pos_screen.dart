import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../models/sale_item.dart';

class PosScreen extends StatefulWidget {
  @override
  _PosScreenState createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Forzar la recarga de productos al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final saleProvider = Provider.of<SaleProvider>(context);

    // Obtener categorías únicas
    final categories = productProvider.products
        .map((p) => p.category ?? 'General')
        .toSet()
        .toList();

    // Filtrar productos
    List<Product> displayedProducts = productProvider.products;
    
    if (_searchQuery.isNotEmpty) {
      displayedProducts = displayedProducts.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      _selectedCategory = null; // Si busca, anula el filtro de categoría
    } else if (_selectedCategory != null) {
      displayedProducts = displayedProducts.where((p) => 
        (p.category ?? 'General') == _selectedCategory
      ).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Venta (POS)'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Categorías (Horizontal Scroll)
          if (_searchQuery.isEmpty)
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryChip('Todos', _selectedCategory == null, () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    });
                  }
                  final category = categories[index - 1];
                  return _buildCategoryChip(category, _selectedCategory == category, () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  });
                },
              ),
            ),
            
          // Grilla de Productos
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columnas para tablet/paisaje, adaptable
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                final product = displayedProducts[index];
                return _buildProductCard(product, context);
              },
            ),
          ),
          
          // Resumen de Carrito / Bottom Bar
          _buildBottomCartBar(context, saleProvider),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        selectedColor: Colors.blueAccent,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    return InkWell(
      onTap: () => _showQuantityDialog(context, product),
      child: Card(
        elevation: 2,
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Product product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(product.name),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, size: 36, color: Colors.red),
                    onPressed: () {
                      if (quantity > 1) setStateDialog(() => quantity--);
                    },
                  ),
                  Text('$quantity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 36, color: Colors.green),
                    onPressed: () {
                      setStateDialog(() => quantity++);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final saleItem = SaleItem(
                      saleId: 0,
                      productId: product.id,
                      name: product.name,
                      quantity: quantity,
                      unitPrice: product.price,
                      subtotal: product.price * quantity,
                    );
                    Provider.of<SaleProvider>(context, listen: false).addItem(saleItem);
                    Navigator.pop(context);
                  },
                  child: Text('Agregar'),
                )
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildBottomCartBar(BuildContext context, SaleProvider saleProvider) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -3),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${saleProvider.currentItems.length} items', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                Text(
                  'Total: \$${saleProvider.currentTotal.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.shopping_cart_checkout, color: Colors.white),
              label: Text('COBRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: saleProvider.currentItems.isEmpty 
                ? null 
                : () => _showCheckoutDialog(context, saleProvider),
            )
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, SaleProvider saleProvider) {
    final TextEditingController _ticketController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Finalizar Venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total a cobrar: \$${saleProvider.currentTotal.toStringAsFixed(0)}', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextField(
                controller: _ticketController,
                decoration: InputDecoration(
                  labelText: 'Número de Comanda Física',
                  hintText: 'Ej: 104',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (_ticketController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ingrese el número de comanda física')));
                  return;
                }
                
                await saleProvider.saveCurrentSaleWithTicket(_ticketController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venta registrada con éxito')));
              },
              child: Text('Guardar Venta'),
            )
          ],
        );
      }
    );
  }
}
