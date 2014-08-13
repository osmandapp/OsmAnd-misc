<?php
include 'download_utils.php';

$code = $_GET['code']; 
$dom = new DomDocument(); 
$dom->load('indexes.xml'); 
$outputIndexes = $dom-> getElementsByTagName('osmand_regions')->item(0);
loadIndexesFromDir($dom, $outputIndexes, '/var/lib/jenkins/tours/'.$code.'/', 'region', 'tour');

header("Content-type: gzip");
header('Content-Disposition: attachment; filename="tours.xml.gz"');
print gzencode($dom->saveXML());
?>