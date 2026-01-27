import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../models/voting_center.dart';
import '../providers/voting_centers_providers.dart';

class VotingCentersMapArgs {
  final bool selectMode;
  final VotingCenter? selectedCenter;

  const VotingCentersMapArgs({
    this.selectMode = false,
    this.selectedCenter,
  });
}

class VotingCentersMapScreen extends ConsumerStatefulWidget {
  const VotingCentersMapScreen({
    super.key,
    this.selectMode = false,
    this.selectedCenter,
  });

  final bool selectMode;
  final VotingCenter? selectedCenter;

  @override
  ConsumerState<VotingCentersMapScreen> createState() =>
      _VotingCentersMapScreenState();
}

class _VotingCentersMapScreenState
    extends ConsumerState<VotingCentersMapScreen> {
  static const _defaultCenter = LatLng(4.0511, 9.7679);
  final _mapController = MapController();
  VotingCenter? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedCenter;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final centersState = ref.watch(votingCentersProvider);
    final centers = ref.watch(votingCentersFilteredProvider);
    final location = ref.watch(votingCentersLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectMode ? t.votingCentersSelectTitle : t.votingCentersTitle,
        ),
      ),
      bottomNavigationBar: widget.selectMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton.icon(
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    _selected == null
                        ? t.votingCenterSelectPrompt
                        : t.votingCenterSelectAction,
                  ),
                ),
              ),
            )
          : null,
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.votingCentersTitle,
                    subtitle: widget.selectMode
                        ? t.votingCentersSelectSubtitle
                        : t.votingCentersSubtitle,
                  ),
                  const SizedBox(height: 12),
                  if (widget.selectMode)
                    _SelectionCard(
                      selected: _selected,
                      onClear: () => setState(() => _selected = null),
                    ),
                  if (widget.selectMode) const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _SearchBar(
                        hintText: t.votingCentersSearchHint,
                        onChanged: (value) => ref
                            .read(votingCentersSearchProvider.notifier)
                            .setQuery(value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _ActionRow(
                        onUseMyLocation: () => ref
                            .read(votingCentersProvider.notifier)
                            .loadNearby(),
                        onRefresh: () => ref
                            .read(votingCentersProvider.notifier)
                            .refreshAll(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  centersState.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: CamElectionLoader(
                          size: 74,
                          strokeWidth: 6,
                        ),
                      ),
                    ),
                    error: (e, _) => _ErrorCard(
                      message: _errorMessage(t, e),
                    ),
                    data: (_) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  CamReveal(
                    child: _MapCard(
                      mapController: _mapController,
                      centers: centers,
                      location: location,
                      selected: _selected,
                      onSelect: (center) {
                        setState(() => _selected = center);
                        _mapController.move(
                          LatLng(center.latitude, center.longitude),
                          13,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MapLegend(
                    hasLocation: location != null,
                  ),
                  const SizedBox(height: 12),
                  _ListHeader(
                    title: t.votingCentersNearbyTitle,
                    subtitle: t.votingCentersNearbySubtitle,
                  ),
                  const SizedBox(height: 8),
                  if (centers.isEmpty)
                    _EmptyState(message: t.votingCentersEmpty)
                  else
                    ...centers.map(
                      (center) => _CenterCard(
                        center: center,
                        selected: _selected?.id == center.id,
                        onTap: () => setState(() => _selected = center),
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

  String _errorMessage(AppLocalizations t, Object error) {
    if (error is LocationFailure) {
      return switch (error.type) {
        LocationFailureType.servicesDisabled => t.locationServicesDisabled,
        LocationFailureType.permissionDenied => t.locationPermissionDenied,
        LocationFailureType.permissionDeniedForever =>
          t.locationPermissionDeniedForever,
      };
    }
    return t.errorWithDetails(error.toString());
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.selected,
    required this.onClear,
  });

  final VotingCenter? selected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text(
          selected == null
              ? t.votingCenterNotSelectedTitle
              : t.votingCenterSelectedTitle,
        ),
        subtitle: Text(
          selected == null
              ? t.votingCenterNotSelectedSubtitle
              : '${selected!.name} • ${selected!.address}',
        ),
        trailing: selected == null
            ? null
            : IconButton(
                tooltip: t.clearSelection,
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onUseMyLocation,
    required this.onRefresh,
  });

  final VoidCallback onUseMyLocation;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onUseMyLocation,
            icon: const Icon(Icons.my_location),
            label: Text(t.useMyLocation),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(t.refresh),
          ),
        ),
      ],
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.hasLocation});

  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.votingCentersLegendTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _LegendItem(
                  color: BrandPalette.ocean,
                  icon: Icons.how_to_vote,
                  label: t.votingCentersLegendCenter,
                ),
                if (hasLocation)
                  _LegendItem(
                    color: BrandPalette.forest,
                    icon: Icons.my_location,
                    label: t.votingCentersLegendYou,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(220),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.mapController,
    required this.centers,
    required this.location,
    required this.selected,
    required this.onSelect,
  });

  final MapController mapController;
  final List<VotingCenter> centers;
  final LatLng? location;
  final VotingCenter? selected;
  final ValueChanged<VotingCenter> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final mapCenter = location ?? _VotingCentersMapScreenState._defaultCenter;
    final zoom = location == null ? 6.4 : 12.4;
    final tileConfig = _MapTileConfig.fromConfig();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.map_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.votingCentersMapTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 320,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: zoom,
                maxZoom: 18,
                minZoom: 4,
              ),
              children: [
                TileLayer(
                  urlTemplate: tileConfig.urlTemplate,
                  additionalOptions: tileConfig.additionalOptions,
                  userAgentPackageName: 'camvote',
                ),
                MarkerLayer(
                  markers: [
                    if (location != null)
                      Marker(
                        point: location!,
                        width: 46,
                        height: 46,
                        child: _LocationMarker(),
                      ),
                    ...centers
                        .where((c) => c.hasValidCoordinates)
                        .map(
                          (center) => Marker(
                            point: LatLng(center.latitude, center.longitude),
                            width: 52,
                            height: 52,
                            child: GestureDetector(
                              onTap: () => onSelect(center),
                              child: _CenterMarker(
                                selected: selected?.id == center.id,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(tileConfig.attribution),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            alignment: Alignment.centerLeft,
            child: Text(
              t.votingCentersMapHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapTileConfig {
  final String urlTemplate;
  final Map<String, String> additionalOptions;
  final String attribution;

  const _MapTileConfig({
    required this.urlTemplate,
    required this.additionalOptions,
    required this.attribution,
  });

  factory _MapTileConfig.fromConfig() {
    final url = AppConfig.mapTileUrl.trim().isEmpty
        ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
        : AppConfig.mapTileUrl.trim();
    final key = AppConfig.mapTileKey.trim();
    final options = <String, String>{};
    if (key.isNotEmpty) {
      options['key'] = key;
      options['token'] = key;
      options['accessToken'] = key;
    }
    final attribution = AppConfig.mapAttribution.trim().isEmpty
        ? '© OpenStreetMap contributors'
        : AppConfig.mapAttribution.trim();
    return _MapTileConfig(
      urlTemplate: url,
      additionalOptions: options,
      attribution: attribution,
    );
  }
}

class _CenterMarker extends StatelessWidget {
  const _CenterMarker({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BrandPalette.ember : BrandPalette.ocean;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: color.withAlpha(230),
        shape: BoxShape.circle,
        boxShadow: BrandPalette.softShadow,
      ),
      child: Center(
        child: Icon(
          Icons.how_to_vote,
          color: Colors.white,
          size: selected ? 22 : 20,
        ),
      ),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrandPalette.forest.withAlpha(220),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.my_location, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard({
    required this.center,
    required this.selected,
    required this.onTap,
  });

  final VotingCenter center;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      color: selected
          ? Theme.of(context).colorScheme.primary.withAlpha(18)
          : null,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.check_circle : Icons.location_on_outlined,
        ),
        title: Text(center.name),
        subtitle: Text(center.address),
        trailing: center.distanceKm == null
            ? null
            : Text(t.distanceKm(center.distanceKm!.toStringAsFixed(1))),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_outlined),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.map_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
