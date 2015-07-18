# 1. Replicating osm minute updates by using osmupdate

cat >update_empty.osm <<EOL
<?xml version='1.0' encoding='UTF-8'?>
<osm version="0.6" generator="osmconvert 0.8.4" timestamp="2015-07-15T15:55:02Z">
        <bounds minlat="0.5" minlon="0.5" maxlat="0.5" maxlon="0.5"/>
</osm>
EOL

cat >cron_replicate_minute_updates.sh  <<EOL
#!/bin/sh
osmupdate update_empty.osm --minute -v --keep-tempfiles --tempfiles=minutes/m -b=0.5,0.5,0.5,0.5 update_empty_upd.osm
mv update_empty_upd.osm update_empty.osm || echo "Not updated"
EOL

crontab -e 
* * * * * su jenkins && cd /home/osm-planet/osmc/ && ./cron_replicate_minute_updates.sh
schedule it with cron cron_replicate_minute_updates.sh

# 2.
