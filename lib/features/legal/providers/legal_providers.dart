import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_settings_controller.dart';
import '../data/legal_repository.dart';
import '../models/legal_document.dart';

final legalRepositoryProvider = Provider<LegalRepository>((ref) {
  return LegalRepository();
});

final legalDocumentsProvider = FutureProvider.autoDispose<List<LegalDocument>>((
  ref,
) async {
  final repo = ref.watch(legalRepositoryProvider);
  final settings = ref.watch(appSettingsProvider).asData?.value;
  final locale = settings?.locale.languageCode ?? 'en';
  return repo.fetchDocuments(localeCode: locale);
});
