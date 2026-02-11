import '../../../core/network/worker_client.dart';
import '../domain/voter_countdown_profile.dart';

class VoterProfileRepository {
  VoterProfileRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Future<VoterCountdownProfile?> fetchProfile(String uid) async {
    if (uid.trim().isEmpty) return null;
    final response = await _workerClient.get('/v1/user/profile');
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    return VoterCountdownProfile.fromJson(data);
  }
}
