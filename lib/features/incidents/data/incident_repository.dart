import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/worker_client.dart';

import '../models/incident_report.dart';

abstract class IncidentRepository {
  Future<IncidentReportResult> submitIncident(IncidentReport report);
}

class FirebaseIncidentRepository implements IncidentRepository {
  FirebaseIncidentRepository({
    FirebaseAuth? auth,
    WorkerClient? workerClient,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _workerClient = workerClient ?? WorkerClient();

  final FirebaseAuth _auth;
  final WorkerClient _workerClient;

  @override
  Future<IncidentReportResult> submitIncident(IncidentReport report) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('auth_required');
    }

    final urls = <String>[];
    for (final file in report.attachments) {
      final url = await _uploadEvidence(user.uid, file);
      urls.add(url);
    }
    final response = await _workerClient.post(
      '/v1/incidents/submit',
      data: {
        'title': report.title,
        'description': report.description,
        'location': report.location,
        'occurredAt': report.occurredAt.toIso8601String(),
        'category': report.category.apiValue,
        'severity': report.severity.apiValue,
        'electionId': report.electionId.trim().isEmpty
            ? null
            : report.electionId.trim(),
        'attachments': urls,
      },
    );

    return IncidentReportResult(
      reportId: response['reportId']?.toString() ?? '',
      status: response['status']?.toString() ?? 'submitted',
      message: '',
    );
  }

  Future<String> _uploadEvidence(String uid, XFile file) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final bytes = await file.readAsBytes();
    final contentType = file.mimeType ?? 'application/octet-stream';

    final result = await _workerClient.post(
      '/v1/storage/upload',
      data: {
        'path': 'incident_attachments/$uid/$name',
        'contentBase64': base64Encode(bytes),
        'contentType': contentType,
      },
    );

    final url = result['downloadUrl'] as String? ?? '';
    if (url.isEmpty) {
      throw StateError('upload_failed');
    }
    return url;
  }
}
