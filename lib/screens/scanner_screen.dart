import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../services/ocr_service.dart';
import '../services/comanda_parser_service.dart';
import '../services/auto_crop_service.dart';
import 'validation_screen.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final AutoCropService _cropService = AutoCropService();
  bool _isLoading = false;
  String _loadingMessage = 'Procesando imagen con ML Kit...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _processImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Recortando recibo del fondo oscuro...';
    });

    try {
      final originalFile = File(image.path);
      final croppedFile = await _cropService.cropReceiptFromDarkBackground(originalFile);
      
      setState(() {
         _loadingMessage = 'Extrayendo texto con ML Kit...';
      });
      
      final text = await _ocrService.recognizeTextFromImage(croppedFile);
      
      setState(() {
         _loadingMessage = 'Cruzando productos en catálogo...';
      });
      
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Asegurar forzosamente que los productos estén cargados en memoria ANTES de hacer el cruce OCR.
      // Si el array está vacío, forzamos el await de fetchProducts().
      if (productProvider.products.isEmpty) {
        await productProvider.fetchProducts();
      }
      
      final availableProducts = productProvider.products;
      final parsedComanda = await ComandaParserService.parseTextToSaleItems(text, availableProducts);

      Provider.of<SaleProvider>(context, listen: false).setCurrentItems(
        parsedComanda.items, 
        parsedDate: parsedComanda.date,
        ticketNumber: parsedComanda.ticketNumber,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to validation screen
      if (mounted) {
        // --- INICIO MODO DEBUG (Fase 13) ---
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text('🔍 OCR Debugador (Solo Galería)'),
            content: SingleChildScrollView(
              child: SelectableText(text), // Muestra el texto entero para que el dev pueda analizarlo o copiarlo
            ),
            actions: [
              ElevatedButton(
                child: Text('Continuar a Validación'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ValidationScreen()),
                  );
                },
              )
            ],
          )
        );
        // --- FIN MODO DEBUG ---
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar la imagen')));
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear Comanda')),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(_loadingMessage)
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.receipt_long, size: 100, color: Colors.grey),
                   SizedBox(height: 32),
                   ElevatedButton.icon(
                     icon: Icon(Icons.camera_alt, size: 30),
                     label: Padding(
                       padding: const EdgeInsets.all(12.0),
                       child: Text('Tomar Foto', style: TextStyle(fontSize: 18)),
                     ),
                     style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                     onPressed: () => _processImage(ImageSource.camera),
                   ),
                   SizedBox(height: 16),
                   OutlinedButton.icon(
                     icon: Icon(Icons.photo_library),
                     label: Text('Seleccionar de Galería'),
                     onPressed: () => _processImage(ImageSource.gallery),
                   ),
                ],
              ),
      ),
    );
  }
}
