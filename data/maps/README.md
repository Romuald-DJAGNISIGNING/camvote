Offline map datasets (Cameroon)
===============================

Large, raw geodata for preprocessing or generating offline tiles. Kept out of the app bundle to keep APK/IPA sizes small.

Current files
- `cameroon-latest.osm.pbf` — OSM extract (≈200 MB)
- `cameroon-latest.osm.pbf.md5` — checksum from Geofabrik

Refresh workflow
1) Download the latest extract and checksum from Geofabrik:  
   - https://download.geofabrik.de/africa/cameroon-latest.osm.pbf  
   - https://download.geofabrik.de/africa/cameroon-latest.md5
2) Verify integrity:
   ```bash
   md5sum -c cameroon-latest.osm.pbf.md5
   ```
3) Use this dataset for server-side tile generation or analytics; keep the heavy artifacts here (or in object storage), not in `assets/`.

Notes
- If true offline maps are required in-app, consider generating vector tiles and bundling only the needed regions to avoid bloat.
- When syncing to cloud storage, prefer R2 (primary/backup buckets) to stay aligned with the project’s storage strategy.
