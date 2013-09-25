<?php 
   include 'update_indexes.php';
   updateIndexes();
   if(isset($_GET['gzip'])){
    	header("Content-type: gzip");
    	header('Content-Disposition: attachment; filename="indexes.xml.gz"');
    	echo gzencode(file_get_contents('indexes.xml'));
	} else {
   		header('Content-type: application/xml');
   		header('Content-Disposition: attachment; filename="indexes.xml"');
   		readfile('indexes.xml');
   }
?>
