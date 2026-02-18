import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class AdminObserversScreen extends ConsumerStatefulWidget {
  const AdminObserversScreen({super.key});

  @override
  ConsumerState<AdminObserversScreen> createState() =>
      _AdminObserversScreenState();
}

class _AdminObserversScreenState extends ConsumerState<AdminObserversScreen> {
  final _assignController = TextEditingController();
  final _searchController = TextEditingController();
  final _createNameController = TextEditingController();
  final _createUsernameController = TextEditingController();
  final _createEmailController = TextEditingController();
  final _createPasswordController = TextEditingController();
  bool _creating = false;
  bool _isCreatePasswordObscured = true;

  @override
  void dispose() {
    _assignController.dispose();
    _searchController.dispose();
    _createNameController.dispose();
    _createUsernameController.dispose();
    _createEmailController.dispose();
    _createPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observers = ref.watch(observersProvider);
    final query = ref.watch(observersQueryProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.adminObserverManagementTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.adminObserverManagementTitle,
                    subtitle: t.adminObserverManagementSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.adminObserverAssignTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.adminObserverAssignSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _assignController,
                                  decoration: InputDecoration(
                                    hintText: t.adminObserverIdentifierLabel,
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.person_search),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _setRole(context, grant: true),
                                child: Text(t.adminObserverGrantAction),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () =>
                                    _setRole(context, grant: false),
                                child: Text(t.adminObserverRevokeAction),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.adminObserverCreateTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t.adminObserverCreateSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _createNameController,
                            decoration: InputDecoration(
                              labelText: t.nameLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _createEmailController,
                            decoration: InputDecoration(
                              labelText: t.emailLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _createUsernameController,
                            decoration: InputDecoration(
                              labelText: t.adminObserverUsernameLabel,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.alternate_email),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _createPasswordController,
                            obscureText: _isCreatePasswordObscured,
                            decoration: InputDecoration(
                              labelText: t.passwordLabel,
                              helperText: t.adminObserverTempPasswordHelp,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _isCreatePasswordObscured
                                    ? t.showPassword
                                    : t.hidePassword,
                                onPressed: () {
                                  setState(() {
                                    _isCreatePasswordObscured =
                                        !_isCreatePasswordObscured;
                                  });
                                },
                                icon: Icon(
                                  _isCreatePasswordObscured
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _creating
                                  ? null
                                  : () => _createObserver(context),
                              icon: _creating
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_alt_1),
                              label: Text(t.createAction),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: t.adminObserverSearchHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (v) => ref
                            .read(observersQueryProvider.notifier)
                            .update(query.copyWith(query: v)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  observers.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(t.adminObserverEmpty),
                          ),
                        );
                      }
                      return Column(
                        children: items.map((o) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                leading: const Icon(Icons.visibility_outlined),
                                title: Text(
                                  o.fullName.isEmpty ? o.uid : o.fullName,
                                ),
                                subtitle: Text(
                                  [
                                    if (o.email.isNotEmpty) o.email,
                                    t.adminObserverRoleLabel(o.role),
                                    if (o.mustChangePassword)
                                      t.adminObserverMustChangePasswordTag,
                                    t.adminObserverUpdatedLabel(
                                      _formatDateTime(context, o.updatedAt),
                                    ),
                                  ].join(' • '),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: t.adminObserverRevokeAction,
                                      onPressed: () => _setRole(
                                        context,
                                        grant: false,
                                        identifier: o.uid,
                                      ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: t.adminObserverDeleteAction,
                                      onPressed: () =>
                                          _deleteObserver(context, o),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    error: (e, _) =>
                        Center(child: Text(safeErrorMessage(context, e))),
                    loading: () => const Center(child: CamElectionLoader()),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setRole(
    BuildContext context, {
    required bool grant,
    String? identifier,
  }) async {
    final t = AppLocalizations.of(context);
    final value = (identifier ?? _assignController.text).trim();
    if (value.isEmpty) {
      CamToast.show(context, message: t.adminObserverInvalidIdentifier);
      return;
    }
    try {
      await ref
          .read(observerRoleControllerProvider)
          .setRole(identifier: value, grant: grant);
      if (context.mounted) {
        CamToast.show(
          context,
          message: grant
              ? t.adminObserverGrantSuccess
              : t.adminObserverRevokeSuccess,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CamToast.show(context, message: t.genericErrorLabel);
      }
    }
  }

  Future<void> _createObserver(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final fullName = _createNameController.text.trim();
    final email = _createEmailController.text.trim();
    final username = _createUsernameController.text.trim();
    final password = _createPasswordController.text;
    final emailValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

    if (fullName.isEmpty || email.isEmpty || password.length < 8) {
      CamToast.show(context, message: t.requiredField);
      return;
    }
    if (!emailValid) {
      CamToast.show(context, message: t.invalidEmailAddress);
      return;
    }

    setState(() => _creating = true);
    try {
      await ref
          .read(observerRoleControllerProvider)
          .createObserver(
            fullName: fullName,
            email: email,
            temporaryPassword: password,
            username: username,
          );
      if (!context.mounted) return;
      _createNameController.clear();
      _createUsernameController.clear();
      _createEmailController.clear();
      _createPasswordController.clear();
      CamToast.show(context, message: t.adminObserverCreateSuccess);
    } catch (_) {
      if (context.mounted) {
        CamToast.show(context, message: t.genericErrorLabel);
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  Future<void> _deleteObserver(
    BuildContext context,
    ObserverAdminRecord observer,
  ) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.adminObserverDeleteAction),
          content: Text(t.adminObserverDeleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    try {
      await ref
          .read(observerRoleControllerProvider)
          .deleteObserver(identifier: observer.uid);
      if (context.mounted) {
        CamToast.show(context, message: t.adminObserverDeleteSuccess);
      }
    } catch (_) {
      if (context.mounted) {
        CamToast.show(context, message: t.genericErrorLabel);
      }
    }
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date $time';
  }
}
