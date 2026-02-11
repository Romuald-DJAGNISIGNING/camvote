import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/admin_support_ticket.dart';
import '../providers/support_providers.dart';

class AdminSupportTicketsScreen extends ConsumerStatefulWidget {
  const AdminSupportTicketsScreen({super.key});

  @override
  ConsumerState<AdminSupportTicketsScreen> createState() =>
      _AdminSupportTicketsScreenState();
}

class _AdminSupportTicketsScreenState
    extends ConsumerState<AdminSupportTicketsScreen> {
  final _searchController = TextEditingController();
  String? _respondingTicketId;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    final q = ref.read(adminSupportQueryProvider);
    _searchController.text = q.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final query = ref.watch(adminSupportQueryProvider);
    final ticketsAsync = ref.watch(adminSupportTicketsProvider);

    return Scaffold(
      appBar: NotificationAppBar(
        title: const Text('Admin Support'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: 'Admin Support',
                    subtitle:
                        'Review support tickets, respond to users, and track ticket status.',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText:
                                  'Search by name, email, registration ID, or message',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) => ref
                                .read(adminSupportQueryProvider.notifier)
                                .update(query.copyWith(query: value)),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<AdminSupportTicketStatus?>(
                            initialValue: query.status,
                            decoration: InputDecoration(
                              labelText: t.filterStatus,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<AdminSupportTicketStatus?>(
                                value: null,
                                child: Text('All statuses'),
                              ),
                              ...AdminSupportTicketStatus.values
                                  .where(
                                    (status) =>
                                        status !=
                                        AdminSupportTicketStatus.unknown,
                                  )
                                  .map(
                                    (status) =>
                                        DropdownMenuItem<
                                          AdminSupportTicketStatus?
                                        >(
                                          value: status,
                                          child: Text(status.label),
                                        ),
                                  ),
                            ],
                            onChanged: (value) => ref
                                .read(adminSupportQueryProvider.notifier)
                                .update(
                                  query.copyWith(
                                    status: value,
                                    clearStatus: value == null,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ticketsAsync.when(
                    data: (tickets) {
                      if (tickets.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('No support tickets found.'),
                          ),
                        );
                      }

                      return Column(
                        children: tickets
                            .map(
                              (ticket) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _TicketCard(
                                  ticket: ticket,
                                  busy: _respondingTicketId == ticket.id,
                                  onRespond: () =>
                                      _openRespondDialog(context, ticket),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    error: (error, _) =>
                        Center(child: Text(safeErrorMessage(context, error))),
                    loading: () => const Center(child: CamElectionLoader()),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(adminSupportTicketsProvider);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _refreshing = false);
    }
  }

  Future<void> _openRespondDialog(
    BuildContext context,
    AdminSupportTicket ticket,
  ) async {
    final initialStatus = switch (ticket.status) {
      AdminSupportTicketStatus.open ||
      AdminSupportTicketStatus.unknown => AdminSupportTicketStatus.answered,
      _ => ticket.status,
    };
    final payload = await _showRespondDialog(
      context: context,
      ticket: ticket,
      initialStatus: initialStatus,
    );
    if (payload == null) return;

    setState(() => _respondingTicketId = ticket.id);
    try {
      await ref
          .read(adminSupportControllerProvider)
          .respond(
            ticketId: ticket.id,
            responseMessage: payload.message,
            status: payload.status,
          );
      if (!context.mounted) return;
      CamToast.show(context, message: 'Ticket updated successfully.');
    } catch (error) {
      if (!context.mounted) return;
      CamToast.show(context, message: safeErrorMessage(context, error));
    } finally {
      if (mounted) {
        setState(() => _respondingTicketId = null);
      }
    }
  }

  Future<_SupportResponsePayload?> _showRespondDialog({
    required BuildContext context,
    required AdminSupportTicket ticket,
    required AdminSupportTicketStatus initialStatus,
  }) async {
    final controller = TextEditingController(text: ticket.responseMessage);
    AdminSupportTicketStatus selectedStatus = initialStatus;

    final result = await showDialog<_SupportResponsePayload>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text('Respond to ticket ${ticket.id}'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<AdminSupportTicketStatus>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'New status',
                        border: OutlineInputBorder(),
                      ),
                      items: AdminSupportTicketStatus.values
                          .where(
                            (status) =>
                                status != AdminSupportTicketStatus.unknown,
                          )
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Response message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final message = controller.text.trim();
                    if (message.isEmpty) return;
                    Navigator.of(dialogContext).pop(
                      _SupportResponsePayload(
                        status: selectedStatus,
                        message: message,
                      ),
                    );
                  },
                  child: const Text('Send response'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.busy,
    required this.onRespond,
  });

  final AdminSupportTicket ticket;
  final bool busy;
  final VoidCallback onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(ticket.updatedAt);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(ticket.updatedAt));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.name.isEmpty ? ticket.id : ticket.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: ticket.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                if (ticket.email.isNotEmpty) ticket.email,
                if (ticket.role.isNotEmpty) ticket.role,
                if (ticket.category.isNotEmpty) ticket.category,
              ].join(' | '),
              style: theme.textTheme.bodySmall,
            ),
            if (ticket.registrationId.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Registration ID: ${ticket.registrationId}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(ticket.message),
            if (ticket.responseMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.primary.withAlpha(18),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(60),
                  ),
                ),
                child: Text(ticket.responseMessage),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Updated $date $time',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                FilledButton.icon(
                  onPressed: busy ? null : onRespond,
                  icon: busy
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mark_email_read_outlined),
                  label: Text(
                    ticket.responseMessage.isEmpty ? 'Respond' : 'Update',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AdminSupportTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      AdminSupportTicketStatus.open => (
        const Color(0xFFFFF2CC),
        const Color(0xFF7A5A00),
      ),
      AdminSupportTicketStatus.answered => (
        const Color(0xFFD7ECFF),
        const Color(0xFF0E4E9B),
      ),
      AdminSupportTicketStatus.resolved => (
        const Color(0xFFD9F4E4),
        const Color(0xFF0A6531),
      ),
      AdminSupportTicketStatus.closed => (
        const Color(0xFFE7E7E7),
        const Color(0xFF454545),
      ),
      AdminSupportTicketStatus.unknown => (
        const Color(0xFFF1E5FF),
        const Color(0xFF5E3B8B),
      ),
    };

    return Chip(
      label: Text(status.label),
      backgroundColor: bg,
      labelStyle: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
      side: BorderSide(color: fg.withAlpha(60)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SupportResponsePayload {
  final AdminSupportTicketStatus status;
  final String message;

  const _SupportResponsePayload({required this.status, required this.message});
}
