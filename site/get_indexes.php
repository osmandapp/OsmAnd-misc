<?php 
   include 'update_indexes.php';
   updateIndexes();
   header('Content-type: application/xml');
   header('Content-Disposition: attachment; filename="indexes.xml"');

   readfile('indexes.xml');
?>
