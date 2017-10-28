# 1. Jenkins configuration backup
Jenkins backup url	git@bitbucket.org:osmand/jenkins-backup.git

# 2. Home folders
**basemap -> /mnt/home-hdd/basemap/ Size 2.7G** - Directory with the Basemap variants,
basemap sources and upload script. Used in the following jenkins jobs: Maps_ExtractBasemapSource,
Maps_GenerateBasemap. Backup - yes.

**binaries -> /mnt/home-hdd/binaries/ Size 5.7G** -  local ivy repository for OsmAnd libraries + caches of prebuilt third party libraries. 
Used in the following jenkins jobs:
OsmAndCoreAndTools-windows-gcc-64bit, OsmAndCoreAndTools-linux-gcc-64bit, OsmAndCoreAndTools-linux-gcc-64bit,
OsmAndCore-android, OsmAndMapCreator, OsmAndCore-android-arm-test. Backup - yes.

**changesets -> /mnt/home-hdd/changesets/ Size 3.2G** - Directory that contains PostgreSQL Databases
backups. Jobs used in: OsmLiveServer_Rotate_Changesets_DB. Backup - yes.

**docker Size 12KB** - This directory contains Dockerfile of Java for Docker's automated build.
Job used in: Maps_GenerateWikiSqlite. Backup - no.

**indexes -> /mnt/home-hdd/indexes/ Size 94G** - Contains all the generated maps, road-only and wiki maps,
as well as jenkins gen.log files for the generated maps. Used for map generation.
Backup - no.

**osm-planet -> /mnt/home-hdd/osm-planet/ Size 147G** - (Inner structure:
* aosmc -> /mnt/home-ssd/osm-planet/aosmc
* listing_tmp
* osc_tmp
* osm-extract -> /mnt/home-hdd/osm-extract/
* osmc
* osmlive -> /mnt/home-ssd/osm-planet/osmlive/
* planet-latest.o5m
* planet-latest.o5m_bak)
This directory contains all the diffs as well as the world database for Overpass.
Used in all OSM-Live related jobs and Backup_Incremental. Backup - no.  

**overpass -> /mnt/home-ssd/overpass Size 253G** - The directory with Overpass API instance.
Used in: OsmLive_FetchAndUpdateOverpass, Maps_ExtractBasemapSource. Backup - yes.

**posgres -> /mnt/home-hdd/posgres/ Size 1.3G** - Utilties to run tile rendering.
1. Tirex - the background process to render tiles;
2. Mapnik style;
3. mod_tile - apache module to render tiles & redirect to tirex;
4. osm2pgsql - to update gis database for mapnik
Used in Planet_UpdateMapnik job. Backup - yes.

**releases -> /mnt/home-hdd/releases/ Size 19G** - The directory contains all OsmAnd releases as apk files.
Jobs: Osmand-release, WebSite_BackupAdditionalData.
Backup - yes.

**relief-data -> /mnt/home-hdd/relief-data/ Size 1.5T** - Contains all STRM data. Job:
SRTM_CombineSRTMFIlesIntoCountryFile. Backup - no. Inner folders:
* 192G	./terrain-aster-srtm-eudem
* 15G	./contours-osm-bz2-north-eu-test
* 20K	./relief30m/corrected/test/scripts/translations
* 72K	./relief30m/corrected/test/scripts
* 671M	./relief30m/corrected/test
* 20K	./relief30m/corrected/scripts/translations
* 72K	./relief30m/corrected/scripts
* 458G	./relief30m/corrected
* 537G	./relief30m
* 50G	./SRTM-filled
* 34G	./countries-sqlite
* 3.8G	./terrain-north-eu
* 138G	./contours-osm-bz2/COUNTRY_OBF_90M_OLD
* 3.0G	./contours-osm-bz2/COUNTRY_OBF/bak
* 131G	./contours-osm-bz2/COUNTRY_OBF
* 580G	./contours-osm-bz2

**user -> /mnt/home-hdd/user/ Size 685M** - Contains user files. Backup - no.

**wiki -> /mnt/home-ssd/wiki Size 77G** - Temporary directory on SSD to generate wiki maps. Jobs:
/Maps_GenerateWikiSqlite. Backup - no.

**wiki-hdd -> /mnt/home-hdd/wiki/ Size 20K** - Backup - no.

**www -> /mnt/home-hdd/www/ Size 346G** - Contains all the content available for downloading:
* 51G	./indexes
* 42G	./wikigen/regions
* 74G	./wikigen
* 26G	./road-indexes
* 4.0K	./night-builds/2013
* 4.0K	./night-builds/2016
* 4.0K	./night-builds/2014
* 4.0K	./night-builds/2015
* 52G	./night-builds
* 34G	./hillshade
* 97G	./srtm-countries
* 16G	./wiki
Backup - no.
