class RegistrationSubmissionResult {
  final String registrationId;
  final String status;
  final String message;
  final String nextAction;
  final bool? cardExpired;
  final String existingRegistrationId;
  final String renewalToken;

  const RegistrationSubmissionResult({
    required this.registrationId,
    required this.status,
    required this.message,
    this.nextAction = '',
    this.cardExpired,
    this.existingRegistrationId = '',
    this.renewalToken = '',
  });

  factory RegistrationSubmissionResult.fromJson(Map<String, dynamic> json) {
    return RegistrationSubmissionResult(
      registrationId:
          (json['registration_id'] as String?) ??
          (json['registrationId'] as String?) ??
          '',
      status: (json['status'] as String?) ?? 'pending',
      message: (json['message'] as String?) ?? '',
      nextAction: (json['next_action'] as String?) ?? '',
      cardExpired: json['card_expired'] as bool?,
      existingRegistrationId:
          (json['existing_registration_id'] as String?) ??
          (json['existingRegistrationId'] as String?) ??
          '',
      renewalToken: (json['renewal_token'] as String?) ?? '',
    );
  }
}
