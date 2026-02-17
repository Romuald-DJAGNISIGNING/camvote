class RegistrationSubmissionResult {
  final String registrationId;
  final String status;
  final String message;
  final String nextAction;
  final bool? cardExpired;
  final String existingRegistrationId;
  final String renewalToken;
  final bool queuedOffline;
  final String offlineQueueId;

  const RegistrationSubmissionResult({
    required this.registrationId,
    required this.status,
    required this.message,
    this.nextAction = '',
    this.cardExpired,
    this.existingRegistrationId = '',
    this.renewalToken = '',
    this.queuedOffline = false,
    this.offlineQueueId = '',
  });

  factory RegistrationSubmissionResult.fromJson(Map<String, dynamic> json) {
    final queued = json['queued'] == true;
    final queueId =
        (json['offlineQueueId'] as String?) ??
        (json['offline_queue_id'] as String?) ??
        '';
    final registrationId =
        (json['registration_id'] as String?) ??
        (json['registrationId'] as String?) ??
        (queued ? queueId : '');
    return RegistrationSubmissionResult(
      registrationId: registrationId,
      status:
          (json['status'] as String?) ??
          (queued ? 'queued_offline' : 'pending'),
      message: (json['message'] as String?) ?? '',
      nextAction: (json['next_action'] as String?) ?? '',
      cardExpired: json['card_expired'] as bool?,
      existingRegistrationId:
          (json['existing_registration_id'] as String?) ??
          (json['existingRegistrationId'] as String?) ??
          '',
      renewalToken: (json['renewal_token'] as String?) ?? '',
      queuedOffline: queued,
      offlineQueueId: queueId,
    );
  }
}
