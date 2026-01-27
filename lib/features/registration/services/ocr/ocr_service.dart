import 'ocr_models.dart';

import 'ocr_service_stub.dart'
    if (dart.library.io) 'ocr_service_mobile.dart';

abstract class OcrService {
  Future<OcrExtractedIdentity> recognize({
    required String imagePath,
    required OfficialDocumentType docType,
  });
}

OcrService createOcrService() => createOcrServiceImpl();