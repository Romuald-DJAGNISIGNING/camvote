import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../models/incident_report.dart';
import '../providers/incident_providers.dart';

class ObserverIncidentReportScreen extends ConsumerStatefulWidget {
  const ObserverIncidentReportScreen({super.key});

  @override
  ConsumerState<ObserverIncidentReportScreen> createState() =>
      _ObserverIncidentReportScreenState();
}

class _ObserverIncidentReportScreenState
    extends ConsumerState<ObserverIncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _electionCtrl = TextEditingController();
  final _picker = ImagePicker();

  IncidentCategory _category = IncidentCategory.fraud;
  IncidentSeverity _severity = IncidentSeverity.medium;
  DateTime _occurredAt = DateTime.now();
  List<XFile> _attachments = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _electionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final submission = ref.watch(incidentSubmissionProvider);
    final isSubmitting = submission.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(t.observerReportIncidentTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.observerReportIncidentTitle,
                subtitle: t.observerReportIncidentSubtitle,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: InputDecoration(
                            labelText: t.incidentTitleLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? t.requiredField
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<IncidentCategory>(
                          initialValue: _category,
                          decoration: InputDecoration(
                            labelText: t.incidentCategoryLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: IncidentCategory.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.label(t)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _category = v ?? _category),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<IncidentSeverity>(
                          initialValue: _severity,
                          decoration: InputDecoration(
                            labelText: t.incidentSeverityLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: IncidentSeverity.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.label(t)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _severity = v ?? _severity),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: InputDecoration(
                            labelText: t.incidentLocationLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? t.requiredField
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: t.incidentDescriptionLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? t.requiredField
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _electionCtrl,
                          decoration: InputDecoration(
                            labelText: t.incidentElectionIdLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _OccurredAtField(
                          label: t.incidentDateTimeLabel,
                          value: _occurredAt,
                          onPick: () => _pickOccurredAt(context),
                        ),
                        const SizedBox(height: 12),
                        _EvidencePicker(
                          attachments: _attachments,
                          onAddCamera: _addFromCamera,
                          onAddGallery: _addFromGallery,
                          onRemove: _removeAttachment,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isSubmitting
                                ? null
                                : () => _submit(context),
                            child: isSubmitting
                                ? const CamElectionLoader(size: 24, strokeWidth: 3)
                                : Text(t.incidentSubmitAction),
                          ),
                        ),
                        if (submission.hasError) ...[
                          const SizedBox(height: 10),
                          Text(
                            t.errorWithDetails(
                              submission.error?.toString() ?? '',
                            ),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickOccurredAt(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (time == null) return;
    if (!context.mounted) return;
    setState(() {
      _occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _addFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _attachments = [..._attachments, file]);
  }

  Future<void> _addFromGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() => _attachments = [..._attachments, ...files]);
  }

  void _removeAttachment(XFile file) {
    setState(() => _attachments = _attachments.where((f) => f != file).toList());
  }

  Future<void> _submit(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final report = IncidentReport(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      occurredAt: _occurredAt,
      category: _category,
      severity: _severity,
      electionId: _electionCtrl.text.trim(),
      attachments: _attachments,
    );

    final result = await ref
        .read(incidentSubmissionProvider.notifier)
        .submit(report);

    if (result == null || result.status == 'error') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?.message ?? t.incidentSubmissionFailed)),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isNotEmpty
              ? result.message
              : t.incidentSubmittedBody(result.reportId),
        ),
      ),
    );
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _locationCtrl.clear();
    _descCtrl.clear();
    _electionCtrl.clear();
    setState(() {
      _attachments = [];
      _category = IncidentCategory.fraud;
      _severity = IncidentSeverity.medium;
      _occurredAt = DateTime.now();
    });
  }
}

class _EvidencePicker extends StatelessWidget {
  const _EvidencePicker({
    required this.attachments,
    required this.onAddCamera,
    required this.onAddGallery,
    required this.onRemove,
  });

  final List<XFile> attachments;
  final VoidCallback onAddCamera;
  final VoidCallback onAddGallery;
  final ValueChanged<XFile> onRemove;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.incidentEvidenceTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onAddCamera,
              icon: const Icon(Icons.photo_camera),
              label: Text(t.incidentAddCamera),
            ),
            OutlinedButton.icon(
              onPressed: onAddGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(t.incidentAddGallery),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (attachments.isEmpty)
          Text(t.incidentEvidenceEmpty)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attachments
                .map(
                  (file) => Chip(
                    label: Text(file.name),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => onRemove(file),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _OccurredAtField extends StatelessWidget {
  const _OccurredAtField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time =
        MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text('$date • $time'),
      trailing: TextButton(
        onPressed: onPick,
        child: Text(t.changeAction),
      ),
    );
  }
}
