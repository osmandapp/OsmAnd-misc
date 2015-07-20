# 1. Replicating osm minute updates by using osmupdate

cat >update_empty.osm <<EOL
<?xml version='1.0' encoding='UTF-8'?>
<osm version="0.6" generator="osmconvert 0.8.4" timestamp="2015-07-15T15:55:02Z">
        <bounds minlat="0.5" minlon="0.5" maxlat="0.5" maxlon="0.5"/>
</osm>
EOL

cat >cron_replicate_minute_updates.sh  <<EOL
#!/bin/sh
osmupdate update_empty.osm --minute -v --keep-tempfiles --tempfiles=_minutes/m -b=0.5,0.5,0.5,0.5 update_empty_upd.osm
mv update_empty_upd.osm update_empty.osm || echo "Not updated"
EOL

crontab -e 
* * * * * su jenkins && cd /home/osm-planet/osmc/ && ./cron_replicate_minute_updates.sh
schedule it with cron cron_replicate_minute_updates.sh

# 2. Split changes per country 
Job http://builder.osmand.net:8080/view/Generate%20Maps/job/MapsDaily_GenerateIndexIdBbbox/
Updates /postgresql/jenkins/bboxid.sqlite (global world id to bbox index) and splits to /home/osm-planet/osmc/$COUNTRY.
It creates 3 files:
1) osc.gz - patch 2) osc.txt - text file 3) ids.txt (ids of objects which related to $COUNTRY)

# 3. Update country.pbf and generates rich osm changes
Job http://builder.osmand.net:8080/job/MapsDaily_GenerateOsmPerCountry/.
It iterates over all downloadable maps and if $FOLDER_NAME.pbf (!) is present in the folder, it applies all minute updates in the folder and create osm.gz file with current day timestamp  (where all changed osm objects are included + all descendentant). For example, if the way was changed osm.gz will contain all the nodes of it, if the relation was changed it will contain all members, if the node was changed it will contain all ways enclosing it.
