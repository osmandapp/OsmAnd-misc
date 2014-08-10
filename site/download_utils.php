<?php
function downloadFile($filename) {
	if (!file_exists($filename)) {
		header('HTTP/1.0 404 Not Found');
		//die('File doesn\'t exist');
		die(1);
	}

	$from=0; 
	$cr=NULL;
	$to=filesize($filename) - 1;

	if (isset($_SERVER['HTTP_RANGE'])) {
	    list($a, $range) = explode("=",$_SERVER['HTTP_RANGE'],2);
	    list($range) = explode(",",$range,2);
	    list($from, $range_end) = explode("-", $range);
	    $from=intval($from);
	    if($range_end) {
	       $to=intval($range_end);
	    }
	    header('HTTP/1.1 206 Partial Content');
	    header('Content-Range: bytes ' . $from . '-' . $to.'/'.filesize($filename));
	} else {
            header('HTTP/1.1 200 Ok');
        }

	$size= $to - $from + 1;
	header('Accept-Ranges: bytes');
	header('Content-Length: ' . $size);

	header('Connection: close');
	header('Content-Type: application/octet-stream');
	header('Last-Modified: ' . gmdate('r', filemtime($filename)));
	$f=fopen($filename, 'r');
	header('Content-Disposition: attachment; filename="' . basename($filename) . '";');
	if ($from) fseek($f, $from, SEEK_SET);
	
	
	$downloaded=0;
	while(!feof($f) and !connection_status() and ($downloaded<$size)) {
	    $part = min(512000, $size-$downloaded);
	    echo fread($f, $part);
	    $downloaded+=$part;
	    flush();
	}
	fclose($f);
}

function url_exists($url) { 
    $hdrs = @get_headers($url); 
    return is_array($hdrs) ? preg_match('/^HTTP\\/\\d+\\.\\d+\\s+2\\d\\d\\s+.*$/',$hdrs[0]) : false; 
} 

function dwFile($filename,$query,$type) {
  if($_SERVER['SERVER_NAME'] == 'download.osmand.net') {
    header('HTTP/1.1 302 Found');
    $var = rand(0, 99);
    $simple = false;
    if($type == "road" or $type == "") {
      $simple = true;
    }
    $helpServers = array();
    $mainServers = array("dl2.osmand.net", "dl3.osmand.net");
    $mainServersLoad = 100;
    
    $helpServersCount = count($helpServers);
    $mainServersCount = count($mainServers);
    if($helpServersCount > 0 and $simple and $var < (100 - $mainServersLoad)) {
    	$url = $helpServers[$var % $helpServersCount];
    	header('Location: http://'.$url.'/download.php?'.$query);
    } else if($mainServersCount > 0) {
    	$url = $mainServers[$var % $mainServersCount];
    	header('Location: http://'.$url.'/download.php?'.$query);
    } else {
        downloadFile($filename);
    }
  } else {
    downloadFile($filename);
  }
}
?>