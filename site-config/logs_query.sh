#!/bin/bash


FOLDER=/var/lib/jenkins/
if [ -z "$START_DATE" ]; then
	START_DATE='01-01-2012'
fi
DATE_CONDITION=" and day >= \'$START_DATE\'"

echo "Calculate Retention"
for i in `seq 1 4`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="_plus"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="_free"
	fi
	if (($i == 1)) || (($i == 3)); then
		SELECT_DATE="D.minday"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		INF="month"
	fi

psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT(ip) allUsers, SUM(count) allFreq,  \
 SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) weekRetUsers, \
 SUM( CASE WHEN maxday >= minday + 7 THEN count ELSE 0 END ) weekRetFreq, \
 SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) monthRetUsers, \
 SUM( CASE WHEN maxday >= minday + 30 THEN count ELSE 0 END ) monthRetFreq, \
 SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) month6RetUsers, \
 SUM( CASE WHEN maxday >= minday + 180 THEN count ELSE 0 END ) month6RetFreq \
from (SELECT ip, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
		count(*) count from requests where $VERSION group by ip HAVING minday >= \'$START_DATE\') D \
group by date order by 1 desc; " > $FOLDER/report_retention_${INF}_1_$VERSION_P

psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT(ip) allUsers, SUM(count) allFreq,  \
 SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) weekRetUsers, \
 SUM( CASE WHEN maxday >= minday + 7 THEN count ELSE 0 END ) weekRetFreq, \
 SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) monthRetUsers, \
 SUM( CASE WHEN maxday >= minday + 30 THEN count ELSE 0 END ) monthRetFreq, \
 SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) month6RetUsers, \
 SUM( CASE WHEN maxday >= minday + 180 THEN count ELSE 0 END ) month6RetFreq \
from (SELECT ip, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
	count(*) count from downloads where $VERSION  group by ip HAVING minday >= \'$START_DATE\') D \
 group by date order by 1 desc; " > $FOLDER/report_retention_${INF}_2_$VERSION_P


psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT(aid) allUsers, round( AVG(starts), 2) avgSt, round(AVG(numberdays), 2) avgNd,  \
 SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) wRetUsers, \
 SUM( CASE WHEN maxday >= minday + 7 THEN starts ELSE 0 END ) wRetSt, \
 SUM( CASE WHEN maxday >= minday + 7 THEN numberdays ELSE 0 END ) wRetNd, \
 SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) mRetUsers, \
 SUM( CASE WHEN maxday >= minday + 30 THEN starts ELSE 0 END ) mRetSt, \
 SUM( CASE WHEN maxday >= minday + 30 THEN numberdays ELSE 0 END ) mRetNd, \
 SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) m6RetUsers, \
 SUM( CASE WHEN maxday >= minday + 180 THEN starts ELSE 0 END ) m6RetSt, \
 SUM( CASE WHEN maxday >= minday + 180 THEN numberdays ELSE 0 END ) m6RetNd \
from (SELECT aid, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
      max(ns) starts, max(nd) numberdays from requests \
      where aid <> '' and $VERSION group by aid HAVING minday >= \'$START_DATE\') D \
group by date order by 1 desc; " > $FOLDER/report_retention_${INF}_3_$VERSION_P
done