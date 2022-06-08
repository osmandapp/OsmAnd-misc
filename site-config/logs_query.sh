#!/bin/bash


FOLDER=/var/lib/jenkins/reports
if [ -z "$START_DATE" ]; then
	START_DATE='2012-01-01'
fi
RSTART="${RSTART:-1}"
REND="${RSTART:-6}"
DATE_CONDITION=" and day >= '$START_DATE'"
echo "Calculate General activity users"
for i in `seq $RSTART $REND`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
		USER_COLUMN="aid"
	elif (($i == 3)) || (($i == 4)); then
		VERSION="version = ''"
		VERSION_P="ios"
		USER_COLUMN="ip"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
		USER_COLUMN="aid"
	fi
	if (($i == 1)) || (($i == 3)) || (($i == 5)); then
		SELECT_DATE="D.minday"
		SELECT_SUBDATE="day"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		SELECT_SUBDATE="substr(day, 0, 8)"
		INF="month"
	fi
	NAME=report_ga_${INF}_$VERSION_P
	echo "General activity users $i. $(date) - $NAME"
	psql -d $DB_NAME -U $DB_USER -c "select count(distinct $USER_COLUMN), $SELECT_SUBDATE date \
	    from requests WHERE $VERSION $DATE_CONDITION group by $SELECT_SUBDATE order by date desc;" > $FOLDER/$NAME
done

echo "Calculate General activity downloads"
for i in `seq $RSTART $REND`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
		USER_COLUMN="ip"
	elif (($i == 3)) || (($i == 4)); then
		VERSION="version like 'OsmAndIOs%'"
		VERSION_P="ios"
		USER_COLUMN="ip"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
		USER_COLUMN="ip"
	fi
	if (($i == 1)) || (($i == 3)) || (($i == 5)); then
		SELECT_DATE="D.minday"
		SELECT_SUBDATE="day"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		SELECT_SUBDATE="substr(day, 0, 8)"
		INF="month"
	fi
	NAME=report_ga_downloads_${INF}_3_$VERSION_P
	echo "General activity downloads $i. $(date) - $NAME"
	psql -d $DB_NAME -U $DB_USER -c "select count(distinct $USER_COLUMN) users, \
		count(*) total_downloads, count(*) ::float / count(distinct $USER_COLUMN) average_per_user, $SELECT_SUBDATE date \
		from downloads WHERE $VERSION $DATE_CONDITION group by $SELECT_SUBDATE order by date desc;" > $FOLDER/$NAME
done



echo "Calculate User acquisition"
for i in `seq $RSTART $REND`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
		USER_COLUMN="aid"
	elif (($i == 3)) || (($i == 4)); then
		VERSION="version = ''"
		VERSION_P="ios"
		USER_COLUMN="ip"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
		USER_COLUMN="aid"
	fi
	if (($i == 1)) || (($i == 3)) || (($i == 5)); then
		SELECT_DATE="D.minday"
		SELECT_SUBDATE="day"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		SELECT_SUBDATE="substr(day, 0, 8)"
		INF="month"
	fi
	NAME=report_ua_${INF}_$VERSION_P
	echo "User acquisition $i. $(date) - $NAME"
	psql -d $DB_NAME -U $DB_USER -c "SELECT count(distinct $USER_COLUMN), $SELECT_SUBDATE date \
		from requests where $VERSION and ns=1 $DATE_CONDITION \
		group by $SELECT_SUBDATE order by date desc;" > $FOLDER/$NAME

done

echo "Calculate Retention"
for i in `seq $RSTART $REND`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
		USER_COLUMN="aid"
	elif (($i == 3)) || (($i == 4)); then
		VERSION="version = ''"
		VERSION_P="ios"
		USER_COLUMN="ip"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
		USER_COLUMN="aid"
	fi
	if (($i == 1)) || (($i == 3)) || (($i == 5)); then
		SELECT_DATE="D.minday"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		INF="month"
	fi
	NAME=report_retention_${INF}_$VERSION_P
	echo "Retention $i. $(date) - $NAME"
psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT($USER_COLUMN) allUsers, round( AVG(starts), 2) avgSt, round(AVG(numberdays), 2) avgNd,  \
 SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) wRetUsers, \
 SUM( CASE WHEN maxday >= minday + 7 THEN starts ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) + 1) wRetSt, \
 SUM( CASE WHEN maxday >= minday + 7 THEN numberdays ELSE 0 END )  / (SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) + 1) wRetNd, \
 SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) mRetUsers, \
 SUM( CASE WHEN maxday >= minday + 30 THEN starts ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) + 1) mRetSt, \
 SUM( CASE WHEN maxday >= minday + 30 THEN numberdays ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) + 1) mRetNd, \
 SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) m6RetUsers, \
 SUM( CASE WHEN maxday >= minday + 180 THEN starts ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) + 1) m6RetSt, \
 SUM( CASE WHEN maxday >= minday + 180 THEN numberdays ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) + 1) m6RetNd \
from (SELECT $USER_COLUMN, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
      max(ns) starts, max(nd) numberdays from requests \
      where $USER_COLUMN <> '' and $VERSION group by $USER_COLUMN HAVING min(day) >= '$START_DATE') D \
group by $SELECT_DATE order by 1 desc; " > $FOLDER/$NAME
done
