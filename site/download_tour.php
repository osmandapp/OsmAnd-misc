<?php
include 'autoload.php';
include 'download_utils.php';
use UnitedPrototype\GoogleAnalytics;


if(!isset($_GET['file']) ) {
  header('HTTP/1.0 404 Not Found');
  die(1);
}
 $file = $_GET['file'];
 $code = $_GET['code']
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
    $page = new GoogleAnalytics\Page('/download_tour.php?'.$code.'&'.$file);
    $page->setTitle('Download file '.$file);

    // Track page view
    $tracker->trackPageview($page, $session, $visitor);
    
    $event = new GoogleAnalytics\Event($app, 'App', $file, $eventno);
    $tracker->trackEvent($event, $session, $visitor);
 }
 set_time_limit(0);
 if (file_exists('tours/'.$file)) {
    downloadFile('tours/'.$file);
 } else if (isset($code) and file_exists('/var/lib/jenkins/tours/'.$code.'/'.$file)) {
    downloadFile('/var/lib/jenkins/tours/'.$code.'/'.$file);
 } else {
    header('HTTP/1.1 404 Not Found');
 }

?>
