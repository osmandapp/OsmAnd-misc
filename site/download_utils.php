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
    //if($type == "road" or $type == "" or $type == "wiki") {
    if($type == "") {
      $simple = true;
    }
    $helpServers = array();
    $mainServers = array("dl2.osmand.net", "dl3.osmand.net");
    $mainServersLoad = 100;
    
    $helpServersCount = count($helpServers);
    $mainServersCount = count($mainServers);
    if($type == "osmc" ) {
		downloadFile($filename);
    } else if($helpServersCount > 0 and $simple and $var < (100 - $mainServersLoad)) {
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

function endsWith($haystack, $needle)
{
    $length = strlen($needle);
    if ($length == 0) {
        return true;
    }

    return (substr($haystack, -$length) === $needle);
}

function loadIndexesFromDir($output, $outputIndexes, $dir, $elementName, $ftype){
	$local_file = basename($_SERVER['PHP_SELF']) == basename(__FILE__);
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			$zip = new ZipArchive();
			while (($file = readdir($dh)) !== false) {
				$type= $ftype;
				$filename = $dir . $file ; //"./test112.zip";
				//print("processing file:" . $filename . "\n");
				$indexName=$file;
				$size =  number_format((filesize($filename) / (1024.0*1024.0)), 1, '.', '');
				$targetSize =$size;
				$containerSize = filesize($filename);
				$contentSize = filesize($filename);
				if (strpos($file,'.voice') !== false) {
    				$type="voice";
				} else  if (strpos($file,'.gitignore') !== false) {
    				continue;
				}

				if(endsWith($file, ".sqlitedb")) {
					$date= date('d.m.Y',filemtime($filename));
					$timestamp = filemtime($filename);
					$description = str_replace("_", " ", substr($file, 0, -9));
				} else {
					if ($zip->open($filename,ZIPARCHIVE::CHECKCONS)!==TRUE) {
						// echo exit("cannot open <$filename>\n");
						// print($filename . " cannot open as zip\n");
						continue;
					}
					$description = $zip->getCommentIndex(0);
					$stat = $zip->statIndex( 0 , ZIPARCHIVE::FL_UNCHANGED);
					$targetSize = number_format($stat['size'] / (1024.0*1024.0), 1, '.', '');
					$contentSize = $stat['size'];
					$timestamp = $stat['mtime'];
					$date= date('d.m.Y',$stat['mtime']);
					$zip->close();
				}
							

                if($local_file) {
					echo 'Local : '.$indexName.' '.$date.' '.$size.'<br>';
                }
				$out = $output->createElement( $elementName);
				$outputIndexes->appendChild($out);
				
				
				$out -> setAttribute("type", $type);
				$out -> setAttribute("containerSize", $containerSize);
				$out -> setAttribute("contentSize", $contentSize);
				$out -> setAttribute("timestamp", $timestamp * 1000);
				$out -> setAttribute("date", $date);
				$out -> setAttribute("size", $size);
				$out -> setAttribute("targetsize", $targetSize);
				$out -> setAttribute("name", $indexName);
				$out -> setAttribute("description", $description);
			}
			closedir($dh);
		}
	} else {
		print($dir . " not a directory!\n");
	}
}

?>