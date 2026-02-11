import 'package:camvote/core/errors/error_message.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/voting_center.dart';
import '../providers/voting_centers_providers.dart';

class AdminVotingCentersScreen extends ConsumerStatefulWidget {
  const AdminVotingCentersScreen({super.key});

  @override
  ConsumerState<AdminVotingCentersScreen> createState() =>
      _AdminVotingCentersScreenState();
}

class _AdminVotingCentersScreenState
    extends ConsumerState<AdminVotingCentersScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final centersAsync = ref.watch(votingCentersProvider);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.adminVotingCentersTitle),
        actions: [
          IconButton(
            tooltip: t.adminVotingCentersImportCsv,
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => _openImport(context),
          ),
          IconButton(
            tooltip: t.add,
            icon: const Icon(Icons.add),
            onPressed: () => _openEditor(context, null),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: centersAsync.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) =>
                Center(child: Text(safeErrorMessage(context, e))),
            data: (centers) {
              final filtered = _filterCenters(centers);
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.adminVotingCentersTitle,
                        subtitle: t.adminVotingCentersSubtitle(filtered.length),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _search = value),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: t.votingCentersSearchHint,
                              suffixIcon: _search.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _search = '');
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(t.votingCentersEmpty),
                          ),
                        )
                      else
                        ...filtered.map(
                          (center) => Card(
                            child: ListTile(
                              leading: Icon(
                                center.isAbroad
                                    ? Icons.public
                                    : Icons.location_on_outlined,
                              ),
                              title: Text(center.name),
                              subtitle: Text(center.displaySubtitle),
                              trailing: Wrap(
                                spacing: 6,
                                children: [
                                  if (center.type.isNotEmpty)
                                    _Tag(text: center.type),
                                  _Tag(text: center.status),
                                ],
                              ),
                              onTap: () => _openEditor(context, center),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<VotingCenter> _filterCenters(List<VotingCenter> centers) {
    final needle = _search.trim().toLowerCase();
    if (needle.isEmpty) return centers;
    return centers.where((c) {
      return c.name.toLowerCase().contains(needle) ||
          c.address.toLowerCase().contains(needle) ||
          c.city.toLowerCase().contains(needle) ||
          c.regionCode.toLowerCase().contains(needle) ||
          c.country.toLowerCase().contains(needle);
    }).toList();
  }

  Future<void> _openEditor(BuildContext context, VotingCenter? center) async {
    final repo = ref.read(votingCentersRepositoryProvider);
    final updated = await showModalBottomSheet<VotingCenter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CenterEditorSheet(center: center),
    );
    if (updated == null) return;
    await repo.upsert(updated);
  }

  Future<void> _openImport(BuildContext context) async {
    final repo = ref.read(votingCentersRepositoryProvider);
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<List<VotingCenter>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.adminVotingCentersImportCsv),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: t.adminVotingCentersImportHint,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = _parseCsv(controller.text);
              Navigator.pop(context, parsed);
            },
            child: Text(t.importAction),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    await repo.upsertBatch(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.adminVotingCentersImportDone(result.length))),
      );
    }
  }

  List<VotingCenter> _parseCsv(String raw) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return [];

    final headers = _parseCsvLine(
      lines.first,
    ).map((h) => h.trim().toLowerCase()).toList();
    if (headers.isEmpty) return [];

    final centers = <VotingCenter>[];
    for (final line in lines.skip(1)) {
      final values = _parseCsvLine(line);
      if (values.isEmpty) continue;
      final data = <String, String>{};
      for (var i = 0; i < headers.length && i < values.length; i++) {
        data[headers[i]] = values[i].trim();
      }
      centers.add(_centerFromMap(data));
    }
    return centers;
  }

  VotingCenter _centerFromMap(Map<String, String> data) {
    String getValue(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.trim().isNotEmpty) return value.trim();
      }
      return '';
    }

    final name = getValue(['name', 'center_name', 'station']);
    final address = getValue(['address', 'street']);
    final city = getValue(['city', 'locality', 'town']);
    final regionCode = getValue(['region_code', 'region']);
    final regionName = getValue(['region_name']);
    final country = getValue(['country', 'country_name']);
    final countryCode = getValue(['country_code', 'countrycode', 'iso']);
    final type = getValue(['type', 'center_type']);
    final status = getValue(['status']);
    final contact = getValue(['contact', 'phone', 'email']);
    final notes = getValue(['notes', 'note', 'remarks']);
    final lat = double.tryParse(getValue(['latitude', 'lat'])) ?? 0;
    final lng = double.tryParse(getValue(['longitude', 'lng', 'long'])) ?? 0;

    return VotingCenter(
      id: '',
      name: name,
      address: address,
      regionCode: regionCode,
      regionName: regionName,
      city: city,
      country: country,
      countryCode: countryCode.isEmpty ? 'CM' : countryCode,
      type: type.isEmpty ? 'domestic' : type,
      latitude: lat,
      longitude: lng,
      status: status.isEmpty ? 'active' : status,
      contact: contact,
      notes: notes,
      distanceKm: null,
    );
  }

  List<String> _parseCsvLine(String line) {
    final out = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    var i = 0;
    while (i < line.length) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i += 2;
          continue;
        }
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        out.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
      i += 1;
    }
    out.add(buffer.toString());
    return out;
  }
}

class _CenterEditorSheet extends ConsumerStatefulWidget {
  const _CenterEditorSheet({required this.center});

  final VotingCenter? center;

  @override
  ConsumerState<_CenterEditorSheet> createState() => _CenterEditorSheetState();
}

class _CenterEditorSheetState extends ConsumerState<_CenterEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _regionCode;
  late final TextEditingController _regionName;
  late final TextEditingController _country;
  late final TextEditingController _countryCode;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late final TextEditingController _contact;
  late final TextEditingController _notes;

  String _type = 'domestic';
  String _status = 'active';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final center = widget.center;
    _name = TextEditingController(text: center?.name ?? '');
    _address = TextEditingController(text: center?.address ?? '');
    _city = TextEditingController(text: center?.city ?? '');
    _regionCode = TextEditingController(text: center?.regionCode ?? '');
    _regionName = TextEditingController(text: center?.regionName ?? '');
    _country = TextEditingController(text: center?.country ?? 'Cameroon');
    _countryCode = TextEditingController(text: center?.countryCode ?? 'CM');
    _latitude = TextEditingController(
      text: center == null || center.latitude == 0
          ? ''
          : center.latitude.toString(),
    );
    _longitude = TextEditingController(
      text: center == null || center.longitude == 0
          ? ''
          : center.longitude.toString(),
    );
    _contact = TextEditingController(text: center?.contact ?? '');
    _notes = TextEditingController(text: center?.notes ?? '');
    _type = center?.type.isNotEmpty == true ? center!.type : 'domestic';
    _status = center?.status.isNotEmpty == true ? center!.status : 'active';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _regionCode.dispose();
    _regionName.dispose();
    _country.dispose();
    _countryCode.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _contact.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isEditing = widget.center != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? t.adminVotingCentersEditTitle
                      : t.adminVotingCentersCreateTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _name,
                  label: t.centerNameLabel,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? t.requiredField : null,
                ),
                _Field(
                  controller: _address,
                  label: t.centerAddressLabel,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? t.requiredField : null,
                ),
                _Field(controller: _city, label: t.centerCityLabel),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _regionCode,
                        label: t.centerRegionCodeLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(
                        controller: _regionName,
                        label: t.centerRegionNameLabel,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _country,
                        label: t.centerCountryLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(
                        controller: _countryCode,
                        label: t.centerCountryCodeLabel,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller: _latitude,
                        label: t.centerLatitudeLabel,
                        keyboard: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Field(
                        controller: _longitude,
                        label: t.centerLongitudeLabel,
                        keyboard: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                if (!kIsWeb)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _saving ? null : _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text(t.useMyLocation),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _Dropdown(
                        value: _type,
                        label: t.centerTypeLabel,
                        items: [
                          _DropdownItem('domestic', t.centerTypeDomestic),
                          _DropdownItem('embassy', t.centerTypeEmbassy),
                          _DropdownItem('consulate', t.centerTypeConsulate),
                          _DropdownItem('diaspora', t.centerTypeDiaspora),
                          _DropdownItem('other', t.centerTypeOther),
                        ],
                        onChanged: (value) => setState(() => _type = value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Dropdown(
                        value: _status,
                        label: t.centerStatusLabel,
                        items: [
                          _DropdownItem('active', t.centerStatusActive),
                          _DropdownItem('inactive', t.centerStatusInactive),
                          _DropdownItem('pending', t.centerStatusPending),
                        ],
                        onChanged: (value) => setState(() => _status = value),
                      ),
                    ),
                  ],
                ),
                _Field(controller: _contact, label: t.centerContactLabel),
                _Field(
                  controller: _notes,
                  label: t.centerNotesLabel,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: Text(t.save),
                      ),
                    ),
                  ],
                ),
                if (isEditing) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: _saving ? null : _confirmDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(t.delete),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final lat = double.tryParse(_latitude.text.trim()) ?? 0;
    final lng = double.tryParse(_longitude.text.trim()) ?? 0;
    final center = VotingCenter(
      id: widget.center?.id ?? '',
      name: _name.text.trim(),
      address: _address.text.trim(),
      regionCode: _regionCode.text.trim(),
      regionName: _regionName.text.trim(),
      city: _city.text.trim(),
      country: _country.text.trim(),
      countryCode: _countryCode.text.trim(),
      type: _type.trim(),
      latitude: lat,
      longitude: lng,
      status: _status.trim(),
      contact: _contact.text.trim(),
      notes: _notes.text.trim(),
      distanceKm: null,
    );

    if (mounted) {
      Navigator.pop(context, center);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _saving = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _latitude.text = pos.latitude.toString();
      _longitude.text = pos.longitude.toString();
    } catch (_) {
      // ignore - location is optional
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final t = AppLocalizations.of(context);
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.delete),
            content: Text(t.adminVotingCentersDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;
    final repo = ref.read(votingCentersRepositoryProvider);
    await repo.delete(widget.center?.id ?? '');
    if (mounted) Navigator.pop(context);
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyboard,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _DropdownItem {
  const _DropdownItem(this.value, this.label);
  final String value;
  final String label;
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final String label;
  final List<_DropdownItem> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem(value: item.value, child: Text(item.label)),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(80),
        ),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}


