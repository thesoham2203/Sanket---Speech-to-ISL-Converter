import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      print('Error extracting text: $e');
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

