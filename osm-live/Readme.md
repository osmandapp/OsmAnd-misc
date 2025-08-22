## What is OSM-Live ?
OSM-Live process creates OBF files that contains changed OSM objects during a short period of time: for 10 (or more) minutes, for 1 day, for 1 month.
These files have specific naming, such as Us_texas_san-angelo_northamerica_**24_09_13**.obf.gz - for sorting after "main" OBF Us_texas_san-angelo_northamerica_**2**.obf.zip
- `*_24_09_13.obf.gz` - daily file (September 13 2024),
- `*_24_09_00.obf.gz` - monthly file (September 2024),
- `/25_08_20/*_16_50.obf.gz` - minutely file (16:40 - 16:50 August 20 2025)

## What are Jenkins jobs provide them ?
All Jenkins processes described in [Order of Jenkins processes.md](Order%20of%20Jenkins%20processes.md)

## How basically the OSM-Live works ?

1. Using **Overpass** queries we got two main files: `*_before.osm` and `*_after.osm`.<br>
For `*_before.osm` (9:30) :
```
...[date:"2025-08-21T09:30:00Z"];
    // 1. get all nodes, ways, relation changed between START - END
    (
      node(changed:"2025-08-21T09:30:00Z","2025-08-21T09:40:00Z");
      way(changed:"2025-08-21T09:30:00Z","2025-08-21T09:40:00Z");
      relation(changed:"2025-08-21T09:30:00Z","2025-08-21T09:40:00Z");
    )->.a;
```
For `*_after.osm` (9:40) :
```
...[date:"2025-08-21T09:40:00Z"];
    // 1. get all nodes, ways, relation changed between START - END
    (
      node(changed:"2025-08-21T09:30:00Z","2025-08-21T09:40:00Z");
      way(changed:"2025-08-21T09:30:00Z","2025-08-21T09:40:00Z");
      relation(changed:"2025-08-21T09:30:00Z","2025-08-21T09:40:00Z");
    )->.a;
```

2. **Generate** `_before.obf` and `*_after.obf` for whole world using OsmAnd MapCreator.
3. Make `*_diff.obf` - where only changed/deleted objects are present. In the `*_diff.obf` we store objects from `*_after.obf` that are different from `*_before.obf` (created or modified).
5. Split world's `*_diff.obf` into different countries/region files.

## What to do with OSM relations ?

In OsmAnd OBF file we do not save relation directly, but propagate tags from them to way and nodes.<br>

For example, we have relation [`restriction=only_right_turn`](https://www.openstreetmap.org/relation/8085812) and need to include to OSM-live OBF any member of this relation that was changed or the relation itself. In our case these are:
- [From way/1169124687](https://www.openstreetmap.org/way/1169124687)
- [Via node/206392306](https://www.openstreetmap.org/node/206392306)
- [To way/1170508451](https://www.openstreetmap.org/way/1170508451)
- [Relation ownself](https://www.openstreetmap.org/relation/8085812)

#### Overpass fetching
If a way or node was changed, we have to retreive their relation(s) with members and store to `*_before.obf` `*_after.obf`:
```
    // 2.3 retrieve all relations for changed nodes / ways, so we can propagate proper tags to them
    (relation(bn.a);.a;) ->.a;
    (relation(bw.a);.a;) ->.a;
    // 3. final step make all relations / way / node complete
    (way(r.a);.a;) ->.a; 
    (node(r.a);.a;) ->.a;
```

If the relation changed itself when we retreive members (nodes and ways), after retrieving all member's relations (even if incompleted - without all the members included!!!), the data is stored to `*_before_rel.obf` and `*_after_rel.obf`:
```
    // get all relation changed between START - END
    (
      relation(changed:\"$START_DATE\",\"$END_DATE\");
    )->.a;
    // 1. retrieve all members of changed relation (nodes/ways) to set .b    
    (way(r.a);) ->.b; 
    (node(r.a);.b;) ->.b;
    // 2. complete ways
    (node(w.b);.b;) ->.b;
    // 3. find incomplete relations for all members to set .c
    (relation(bw.b);) ->.c;
    (relation(bn.b);.c;) ->.c;
```
Note. `*_before_rel.obf` and `*_after_rel.obf` - needs only for find nodes/ways with propagated relation tags. Relations can be created/modified/deleted and need to be sure that these changes is correctly processing in all their members.

#### Utility `generate-relation-osm` . Create `*_after_rel_m.osm`
```
    echo "### 1. Generate relation osm : $(date -u) . All nodes and ways copy from before_rel to after_rel " &
    $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-relation-osm \
            $DATE_DIR/src/${BASENAME}_before_rel.osm.gz $DATE_DIR/src/${BASENAME}_after_rel.osm.gz \
            $DATE_DIR/src/${BASENAME}_diff.osm.gz ${BASENAME}_after_rel_m.osm.gz
```
Files `*_before_rel.osm` and `*_after_rel.osm` can include different sets of relations. And different relations contains different sets of members (nodes/ways)!!!<br>
- Why is it happen? - Before query on specific time (`$START_DATE` or `$END_DATE`) we do not know what relations was created/deleted. So  `*_before_rel.osm` will consist of deleted relations, and `*_after_rel.osm` will consist of created relations.
- Why is it problem (different sets of nodes/members) ? - Because in `*_diff.obf` we can got many "created" and "deleted" nodes/ways.<br>
- So, what to do? - We just copy nodes/ways from `*_before_rel.osm` to `*_after_rel.osm`.
- Hmm, but nodes/ways in `*_before_rel.osm` can consist of old tags or geometry ?! - Yes, therefore need to use `*_diff.osm` for find all `<action type="create">`, `<action type="modify">`, `<action type="delete">` and correctly copy objects. Good example in the issue [Geometry duplication in live update](https://github.com/osmandapp/OsmAnd/issues/21561) whre made fix that avoid copying modified nodes/ways to `*_after_rel_m.osm`.

## What is next ?
After getting `*_before.osm`, `*_after.osm`, `*_before_rel.osm`, `*_after_rel.osm` and `*_diff.osm` we need:

#### 1. to generate obf files:
```
        echo "### 2. Generate obf files : $(date -u) . Will store into $DATE_DIR/obf/"
        $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-no-address $DATE_DIR/src/${BASENAME}_after.osm.gz  \
            --ram-process --add-region-tags --extra-relations="$LOW_EMMISION_ZONE_FILE" --upload $DATE_DIR/obf/ &
        $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-no-address $DATE_DIR/src/${BASENAME}_before.osm.gz  \
            --ram-process --add-region-tags --extra-relations="$LOW_EMMISION_ZONE_FILE" --upload $DATE_DIR/obf/ &
        $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-no-address-no-multipolygon $DATE_DIR/src/${BASENAME}_before_rel.osm.gz \
            --ram-process --add-region-tags --upload $DATE_DIR/obf/ &
        $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-no-address-no-multipolygon ${BASENAME}_after_rel_m.osm.gz \
            --ram-process --add-region-tags --upload $DATE_DIR/obf/ &
        wait 
```
For `*_rel.osm` files we use `_no-multipolygon_` option because most part of relations are incomplete and multipolygons will be broken!
#### 2. to generate `*_diff.obf` files:
```
        echo "### 1. Generate diff files : $(date -u)"
        $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-diff \
            ${BEFORE_OBF_FILE} ${AFTER_OBF_FILE} ${BASENAME}_diff.obf $DIFF_FILE &
        $OSMAND_MAP_CREATOR_PATH/utilities.sh generate-obf-diff-no-transport \
            ${BEFORE_REL_OBF_FILE} ${AFTER_REL_M_OBF_FILE} ${BASENAME}_diff_rel.obf &
        wait
```
Where `$DIFF_FILE` is `*_diff.osm` file with OSM changesets that consist of `<action type="create">`, `<action type="modify">`, `<action type="delete">`
#### to merge `*_diff.obf` and `*_diff_rel.obf`:
```
$OSMAND_MAP_CREATOR_PATH/utilities.sh merge-obf-diff ${BASENAME}_diff_rel.obf ${BASENAME}_diff.obf ${BASENAME}_diff_merged.obf
```
During merge we need to remember that the data from `*_diff.obf` has full integrity. But the data from `*_diff_rel.obf` are based on incompleted data (see point Utility _generate-relation-osm_). So we need to be very carefull with merge these two files and give preference to the data from `*_diff.obf` .
#### to split whole world *_diff for countries:
```
$OSMAND_MAP_CREATOR_PATH/utilities.sh split-obf ${BASENAME}_diff.obf $RESULT_DIR  "$DATE_NAME" "_$TIME_NAME" --srtm="$SRTM_DIR"
```

## Real issues
#### [Part of the road is missing after edits](https://github.com/osmandapp/OsmAnd/issues/23030#issuecomment-3205108026)
OSM editor deleted [relation](https://www.openstreetmap.org/relation/8060127) and changed tags in the [way](https://www.openstreetmap.org/way/536051747), the way was a member of the relation.<br>
Was manually generated diff files (generate-obf-diff): 
- `diff.obf` <= `25_08_08_10_10_after.obf` ∩ `25_08_08_10_10_before.obf` 
- `diff_rel.obf` <= `25_08_08_10_10_after_rel_m.obf` ∩ `25_08_08_10_10_before_rel.obf` <br>

And using BinaryInspector (inspector.sh) checked diff.obf:
```
./inspector.sh -vmap -vmapobjects ../tmp/live0808/obf/diff.obf | grep 536051747
```
checked diff_rel.obf:
```
./inspector.sh -vmap -vmapobjects ../tmp/live0808/obf/diff_rel.obf | grep 536051747
> Way types [osmand_change-delete (2415)] id 68614623735 osmid 536051747
```
Hmm, why:
1. [way 536051747](https://www.openstreetmap.org/way/536051747/history/14) is not present in `diff.obf` ? - We know that editor changed tags, but no any changes wasn't stored in `diff.obf`.<br>
After analyze changed tags we found that any change had no influence on map section (`-vmap`), so nothing stored to changes (`diff.obf`).
2. [way 536051747](https://www.openstreetmap.org/way/536051747) is marked as deleted (`osmand_change-delete`) in diff_rel.obf ? - We know that was deleted only [relation](https://www.openstreetmap.org/relation/8060127), but no [way](https://www.openstreetmap.org/way/536051747) itself!<br>

So, for fix it we need avoid marked was by `osmand_change-delete` or correctly process it. Check theses two places in the code:
1. Utility `generate-relation-osm` (RelationDiffGenerator.java) - because as we know this tool are copies objects from `*_before_rel.osm` to `*_after_rel.osm` - this is avoiding marking them by `osmand_change-delete`.<br>
Most logic solution is remove [&& !modifiedObjIds.contains(e.getKey())](https://github.com/osmandapp/OsmAnd-tools/blob/f40ef481a16fac296f8d25290707fe6c10427f38/java-tools/OsmAndMapCreatorUtilities/src/main/java/net/osmand/obf/diff/RelationDiffGenerator.java#L105). But is not, it's fix was added in the issue [Geometry duplication in live update](https://github.com/osmandapp/OsmAnd/issues/21561) for avoid add `*_before` objects with old geometry to `diff`.
2. Merging `*_diff.obf` and `*_diff_rel.obf` (`merge-obf-diff` ObfDiffMerger.java). <br>
Found [`commonMapData.put`](https://github.com/osmandapp/OsmAnd-tools/blob/70602a833ae93b64c1bc5d72d870abdd5deac96c/java-tools/OsmAndMapCreatorUtilities/src/main/java/net/osmand/obf/diff/ObfDiffMerger.java#L129) where are adding our `osmand_change-delete` way.<br>
Can we trust `osmand_change-delete` nodes/ways from `*_diff_rel.obf` ? - No, because as we know from this file we must process only modified nodes/ways, and created/deleted nodes/ways we must to process from `*_diff.obf`! See [PR with this fix](https://github.com/osmandapp/OsmAnd-tools/pull/1234).
