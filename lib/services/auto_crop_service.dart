import 'dart:io';
import 'package:image/image.dart' as img;

class AutoCropService {
  /// Procesa una imagen buscando aislar un recibo blanco sobre un fondo oscuro.
  /// Retorna un nuevo archivo temporal recortado.
  Future<File> cropReceiptFromDarkBackground(File originalImage) async {
    final imageBytes = await originalImage.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) return originalImage;

    // Reducir la resolución para acelerar el procesamiento de escaneo de píxeles
    img.Image smallImage = img.copyResize(image, width: 800);
    double scaleFactor = image.width / 800;

    int minX = smallImage.width;
    int minY = smallImage.height;
    int maxX = 0;
    int maxY = 0;

    // Umbral de luminosidad. Los píxeles del papel (blanco) tienen alta luminosidad.
    // 200/255 = ~0.78 de intensidad rgb conjunta
    const int threshold = 180;
    int brightPixelsFound = 0;

    for (int y = 0; y < smallImage.height; y++) {
      for (int x = 0; x < smallImage.width; x++) {
        final pixel = smallImage.getPixel(x, y);
        
        // Sumamos los canales RGB para estimar brillo
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final brightness = (r + g + b) ~/ 3;

        if (brightness > threshold) {
          brightPixelsFound++;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    // Si no encontramos un área blanca significativa, no recortamos nada (por si la foto ya está bien estructurada)
    if (brightPixelsFound < (smallImage.width * smallImage.height) * 0.05) {
       return originalImage;
    }

    // Añadir un pequeño margen de seguridad para no cortar letras al filo
    int margin = 20;
    minX = (minX - margin).clamp(0, smallImage.width);
    minY = (minY - margin).clamp(0, smallImage.height);
    maxX = (maxX + margin).clamp(0, smallImage.width);
    maxY = (maxY + margin).clamp(0, smallImage.height);

    int finalMinX = (minX * scaleFactor).toInt();
    int finalMinY = (minY * scaleFactor).toInt();
    int finalMaxX = (maxX * scaleFactor).toInt();
    int finalMaxY = (maxY * scaleFactor).toInt();

    // Recortar la imagen en tamaño original
    img.Image croppedImage = img.copyCrop(
      image,
      x: finalMinX,
      y: finalMinY,
      width: finalMaxX - finalMinX,
      height: finalMaxY - finalMinY,
    );

    // Guardar imagen procesada temporal
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/cropped_receipt.jpg');
    final jpgBytes = img.encodeJpg(croppedImage, quality: 90);
    await tempFile.writeAsBytes(jpgBytes);

    return tempFile;
  }
}
