import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  ProductFormScreen({this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;
  String? _category;
  String? _aliasKeywords;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.name;
      _price = widget.product!.price;
      _category = widget.product!.category;
      _aliasKeywords = widget.product!.aliasKeywords;
    } else {
      _name = '';
      _price = 0.0;
    }
  }

  bool _isNewCategory = false;

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Si el usuario eligió 'Nueva Categoría...' pero no escribió nada o solo se quedó con el flag:
      if (_category == null || _category!.trim().isEmpty || _category == 'Nueva Categoría...') {
        _category = 'General';
      }

      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      if (widget.product == null) {
        productProvider.addProduct(Product(
          name: _name,
          price: _price,
          category: _category,
          aliasKeywords: _aliasKeywords,
        ));
      } else {
        productProvider.updateProduct(Product(
          id: widget.product!.id,
          name: _name,
          price: _price,
          category: _category,
          aliasKeywords: _aliasKeywords,
        ));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    List<String> categories = productProvider.products
        .map((p) => p.category ?? 'General')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
        
    // Asegurar que la categoría del producto actual esté en la lista para evitar crash del Dropdown
    if (_category != null && _category!.isNotEmpty && !categories.contains(_category)) {
      categories.add(_category!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nombre Original (Ej. Limonada Natural)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: widget.product != null ? _price.toString() : '',
                decoration: InputDecoration(labelText: 'Precio (Ej. 8500)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un precio.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              // Selector de Categoría
              DropdownButtonFormField<String>(
                value: _category != null && categories.contains(_category) 
                    ? _category 
                    : (categories.isNotEmpty ? categories.first : null),
                decoration: InputDecoration(labelText: 'Categoría'),
                items: [
                  ...categories.map((String cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  DropdownMenuItem(value: 'Nueva Categoría...', child: Text('Nueva Categoría...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueAccent)))
                ],
                onChanged: (value) {
                  setState(() {
                    _isNewCategory = value == 'Nueva Categoría...';
                    if (!_isNewCategory) {
                      _category = value;
                    } else {
                      _category = ''; // Limpiar para que escriba la nueva
                    }
                  });
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              
              if (_isNewCategory)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Nueva Categoría',
                      fillColor: Colors.blue.shade50,
                      filled: true,
                    ),
                    onChanged: (value) => _category = value,
                    validator: (value) {
                      if (_isNewCategory && (value == null || value.trim().isEmpty)) {
                        return 'Debe escribir el nombre de la categoría';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      if (_isNewCategory) _category = value;
                    },
                  ),
                ),
              TextFormField(
                initialValue: _aliasKeywords,
                decoration: InputDecoration(
                  labelText: 'Alias / Palabras clave separadas por coma',
                  helperText: 'Añade textos del OCR para el fuzzy matching (Ej. L NATURAL, L N/ATURAL)',
                ),
                onSaved: (value) {
                  _aliasKeywords = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
