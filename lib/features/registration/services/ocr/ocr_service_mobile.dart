import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_models.dart';
import 'ocr_parser.dart';
import 'ocr_service.dart';

OcrService createOcrServiceImpl() => _MobileOcrService();

class _MobileOcrService implements OcrService {
  @override
  Future<OcrExtractedIdentity> recognize({
    required String imagePath,
    required OfficialDocumentType docType,
  }) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(input);
      return OcrParser.parse(raw: recognized.text, docType: docType);
    } finally {
      await recognizer.close();
    }
  }
}