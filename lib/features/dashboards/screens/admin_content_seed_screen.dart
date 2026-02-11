import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_message.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../data/admin_content_seed_service.dart';
import '../providers/admin_providers.dart';

class AdminContentSeedScreen extends ConsumerStatefulWidget {
  const AdminContentSeedScreen({super.key});

  @override
  ConsumerState<AdminContentSeedScreen> createState() =>
      _AdminContentSeedScreenState();
}

class _AdminContentSeedScreenState
    extends ConsumerState<AdminContentSeedScreen> {
  static const _contentCollections = <String>[
    'civic_lessons',
    'election_calendar',
    'transparency_updates',
    'observation_checklist',
    'legal_documents',
    'centers',
    'public_content',
  ];

  bool _overwrite = false;
  bool _includeCenters = true;
  bool _loading = false;
  bool _itemsLoading = false;
  String _selectedCollection = 'civic_lessons';
  List<AdminContentRecord> _items = const [];
  SeedReport? _report;
  String? _error;
  String? _itemsError;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refreshItems);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.adminContentSeedTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.adminContentSeedTitle,
                    subtitle: t.adminContentSeedSubtitle,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null && _error!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!),
                      ),
                    ),
                  if (_error != null && _error!.isNotEmpty)
                    const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: _overwrite,
                          onChanged: _loading
                              ? null
                              : (value) => setState(() => _overwrite = value),
                          title: Text(t.adminContentSeedOverwrite),
                        ),
                        const Divider(height: 1),
                        SwitchListTile.adaptive(
                          value: _includeCenters,
                          onChanged: _loading
                              ? null
                              : (value) =>
                                    setState(() => _includeCenters = value),
                          title: Text(t.adminContentSeedIncludeCenters),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _runSeed(context),
                    icon: _loading
                        ? const CamElectionLoader(size: 18, strokeWidth: 2)
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      _loading
                          ? t.adminContentSeedRunning
                          : t.adminContentSeedAction,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_report != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.adminContentSeedReportTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _ReportRow(
                              label: t.adminContentSeedCivicLessons,
                              value: _report!.civicLessons,
                            ),
                            _ReportRow(
                              label: t.adminContentSeedElectionCalendar,
                              value: _report!.electionCalendar,
                            ),
                            _ReportRow(
                              label: t.adminContentSeedTransparency,
                              value: _report!.transparencyUpdates,
                            ),
                            _ReportRow(
                              label: t.adminContentSeedChecklist,
                              value: _report!.observationChecklist,
                            ),
                            _ReportRow(
                              label: t.adminContentSeedLegalDocs,
                              value: _report!.legalDocuments,
                            ),
                            _ReportRow(
                              label: t.adminContentSeedElectionsInfo,
                              value: _report!.electionsInfo ? 1 : 0,
                            ),
                            _ReportRow(
                              label: t.adminContentSeedCenters,
                              value: _report!.votingCenters,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_report != null) const SizedBox(height: 12),
                  if (_report != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(t.adminContentSeedSuccess),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.adminContentManageTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.adminContentManageSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(_selectedCollection),
                                  initialValue: _selectedCollection,
                                  items: _contentCollections
                                      .map(
                                        (collection) => DropdownMenuItem(
                                          value: collection,
                                          child: Text(collection),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _itemsLoading
                                      ? null
                                      : (value) {
                                          if (value == null) return;
                                          setState(
                                            () => _selectedCollection = value,
                                          );
                                          _refreshItems();
                                        },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                tooltip: MaterialLocalizations.of(
                                  context,
                                ).refreshIndicatorSemanticLabel,
                                onPressed: _itemsLoading ? null : _refreshItems,
                                icon: const Icon(Icons.refresh),
                              ),
                              const SizedBox(width: 6),
                              FilledButton.tonalIcon(
                                onPressed: () => _openEditor(),
                                icon: const Icon(Icons.add),
                                label: Text(t.createAction),
                              ),
                            ],
                          ),
                          if (_itemsError != null &&
                              _itemsError!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              _itemsError!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (_itemsLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: CamElectionLoader(
                                  size: 20,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (_items.isEmpty)
                            Text(
                              t.adminContentManageEmpty,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            Column(
                              children: _items.map((item) {
                                final title = _itemTitle(item);
                                final subtitle = title.isNotEmpty
                                    ? '$title • ${item.id}'
                                    : item.id;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(subtitle),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: t.editAction,
                                        onPressed: () =>
                                            _openEditor(item: item),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: t.delete,
                                        onPressed: () => _deleteItem(item.id),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
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

  Future<void> _runSeed(BuildContext context) async {
    final t = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _error = null;
      _report = null;
    });

    try {
      final service = ref.read(adminContentSeedServiceProvider);
      final report = await service.seedCameroonContent(
        overwrite: _overwrite,
        includeCenters: _includeCenters,
      );
      if (!mounted) return;
      setState(() => _report = report);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.adminContentSeedSuccess)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = safeErrorMessage(context, e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsLoading = true;
      _itemsError = null;
    });
    try {
      final service = ref.read(adminContentSeedServiceProvider);
      final items = await service.fetchItems(collection: _selectedCollection);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (error) {
      if (!mounted) return;
      setState(() => _itemsError = safeErrorMessage(context, error));
    } finally {
      if (mounted) {
        setState(() => _itemsLoading = false);
      }
    }
  }

  Future<void> _openEditor({AdminContentRecord? item}) async {
    final t = AppLocalizations.of(context);
    final idController = TextEditingController(text: item?.id ?? '');
    final initialData = item?.data ?? const <String, dynamic>{};
    final payloadController = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(initialData),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item == null ? t.createAction : t.editAction),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  enabled: item == null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: t.adminContentManageIdLabel,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: payloadController,
                  minLines: 8,
                  maxLines: 14,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: t.adminContentManageJsonLabel,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(item == null ? t.createAction : t.editAction),
            ),
          ],
        );
      },
    );

    if (saved != true) return;
    if (!mounted) return;
    final id = idController.text.trim();
    if (id.isEmpty) {
      CamToast.show(context, message: t.requiredField);
      return;
    }
    try {
      final decoded = jsonDecode(payloadController.text.trim());
      if (decoded is! Map<String, dynamic>) {
        CamToast.show(context, message: t.genericErrorLabel);
        return;
      }
      final service = ref.read(adminContentSeedServiceProvider);
      await service.upsertItem(
        collection: _selectedCollection,
        id: id,
        data: decoded,
      );
      if (!mounted) return;
      CamToast.show(context, message: t.adminContentManageSaved);
      _refreshItems();
    } catch (_) {
      if (mounted) {
        CamToast.show(context, message: t.genericErrorLabel);
      }
    }
  }

  Future<void> _deleteItem(String id) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.delete),
          content: Text(t.adminContentManageDeleteConfirm),
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
      final service = ref.read(adminContentSeedServiceProvider);
      await service.deleteItem(collection: _selectedCollection, id: id);
      if (!mounted) return;
      CamToast.show(context, message: t.adminContentManageDeleted);
      _refreshItems();
    } catch (_) {
      if (mounted) {
        CamToast.show(context, message: t.genericErrorLabel);
      }
    }
  }

  String _itemTitle(AdminContentRecord item) {
    final fields = item.data;
    final title = (fields['title'] ?? fields['name'] ?? '').toString().trim();
    if (title.isNotEmpty) return title;
    final city = (fields['city'] ?? '').toString().trim();
    if (city.isNotEmpty) return city;
    return '';
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final int value;

  const _ReportRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(value.toString(), style: textTheme.labelLarge),
        ],
      ),
    );
  }
}
