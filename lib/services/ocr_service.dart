import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognizeTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    try {
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print('Error during text recognition: $e');
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
