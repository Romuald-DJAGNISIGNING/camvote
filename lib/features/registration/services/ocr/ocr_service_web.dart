import 'ocr_models.dart';
import 'ocr_service.dart';

OcrService createOcrServiceImpl() => _WebOcrService();

class _WebOcrService implements OcrService {
  @override
  Future<OcrExtractedIdentity> recognize({
    required String imagePath,
    required OfficialDocumentType docType,
  }) async {
    throw UnsupportedError('OCR is not supported on Web.');
  }
}
