import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/registration_identity.dart';
import '../services/ocr/ocr_models.dart';
import '../services/ocr/ocr_parser.dart';
import '../services/ocr/ocr_service.dart';

@immutable
class RegistrationOcrState {
  final OfficialDocumentType docType;
  final OcrStatus status;
  final XFile? pickedImage;
  final OcrExtractedIdentity? extracted;
  final OcrValidationResult? validation;
  final String? error;

  const RegistrationOcrState({
    required this.docType,
    required this.status,
    this.pickedImage,
    this.extracted,
    this.validation,
    this.error,
  });

  factory RegistrationOcrState.initial() => const RegistrationOcrState(
    docType: OfficialDocumentType.nationalId,
    status: OcrStatus.idle,
  );

  RegistrationOcrState copyWith({
    OfficialDocumentType? docType,
    OcrStatus? status,
    XFile? pickedImage,
    OcrExtractedIdentity? extracted,
    OcrValidationResult? validation,
    String? error,
  }) {
    return RegistrationOcrState(
      docType: docType ?? this.docType,
      status: status ?? this.status,
      pickedImage: pickedImage ?? this.pickedImage,
      extracted: extracted ?? this.extracted,
      validation: validation ?? this.validation,
      error: error,
    );
  }
}

final registrationOcrControllerProvider =
    NotifierProvider.autoDispose<
      RegistrationOcrController,
      RegistrationOcrState
    >(RegistrationOcrController.new);

class RegistrationOcrController extends Notifier<RegistrationOcrState> {
  final _picker = ImagePicker();
  late final OcrService _ocr = createOcrService();

  @override
  RegistrationOcrState build() => RegistrationOcrState.initial();

  void setDocType(OfficialDocumentType type) {
    state = state.copyWith(docType: type);
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(status: OcrStatus.picking, error: null);
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (img == null) {
      state = state.copyWith(status: OcrStatus.idle);
      return;
    }
    state = state.copyWith(status: OcrStatus.idle, pickedImage: img);
  }

  Future<void> captureWithCamera() async {
    state = state.copyWith(status: OcrStatus.picking, error: null);
    final img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (img == null) {
      state = state.copyWith(status: OcrStatus.idle);
      return;
    }
    state = state.copyWith(status: OcrStatus.idle, pickedImage: img);
  }

  Future<void> runOcrAndValidate(RegistrationIdentity expected) async {
    final img = state.pickedImage;
    if (img == null) {
      state = state.copyWith(error: 'No image selected.');
      return;
    }

    state = state.copyWith(
      status: OcrStatus.processing,
      error: null,
      validation: null,
    );

    try {
      final extracted = await _ocr.recognize(
        imagePath: img.path,
        docType: state.docType,
      );

      // If MRZ parsed passport: placeOfBirth might be null -> fail strictly
      final validation = OcrParser.validate(
        expectedFullName: expected.fullName,
        expectedDob: expected.dateOfBirth,
        expectedPlaceOfBirth: expected.placeOfBirth,
        expectedNationality: expected.nationality,
        docType: state.docType,
        extracted: extracted,
      );

      state = state.copyWith(
        status: OcrStatus.done,
        extracted: extracted,
        validation: validation,
      );
    } catch (e) {
      state = state.copyWith(status: OcrStatus.failed, error: e.toString());
    }
  }

  void reset() {
    state = RegistrationOcrState.initial();
  }
}
