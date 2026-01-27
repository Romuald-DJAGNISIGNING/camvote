import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/registration_repository.dart';
import '../models/registration_submission.dart';
import '../models/registration_submission_result.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RegistrationRepository(dio);
});

final registrationSubmissionProvider = AsyncNotifierProvider<
    RegistrationSubmissionController, RegistrationSubmissionResult?>(
  RegistrationSubmissionController.new,
);

class RegistrationSubmissionController
    extends AsyncNotifier<RegistrationSubmissionResult?> {
  @override
  Future<RegistrationSubmissionResult?> build() async => null;

  Future<RegistrationSubmissionResult?> submit(
    RegistrationSubmission submission,
  ) async {
    if (!AppConfig.hasApiBaseUrl) {
      state = AsyncData(
        const RegistrationSubmissionResult(
          registrationId: '',
          status: 'error',
          message: 'API base URL is not configured.',
        ),
      );
      return state.value;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(registrationRepositoryProvider);
      return repo.submit(submission);
    });

    return state.value;
  }

  Future<RegistrationSubmissionResult?> renew(
    RegistrationSubmission submission, {
    String? existingRegistrationId,
    String? renewalToken,
  }) async {
    if (!AppConfig.hasApiBaseUrl) {
      state = AsyncData(
        const RegistrationSubmissionResult(
          registrationId: '',
          status: 'error',
          message: 'API base URL is not configured.',
        ),
      );
      return state.value;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(registrationRepositoryProvider);
      return repo.renew(
        submission,
        existingRegistrationId: existingRegistrationId,
        renewalToken: renewalToken,
      );
    });

    return state.value;
  }
}
