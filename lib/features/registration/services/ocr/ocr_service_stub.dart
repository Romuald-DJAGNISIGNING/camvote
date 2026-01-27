import 'ocr_models.dart';
import 'ocr_service.dart';

OcrService createOcrServiceImpl() => _StubOcrService();

class _StubOcrService implements OcrService {
  @override
  Future<OcrExtractedIdentity> recognize({
    required String imagePath,
    required OfficialDocumentType docType,
  }) async {
    throw UnsupportedError('OCR is not supported on Web/Desktop.');
  }
}