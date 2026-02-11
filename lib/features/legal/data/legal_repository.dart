import '../../../core/network/worker_client.dart';
import '../models/legal_document.dart';

class LegalRepository {
  LegalRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Future<List<LegalDocument>> fetchDocuments({String? localeCode}) async {
    final locale = (localeCode ?? 'en').toLowerCase();
    final response = await _workerClient.get(
      '/v1/legal/documents',
      queryParameters: {'locale': locale},
      authRequired: false,
    );
    final items = response['documents'];
    if (items is! List) return const [];

    return items
        .whereType<Map>()
        .map((doc) {
          final data = (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return LegalDocument(
            id: _asString(doc['id']),
            title: _localized(data, 'title', locale),
            subtitle: _localized(data, 'subtitle', locale),
            content: _localized(data, 'content', locale),
            sourceUrl: _asString(data['sourceUrl'] ?? data['source_url']),
            sourceLabel: _asString(data['sourceLabel'] ?? data['source_label']),
            languageCode: locale,
          );
        })
        .toList();
  }

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  String _localized(Map<String, dynamic> data, String key, String locale) {
    final localizedKey = '${key}_$locale';
    final localized = _asString(data[localizedKey]);
    if (localized.isNotEmpty) return localized;
    return _asString(data[key]);
  }
}
