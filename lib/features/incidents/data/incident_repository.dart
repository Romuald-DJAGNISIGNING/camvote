import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../models/incident_report.dart';

abstract class IncidentRepository {
  Future<IncidentReportResult> submitIncident(IncidentReport report);
}

class ApiIncidentRepository implements IncidentRepository {
  ApiIncidentRepository(this._dio);

  final Dio _dio;

  void _ensureApiConfigured() {
    if (!AppConfig.hasApiBaseUrl) {
      throw StateError('API base URL is not configured.');
    }
  }

  @override
  Future<IncidentReportResult> submitIncident(IncidentReport report) async {
    _ensureApiConfigured();
    final form = FormData();
    form.fields.addAll([
      MapEntry('title', report.title),
      MapEntry('description', report.description),
      MapEntry('location', report.location),
      MapEntry('occurredAt', report.occurredAt.toIso8601String()),
      MapEntry('category', report.category.apiValue),
      MapEntry('severity', report.severity.apiValue),
    ]);

    if (report.electionId.trim().isNotEmpty) {
      form.fields.add(MapEntry('electionId', report.electionId.trim()));
    }

    for (final file in report.attachments) {
      form.files.add(
        MapEntry(
          'evidence',
          await _toMultipart(file),
        ),
      );
    }

    final res = await _dio.post('/observer/incidents', data: form);
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return IncidentReportResult.fromJson(data);
    }
    throw StateError('Unexpected incident submission response.');
  }

  Future<MultipartFile> _toMultipart(XFile file) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return MultipartFile.fromBytes(bytes, filename: file.name);
    }
    return MultipartFile.fromFile(file.path, filename: file.name);
  }
}
