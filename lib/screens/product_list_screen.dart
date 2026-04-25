import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos (Menú)'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                  SizedBox(height: 16),
                  Text('No hay productos registrados.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          final displayedProducts = _searchQuery.isEmpty 
              ? productProvider.products 
              : productProvider.products.where((p) {
                  final query = _searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(query) || 
                         (p.category != null && p.category!.toLowerCase().contains(query));
                }).toList();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o categoría...',
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              if (displayedProducts.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text('No se encontraron coincidencias', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      final product = displayedProducts[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(Icons.shopping_bag, color: Colors.blue.shade700),
                          ),
                          title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                Text('  •  ${product.category ?? "Sin categoría"}', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 26),
                            onPressed: () {
                              if (product.id != null) {
                                productProvider.deleteProduct(product.id!);
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductFormScreen(product: product),
                              ),
                            );
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Nuevo Producto', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductFormScreen(),
            ),
          );
        },
      ),
    );
  }
}
