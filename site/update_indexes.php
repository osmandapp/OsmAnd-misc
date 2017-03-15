<?php
include 'download_utils.php';

function updateIndexes($update=false) {
    $local_file = basename($_SERVER['PHP_SELF']) == basename(__FILE__);
	if( $local_file) 	{
    	$update = true;
	}

	$localFileName='indexes.xml';
	// check each 30 minutes
	if(!$update && file_exists($localFileName) && time() - filemtime($localFileName) < 60 * 30) {
		return;
	}
	if($local_file) {
		echo '<h1>File update : </h1> <br>';
    }

	$dom = new DomDocument();


	$output = new DOMDocument();
	$output->formatOutput = true;

	$outputIndexes = $output->createElement( "osmand_regions" );
	$outputIndexes->setAttribute('mapversion','1');
	$output->appendChild( $outputIndexes );


	/// 2. append local indexes
		// Open a known directory, and proceed to read its contents
	
    loadIndexesFromDir($output, $outputIndexes, 'indexes/', 'region', 'map');
    loadIndexesFromDir($output, $outputIndexes, 'indexes/fonts/', 'fonts', 'fonts');

    loadIndexesFromDir($output, $outputIndexes, 'wiki/', 'wiki', 'wikimap');
    loadIndexesFromDir($output, $outputIndexes, 'road-indexes/', 'road_region', 'road_map');
    loadIndexesFromDir($output, $outputIndexes, 'srtm-countries/', 'srtmcountry', 'srtm_map');
    loadIndexesFromDir($output, $outputIndexes, 'hillshade/', 'hillshade', 'hillshade');
    loadIndexesFromDir($output, $outputIndexes, 'tours/', 'tour', 'tour');
	$output->save($localFileName);
}

updateIndexes(false);
?>
