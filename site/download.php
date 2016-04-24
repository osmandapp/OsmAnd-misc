<?php
include 'autoload.php';
include 'download_utils.php';
use UnitedPrototype\GoogleAnalytics;


 if(!isset($_GET['file']) ) {
   header('HTTP/1.0 404 Not Found');
   die(1);
 }
 $file = $_GET['file'];
  // not used now
 if(!isset($_SERVER['HTTP_RANGE']) ) {
    // old version
    // update_count_of_downloads($file) ;

   if (!isset($_GET['event'])) {
     $eventno = 1;
   } else {
     $eventno = $_GET['event'];
   }
   if (isset($_GET['osmandver'])) {
     $app = $_GET['osmandver'];
   } else {
     $app = 'Download '.$_SERVER['HTTP_USER_AGENT'];
   }
      
    $tracker = new GoogleAnalytics\Tracker('UA-28342846-1', 'download.osmand.net');
    $visitor = new GoogleAnalytics\Visitor();
    $visitor->setIpAddress($_SERVER['REMOTE_ADDR']);
    $visitor->setUserAgent($_SERVER['HTTP_USER_AGENT']);
    $visitor->setScreenResolution('1024x768');
    // Assemble Session information
    // (could also get unserialized from PHP session)
    $session = new GoogleAnalytics\Session();

    // Assemble Page information
    $page = new GoogleAnalytics\Page('/download.php?'.$file);
    $page->setTitle('Download file '.$file);

    // Track page view
    $tracker->trackPageview($page, $session, $visitor);
    
    $event = new GoogleAnalytics\Event($app, 'App', $file, $eventno);
    $tracker->trackEvent($event, $session, $visitor);
 }
 set_time_limit(0);
 $xml = simplexml_load_file("indexes.xml");
 $res = $xml->xpath('//region[@name="'.$file.'"]');
 if($file ==  "World_basemap_2.obf.zip") {
    dwFile('indexes/'.$file, 'standard=yes&file='.$file, "");
 } else if(isset($_GET['srtm'])){
    dwFile('srtm/'.$file, 'srtm=yes&file='.$file, "srtm");
 } else if(isset($_GET['srtmcountry'])){
    dwFile('srtm-countries/'.$file, 'srtmcountry=yes&file='.$file, "srtm");
 } else if(isset($_GET['road'])){
    dwFile('road-indexes/'.$file, 'road=yes&file='.$file, "road");
} else if(isset($_GET['osmc'])){
    dwFile('osmc/'.$file, 'osmc=yes&file='.$file, "osmc");
} else if(isset($_GET['aosmc'])){
    $folder = strtolower(substr($file, 0, - strlen('_16_04_01.obf.gz')));
    dwFile('aosmc/'.$file, 'aosmc=yes&file='.$file, "aosmc");
 } else if(isset($_GET['wiki'])){
    dwFile('wiki/'.$file, 'wiki=yes&file='.$file, "wiki");
 } else if(isset($_GET['hillshade'])){
    dwFile('hillshade/'.$file, 'hillshade=yes&file='.$file, "hillshade");
 } else if(isset($_GET['tour'])){
    dwFile('tours/'.$file, 'tour=yes&file='.$file, "tour");
 } else if (count($res) > 0) {
 	 $node = $res[0];
   dwFile('indexes/'.$file, 'standard=yes&file='.$file, ""); 	 
 } else {
    header('HTTP/1.1 404 Not Found');
 }

?>
