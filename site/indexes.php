<html>
<head><title>OsmAnd Indexes</title></head>
<?php 
   $update = $_GET['update'];
   include 'update_indexes.php';
   updateIndexes($update);
   $dom = new DomDocument(); 
   $dom->load('indexes.xml'); 
   $xpath = new DOMXpath($dom);

   function printNode($node){
      if($node->getAttribute('parts')) {
        echo "<tr><td>".$node->getAttribute('name').
          "</td><td>".$node->getAttribute('date').
          "</td><td>".$node->getAttribute('size')."</td><td>".$node->getAttribute('size').
          "</td><td>".$node->getAttribute('parts').
          "</td><td>".$node->getAttribute('description').
          "</td></tr>";
      } else {
      echo "<tr><td>".$node->getAttribute('name').
           "</td><td>".$node->getAttribute('date').
           "</td><td>".$node->getAttribute('size').
           "</td><td>".$node->getAttribute('targetsize').
           "</td><td>".$node->getAttribute('description').
           "</td></tr>";
      }
   }
?>
<body>
<h1><?php echo "Table of indexes hosted on osmand.net"; ?></h1>
<table border="1">
<?php
   $res = $xpath->query('//region');
   if($res && $res->length > 0) {
		foreach($res as $node) {
		  if (file_exists('indexes/'.$node->getAttribute('name'))) {
            printNode($node);
      }
    }
  }			
?>
</table>
<h1><?php echo "Table of road indexes hosted on osmand.net"; ?></h1>
<table border="1">
<?php
   $res = $xpath->query('//road_region');
   if($res && $res->length > 0) {
    foreach($res as $node) {
      if (file_exists('road-indexes/'.$node->getAttribute('name'))) {
            printNode($node);
      }
    }
  }     
?>
</table>
<h1><?php echo "Table of srtm countries hosted on osmand.net"; ?></h1>
<table border="1">
<?php
   $res = $xpath->query('//srtmcountry');
   if($res && $res->length > 0) {
    foreach($res as $node) {
      if (file_exists('srtm-countries/'.$node->getAttribute('name'))) {
            printNode($node);
      }
    }
  }     
?>
</table>
<h1><?php echo "Table of wiki hosted on osmand.net"; ?></h1>
<table border="1">
<?php
   $res = $xpath->query('//wiki');
   if($res && $res->length > 0) {
    foreach($res as $node) {
      if (file_exists('wiki/'.$node->getAttribute('name'))) {
            printNode($node);
      }
    }
  }     
?>
</table>
</body>
</html>
