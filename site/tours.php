<?php
include 'download_utils.php';

$code = $_GET['code']; 
$dom = new DomDocument(); 
$dom->load('indexes.xml'); 
$outputIndexes = $dom-> getElementsByTagName('indexes');
loadIndexesFromDir($dom, $outputIndexes, '/var/lib/jenkins/tours/'.$code.'/', 'region', 'tour');

print $dom->saveXML();
?>