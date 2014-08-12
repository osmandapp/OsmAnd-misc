<?php
include 'download_utils.php';

$code = $_GET['code']; 
$dom = new DomDocument(); 
$dom->load('indexes.xml'); 
$outputIndexes = $dom-> getElementsByTagName('indexes')->item(0);
loadIndexesFromDir($dom, $outputIndexes, '/var/lib/jenkins/tours/'.$code.'/', 'region', 'tour');

header('Content-type: application/xml');
header('Content-Disposition: attachment; filename="tours.xml"');
print $dom->saveXML();
?>