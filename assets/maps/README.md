Cameroon map layers (bundled)
=============================

Lightweight GeoJSON boundaries used by the Flutter map widgets (region overlays, election heatmaps).

Included files
- `cm_admin0_geoboundaries.geojson` — national boundary (ADM0, simplified)
- `cm_admin1_geoboundaries.geojson` — regions (ADM1, simplified)
- `cm_admin2_geoboundaries.geojson` — departments (ADM2, simplified)

Source & refresh
- geoBoundaries (gbOpen)  
  - https://www.geoboundaries.org/api/current/gbOpen/CMR/ADM0/  
  - https://www.geoboundaries.org/api/current/gbOpen/CMR/ADM1/  
  - https://www.geoboundaries.org/api/current/gbOpen/CMR/ADM2/
- To update: download the latest gbOpen files above, simplify if needed, and replace the GeoJSONs here. Keep file names stable to avoid code changes.

Offline / heavy data
- Large OSM extracts live in `data/maps/` so APK/IPA sizes stay reasonable. Do not move them here unless you intend to ship offline maps.

Licensing
- geoBoundaries gbOpen data is released under the license noted in each metadata file (generally CC BY 4.0 or CC BY 3.0). Preserve attribution in UI where applicable.
