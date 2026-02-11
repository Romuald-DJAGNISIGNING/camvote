import '../../../core/network/worker_client.dart';
import '../models/about_profile.dart';

class AboutRepository {
  AboutRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Future<AboutProfile?> fetchProfile() async {
    final response = await _workerClient.get(
      '/v1/public/about-profile',
      authRequired: false,
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return AboutProfile.fromJson(data);
  }
}
