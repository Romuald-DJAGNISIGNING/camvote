import 'package:dio/dio.dart';

import '../models/support_ticket.dart';

class SupportRepository {
  SupportRepository(this._dio);

  final Dio _dio;

  Future<SupportTicketResult> submitTicket(SupportTicket ticket) async {
    final res = await _dio.post(
      '/support/tickets',
      data: ticket.toJson(),
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return SupportTicketResult.fromJson(data);
    }

    throw StateError('Unexpected support response.');
  }
}
