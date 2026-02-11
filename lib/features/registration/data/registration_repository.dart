import '../../../core/network/worker_client.dart';
import '../models/registration_submission.dart';
import '../models/registration_submission_result.dart';
import '../../../shared/security/device_fingerprint.dart';

class RegistrationRepository {
  RegistrationRepository({WorkerClient? client})
    : _client = client ?? WorkerClient();

  final WorkerClient _client;

  Future<RegistrationSubmissionResult> submit(
    RegistrationSubmission submission,
  ) async {
    final deviceHash = await DeviceFingerprint.compute();
    final result = await _client.post(
      '/v1/registration/submit',
      data: {...submission.toJson(), 'deviceHash': deviceHash},
    );
    return RegistrationSubmissionResult.fromJson(result);
  }

  Future<RegistrationSubmissionResult> renew(
    RegistrationSubmission submission, {
    String? existingRegistrationId,
    String? renewalToken,
  }) async {
    final deviceHash = await DeviceFingerprint.compute();
    final payload = <String, dynamic>{
      ...submission.toJson(),
      'renewal': true,
      'deviceHash': deviceHash,
    };
    if (existingRegistrationId != null && existingRegistrationId.isNotEmpty) {
      payload['existingRegistrationId'] = existingRegistrationId;
    }
    if (renewalToken != null && renewalToken.isNotEmpty) {
      payload['renewalToken'] = renewalToken;
    }

    final result = await _client.post('/v1/registration/submit', data: payload);
    return RegistrationSubmissionResult.fromJson(result);
  }
}
