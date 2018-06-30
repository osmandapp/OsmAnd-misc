# 1. Jenkins configuration backup
Jenkins backup url	git@bitbucket.org:osmand/jenkins-backup.git

# 2. Home folders. Symlink to /mnt/home-hdd/ (3.1T), /mnt/home-ssd/ (1.5T)
**/mnt/home-hdd/basemap/ Size 2.7G** - Directory with the Basemap variants,
basemap sources and upload script. Used in the following jenkins jobs: Maps_ExtractBasemapSource,
Maps_GenerateBasemap. [Backup]

**/mnt/home-hdd/binaries/ Size 5.7G** -  local ivy repository for OsmAnd libraries + caches of prebuilt third party libraries. 
[Backup]

**/mnt/home-hdd/changesets/ Size 3.2G** - Directory that contains changeset database backups. [Backup]

**/mnt/home-hdd/indexes/ Size 94G** - Contains all the generated maps, road-only and wiki maps, as well as jenkins gen.log files for the generated maps. Used for map generation.

**/mnt/home-hdd/jenkins-workspace/ Size 165G** - Jenkins workspace. [Possible backup]

**/mnt/home-hdd/osm-extract/ Size 295G** - Directory with monthly extracted osm files. 

**/mnt/home-hdd/osm-planet/ Size 147G** - Stores simlinks to osmlive & osmextract + 2 OSM o5m planet files - 75 GB each.

**/mnt/home-hdd/posgres/ Size 1.3G** - Utilities to run tile rendering.
1. Tirex - the background process to render tiles;
2. Mapnik style;
3. mod_tile - apache module to render tiles & redirect to tirex;
4. osm2pgsql - to update gis database for mapnik
[Backup]


**/mnt/home-hdd/releases/ Size 19G** - The directory contains all OsmAnd releases as apk files.
[Backup]

**/mnt/home-hdd/relief-data/ Size 1.5T** - Contains all SRTM data. [Backup] ???
* 192G	./terrain-aster-srtm-eudem - GeoTIFFs
* 34G	./countries-sqlite - hillshade sqlite
* 128G	./contours-osm-bz2/COUNTRY_OBF - generated SRTM obf files
* 440G	./contours-osm-bz2 - contour tiles in OSM format
* 182G	./hillshade - hillshade source files

**/mnt/home-hdd/routing/ Size 7.5G** - Experiments with OSRM routing.

**/mnt/home-hdd/tiles/ Size 560G** - Contains tiles for Mapnik rendering.

**/mnt/home-hdd/user/ Size 685M** - Contains user files. [Backup].

**/mnt/home-hdd/www/ Size 346G** - Contains all the content available for downloading:
* 51G	./indexes
* 42G	./wikigen/regions
* 74G	./wikigen
* 26G	./road-indexes
* 52G	./night-builds [Backup]
* 34G	./hillshade
* 97G	./srtm-countries
* 16G	./wiki

**/mnt/home-ssd/flatnodes Size 40GB** - File to update OSM psql. Nodes cache from osm2psql utility.

**/mnt/home-ssd/tablespace Size 732GB** - OSM psql database to render tiles.

**/mnt/home-ssd/osm-planet/ Size 411GB** - OSM Live 15 minutes update files. Deprecated folder with aosmc & new osm live data in osmlive folder [Backup].

**/mnt/home-ssd/overpass Size 253G** - The directory with Overpass API instance + data.
[Backup] 

**/mnt/home-ssd/wiki Size 77G** - Temporary directory on SSD to generate wiki maps. Jobs:
/Maps_GenerateWikiSqlite.

# 3. /var Folders
**/var/lib/ Size 82GB**– Directory with installed apps.
List of important apps:
* tirex
* android-sdk-latest-linux, android-ndk-r8db,  android-ndk-r10e, android-ndk-r10 - 21.5 GB
* apache2, php
* mysql - 1.5 GB (./wiki 1.4GB - Wiki databases for different regions - deprecated?)
* docker - 27 GB ( osmand/java8 - wikigen, overpass, images with compilation)
* jenkins - 17 GB
* postgresql - 1.3GB (two instances v 9.1 & v 9.3 & some system tables)
**Android SDK installed packages:**
**www-download Size 164M** - Directory with the website contents.
Files that should be put manually:
* ./reports/db_conn.php
* ./private/service.json (for Firebase).
**Important! Restrict user access to ./private!**

**AFTER THE SERVER RESTART DO THE FOLLOWING**

# 4. Tirex
**/etc/tirex/ Size 120K** - mapnik renderer configuration
**How to start tirex:**
As root:
```
mkdir /var/run/tirex
chown postgres:postgres /var/run/tirex
su postgres
tirex-master
tirex-backend-manager
```
Wait 5 minutes and check if requests are processed and rendered using ```tirex-status

# 5. Overpass
**How to start overpass:**  
* systemctl start dispatcher.service 
