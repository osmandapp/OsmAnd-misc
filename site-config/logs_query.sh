#!/bin/bash


FOLDER=/var/lib/jenkins/
if [ -z "$START_DATE" ]; then
	START_DATE='2012-01-01'
fi
DATE_CONDITION=" and day >= '$START_DATE'"
echo "Calculate General activity users"
for i in `seq 1 4`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
	fi
	if (($i == 1)) || (($i == 3)); then
		SELECT_DATE="D.minday"
		SELECT_SUBDATE="day"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		SELECT_SUBDATE="substr(day, 0, 8)"
		INF="month"
	fi
	echo "1-$i. $(date)"
	psql -d $DB_NAME -U $DB_USER -c "select count(distinct ip), $SELECT_SUBDATE date \
		from requests WHERE $VERSION $DATE_CONDITION group by $SELECT_SUBDATE order by date desc;" > $FOLDER/report_ga_${INF}_1_$VERSION_P

	echo "2-$i. $(date)"
	psql -d $DB_NAME -U $DB_USER -c "select count(distinct aid), $SELECT_SUBDATE date \
	    from requests WHERE $VERSION $DATE_CONDITION group by $SELECT_SUBDATE order by date desc;" > $FOLDER/report_ga_${INF}_2_$VERSION_P
done

echo "Calculate General activity downloads"
for i in `seq 1 4`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
	fi
	if (($i == 1)) || (($i == 3)); then
		SELECT_DATE="D.minday"
		SELECT_SUBDATE="day"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		SELECT_SUBDATE="substr(day, 0, 8)"
		INF="month"
	fi
	echo "1-$i. $(date)"
	psql -d $DB_NAME -U $DB_USER -c "select count(distinct ip) users, \
		count(*) total_downloads, count(*) ::float / count(distinct ip) average_per_user, $SELECT_SUBDATE date \
		from downloads WHERE $VERSION $DATE_CONDITION group by $SELECT_SUBDATE order by date desc;" > $FOLDER/report_ga_downloads_${INF}_3_$VERSION_P
done



echo "Calculate User acquisition"
for i in `seq 1 4`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
	fi
	if (($i == 1)) || (($i == 3)); then
		SELECT_DATE="D.minday"
		SELECT_SUBDATE="day"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		SELECT_SUBDATE="substr(day, 0, 8)"
		INF="month"
	fi
	echo "1-$i. $(date)"
	psql -d $DB_NAME -U $DB_USER -c "SELECT COUNT(ip), $SELECT_DATE date \
	    from (SELECT ip, min(to_date(day,'YYYY-MM-DD')) minday from requests \
	    	  where $VERSION group by ip HAVING min(day) >= '$START_DATE') D \
        group by $SELECT_DATE order by date desc;" > $FOLDER/report_ua_${INF}_2_$VERSION_P
        
	echo "2-$i. $(date)"
	psql -d $DB_NAME -U $DB_USER -c "SELECT count(distinct AID), $SELECT_SUBDATE date \
		from requests where $VERSION and ns=1 $DATE_CONDITION \
		group by $SELECT_SUBDATE order by date desc;" > $FOLDER/report_ua_${INF}_1_$VERSION_P

done

echo "Calculate Retention"
for i in `seq 1 4`; do
	if (($i == 1)) || (($i == 2)); then
		VERSION="version like 'OsmAnd%%2B%'"
		VERSION_P="plus"
	else
		VERSION="version like 'OsmAnd+%'"
		VERSION_P="free"
	fi
	if (($i == 1)) || (($i == 3)); then
		SELECT_DATE="D.minday"
		INF="day"
	else
		SELECT_DATE="to_char(D.minday, 'YYYY-MM')"
		INF="month"
	fi
	# Not working
# 	echo "1-$i. $(date)"
# psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT(ip) allUsers, SUM(count) allFreq,  \
#  SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) weekRetUsers, \
#  SUM( CASE WHEN maxday >= minday + 7 THEN count ELSE 0 END ) weekRetFreq, \
#  SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) monthRetUsers, \
#  SUM( CASE WHEN maxday >= minday + 30 THEN count ELSE 0 END ) monthRetFreq, \
#  SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) month6RetUsers, \
#  SUM( CASE WHEN maxday >= minday + 180 THEN count ELSE 0 END ) month6RetFreq \
# from (SELECT ip, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
# 		count(*) count from requests where $VERSION group by ip HAVING min(day) >= '$START_DATE') D \
# group by $SELECT_DATE order by 1 desc; " > $FOLDER/report_retention_${INF}_1_$VERSION_P
	# echo "2-$i. $(date)"
# psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT(ip) allUsers, SUM(count) allFreq,  \
#  SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) weekRetUsers, \
#  SUM( CASE WHEN maxday >= minday + 7 THEN count ELSE 0 END ) weekRetFreq, \
#  SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) monthRetUsers, \
#  SUM( CASE WHEN maxday >= minday + 30 THEN count ELSE 0 END ) monthRetFreq, \
#  SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) month6RetUsers, \
#  SUM( CASE WHEN maxday >= minday + 180 THEN count ELSE 0 END ) month6RetFreq \
# from (SELECT ip, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
# 	count(*) count from downloads where $VERSION  group by ip HAVING min(day) >= '$START_DATE') D \
#  group by $SELECT_DATE order by 1 desc; " > $FOLDER/report_retention_${INF}_2_$VERSION_P
	echo "1-$i. $(date)"
psql -d $DB_NAME -U $DB_USER -c "SELECT $SELECT_DATE date, COUNT(aid) allUsers, round( AVG(starts), 2) avgSt, round(AVG(numberdays), 2) avgNd,  \
 SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) wRetUsers, \
 SUM( CASE WHEN maxday >= minday + 7 THEN starts ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) + 1) wRetSt, \
 SUM( CASE WHEN maxday >= minday + 7 THEN numberdays ELSE 0 END )  / (SUM( CASE WHEN maxday >= minday + 7 THEN 1 ELSE 0 END ) + 1) wRetNd, \
 SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) mRetUsers, \
 SUM( CASE WHEN maxday >= minday + 30 THEN starts ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) + 1) mRetSt, \
 SUM( CASE WHEN maxday >= minday + 30 THEN numberdays ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 30 THEN 1 ELSE 0 END ) + 1) mRetNd, \
 SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) m6RetUsers, \
 SUM( CASE WHEN maxday >= minday + 180 THEN starts ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) + 1) m6RetSt, \
 SUM( CASE WHEN maxday >= minday + 180 THEN numberdays ELSE 0 END ) / (SUM( CASE WHEN maxday >= minday + 180 THEN 1 ELSE 0 END ) + 1) m6RetNd \
from (SELECT aid, min(to_date(day,'YYYY-MM-DD')) minday, max(to_date(day,'YYYY-MM-DD')) maxday, \
      max(ns) starts, max(nd) numberdays from requests \
      where aid <> '' and $VERSION group by aid HAVING min(day) >= '$START_DATE') D \
group by $SELECT_DATE order by 1 desc; " > $FOLDER/report_retention_${INF}_$VERSION_P
done