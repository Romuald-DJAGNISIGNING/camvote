import 'package:dio/dio.dart';

import '../models/registration_submission.dart';
import '../models/registration_submission_result.dart';

class RegistrationRepository {
  RegistrationRepository(this._dio);

  final Dio _dio;

  Future<RegistrationSubmissionResult> submit(
    RegistrationSubmission submission,
  ) async {
    final res = await _dio.post(
      '/registrations',
      data: submission.toJson(),
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return RegistrationSubmissionResult.fromJson(data);
    }

    throw StateError('Unexpected registration response.');
  }

  Future<RegistrationSubmissionResult> renew(
    RegistrationSubmission submission, {
    String? existingRegistrationId,
    String? renewalToken,
  }) async {
    final payload = <String, dynamic>{
      ...submission.toJson(),
      'renewal': true,
    };
    if (existingRegistrationId != null && existingRegistrationId.isNotEmpty) {
      payload['existing_registration_id'] = existingRegistrationId;
    }
    if (renewalToken != null && renewalToken.isNotEmpty) {
      payload['renewal_token'] = renewalToken;
    }

    final res = await _dio.post(
      '/registrations/renew',
      data: payload,
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return RegistrationSubmissionResult.fromJson(data);
    }

    throw StateError('Unexpected registration renewal response.');
  }
}
