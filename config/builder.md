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

**/mnt/home-hdd/posgres/ Size 1.3G** - Utilties to run tile rendering.
1. Tirex - the background process to render tiles;
2. Mapnik style;
3. mod_tile - apache module to render tiles & redirect to tirex;
4. osm2pgsql - to update gis database for mapnik
[Backup]


**/mnt/home-hdd/releases/ Size 19G** - The directory contains all OsmAnd releases as apk files.
[Backup]

**/mnt/home-hdd/relief-data/ Size 1.5T** - Contains all STRM data. [Backup] ???
Structure (explain structure & possibly rename folders ??? ):
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
* 26G	./SRTM_V41_CGIAR_ASTER_hillshade-compressed.sqlitedb
* 22G	./SRTM_Hillshade_tiles_TMS.zip
* 4.0K ./delete_old_aosmc.sh

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
* mysql - 1.5 GB ( database ???)
* docker - 27 GB ( osmand/java8 - wikigen, overpass, images with compilation)
* jenkins - 17 GB
* postgresql - 15 GB ? database ???

**Android SDK installed packages:**
```
Installed packages:
  Path                              | Version | Description                       | Location                         
  -------                           | ------- | -------                           | -------                          
  add-ons;addon-g..._apis-google-10 | 2.0.0   | Google APIs, Android 10, rev 2    | add-ons/addon-g...apis-google-10/
  add-ons;addon-g..._apis-google-11 | 1.0.0   | Google APIs, Android 11           | add-ons/addon-g...apis-google-11/
  add-ons;addon-g..._apis-google-12 | 1.0.0   | Google APIs, Android 12           | add-ons/addon-g...apis-google-12/
  add-ons;addon-g..._apis-google-13 | 1.0.0   | Google APIs, Android 13           | add-ons/addon-g...apis-google-13/
  add-ons;addon-g..._apis-google-14 | 2.0.0   | Google APIs, Android 14, rev 2    | add-ons/addon-g...apis-google-14/
  add-ons;addon-g..._apis-google-15 | 2.0.0   | Google APIs, Android 15, rev 2    | add-ons/addon-g...apis-google-15/
  add-ons;addon-g..._apis-google-16 | 3.0.0   | Google APIs, Android 16, rev 3    | add-ons/addon-g...apis-google-16/
  add-ons;addon-g..._apis-google-17 | 3.0.0   | Google APIs, Android 17, rev 3    | add-ons/addon-g...apis-google-17/
  add-ons;addon-g..._apis-google-18 | 3.0.0   | Google APIs, Android 18, rev 3    | add-ons/addon-g...apis-google-18/
  add-ons;addon-g..._apis-google-19 | 10.0.0  | Google APIs (ARM System Image)... | add-ons/addon-g...is-google-19-2/
  add-ons;addon-g..._apis-google-21 | 1.0.0   | Google APIs, Android 21           | add-ons/addon-g...apis-google-21/
  add-ons;addon-g...e_apis-google-3 | 3.0.0   | Google APIs, Android 3, rev 3     | add-ons/addon-g..._apis-google-3/
  add-ons;addon-g...e_apis-google-4 | 2.0.0   | Google APIs, Android 4, rev 2     | add-ons/addon-g..._apis-google-4/
  add-ons;addon-g...e_apis-google-7 | 1.0.0   | Google APIs, Android 7            | add-ons/addon-g..._apis-google-7/
  add-ons;addon-g...e_apis-google-8 | 2.0.0   | Google APIs, Android 8, rev 2     | add-ons/addon-g..._apis-google-8/
  add-ons;addon-g...s_x86-google-19 | 10.0.0  | Google APIs (x86 System Image)... | add-ons/addon-g..._x86-google-19/
  add-ons;addon-g...e_gdk-google-19 | 11.0.0  | Glass Development Kit Preview,... | add-ons/addon-g..._gdk-google-19/
  add-ons;addon-g...addon-google-12 | 2.0.0   | Google TV Addon, Android 12, r... | add-ons/addon-g...ddon-google-12/
  add-ons;addon-g...addon-google-13 | 1.0.0   | Google TV Addon, Android 13       | add-ons/addon-g...ddon-google-13/
  build-tools;19.0.0                | 19.0.0  | Android SDK Build-Tools 19        | build-tools/19.0.0/              
  build-tools;19.0.1                | 19.0.1  | Android SDK Build-Tools 19.0.1    | build-tools/19.0.1/              
  build-tools;19.0.2                | 19.0.2  | Android SDK Build-Tools 19.0.2    | build-tools/19.0.2/              
  build-tools;19.0.3                | 19.0.3  | Android SDK Build-Tools 19.0.3    | build-tools/19.0.3/              
  build-tools;19.1.0                | 19.1.0  | Android SDK Build-Tools 19.1      | build-tools/19.1.0/              
  build-tools;20.0.0                | 20.0.0  | Android SDK Build-Tools 20        | build-tools/20.0.0/              
  build-tools;21.0.0                | 21.0.0  | Android SDK Build-Tools 21        | build-tools/21.0.0/              
  build-tools;21.0.1                | 21.0.1  | Android SDK Build-Tools 21.0.1    | build-tools/21.0.1/              
  build-tools;21.0.2                | 21.0.2  | Android SDK Build-Tools 21.0.2    | build-tools/21.0.2/              
  build-tools;21.1.0                | 21.1.0  | Android SDK Build-Tools 21.1      | build-tools/21.1.0/              
  build-tools;21.1.1                | 21.1.1  | Android SDK Build-Tools 21.1.1    | build-tools/21.1.1/              
  build-tools;21.1.2                | 21.1.2  | Android SDK Build-Tools 21.1.2    | build-tools/21.1.2/              
  build-tools;23.0.0                | 23.0.0  | Android SDK Build-Tools 23        | build-tools/23.0.0/              
  build-tools;23.0.1                | 23.0.1  | Android SDK Build-Tools 23.0.1    | build-tools/23.0.1/              
  build-tools;23.0.3                | 23.0.3  | Android SDK Build-Tools 23.0.3    | build-tools/23.0.3/              
  build-tools;26.0.0                | 26.0.0  | Android SDK Build-Tools 26        | build-tools/26.0.0/              
  build-tools;26.0.1                | 26.0.1  | Android SDK Build-Tools 26.0.1    | build-tools/26.0.1/              
  build-tools;26.0.2                | 26.0.2  | Android SDK Build-Tools 26.0.2    | build-tools/26.0.2/              
  docs                              | 1       | Documentation for Android SDK     | docs/                            
  extras;android;m2repository       | 39.0.0  | Android Support Repository, re... | extras/android/m2repository/     
  extras;android;support            | 23.2.1  | Android Support Library, rev 2... | extras/android/support/          
  extras;google;g...e_play_services | 37.0.0  | Google Play services, rev 37      | extras/google/g..._play_services/
  extras;google;g...ces_fit_preview | 1.0.0   | Google Play services for Fit P... | extras/google/g...es_fit_preview/
  extras;google;g..._services_froyo | 12.0.0  | Google Play services for Froyo... | extras/google/g...services_froyo/
  extras;google;m2repository        | 38.0.0  | Google Repository, rev 38         | extras/google/m2repository/      
  extras;google;play_apk_expansion  | 3.0.0   | Google Play APK Expansion Libr... | extras/google/play_apk_expansion/
  extras;google;play_billing        | 5.0.0   | Google Play Billing Library, r... | extras/google/play_billing/      
  extras;google;play_licensing      | 1.0.0   | Google Play Licensing Library     | extras/google/play_licensing/    
  extras;google;simulators          | 1.0.0   | Android Auto API Simulators       | extras/google/simulators/        
  extras;google;webdriver           | 2.0.0   | Google Web Driver, rev 2          | extras/google/webdriver/         
  platform-tools                    | 26.0.1  | Android SDK Platform-Tools        | platform-tools/                  
  platforms;android-10              | 2       | Android SDK Platform 10, rev 2    | platforms/android-10/            
  platforms;android-11              | 2       | Android SDK Platform 11, rev 2    | platforms/android-11/            
  platforms;android-12              | 3       | Android SDK Platform 12, rev 3    | platforms/android-12/            
  platforms;android-13              | 1       | Android SDK Platform 13           | platforms/android-13/            
  platforms;android-14              | 4       | Android SDK Platform 14, rev 4    | platforms/android-14/            
  platforms;android-15              | 5       | Android SDK Platform 15, rev 5    | platforms/android-15/            
  platforms;android-16              | 5       | Android SDK Platform 16, rev 5    | platforms/android-16/            
  platforms;android-17              | 3       | Android SDK Platform 17, rev 3    | platforms/android-17/            
  platforms;android-18              | 3       | Android SDK Platform 18, rev 3    | platforms/android-18/            
  platforms;android-19              | 4       | Android SDK Platform 19, rev 4    | platforms/android-19/            
  platforms;android-20              | 2       | Android SDK Platform 20, rev 2    | platforms/android-20/            
  platforms;android-21              | 2       | Android SDK Platform 21, rev 2    | platforms/android-21/            
  platforms;android-23              | 1       | Android SDK Platform 23           | platforms/android-23/            
  platforms;android-26              | 1       | Android SDK Platform 26           | platforms/android-26/            
  platforms;android-3               | 4       | Android SDK Platform 3, rev 4     | platforms/android-3/             
  platforms;android-4               | 3       | Android SDK Platform 4, rev 3     | platforms/android-4/             
  platforms;android-7               | 3       | Android SDK Platform 7, rev 3     | platforms/android-7/             
  platforms;android-8               | 3       | Android SDK Platform 8, rev 3     | platforms/android-8/             
  platforms;android-L               | 3       | Android SDK Platform L, rev 3     | platforms/android-L/             
  system-images;a...pis;armeabi-v7a | 3       | Google APIs ARM EABI v7a Syste... | system-images/a...is/armeabi-v7a/
  system-images;a...google_apis;x86 | 3       | Google APIs Intel x86 Atom Sys... | system-images/a...oogle_apis/x86/
  system-images;a...gle_apis;x86_64 | 3       | Google APIs Intel x86 Atom_64 ... | system-images/a...le_apis/x86_64/
  tools                             | 25.2.5  | Android SDK Tools 25.2.5 | tools/
```
**www-download Size 164M** - Directory with the website contents.
Files that should be put manually:
* ./reports/db_conn.php
* ./private/service.json (for Firebase).
**Important! Restrict user access to ./private!**

 
