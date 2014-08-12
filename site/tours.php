<?php
include 'download_utils.php';

$code = $_GET['code']; 
$dom = new DomDocument(); 
$dom->load('indexes.xml'); 
$outputIndexes->setAttribute('mapversion','1');
$output->appendChild( $outputIndexes );
loadIndexesFromDir($output, $outputIndexes, 'indexes/', 'region', 'tour');

if(isset($_GET['gzip'])){
   	header("Content-type: gzip");
   	header('Content-Disposition: attachment; filename="indexes.xml.gz"');
   	echo gzencode(file_get_contents('indexes.xml'));
} else {
 	header('Content-type: application/xml');
 	header('Content-Disposition: attachment; filename="indexes.xml"');
 	readfile('indexes.xml');
 }
	$output->save($localFileName);
updateIndexes(false);
?>