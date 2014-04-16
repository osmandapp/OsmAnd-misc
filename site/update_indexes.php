<?php
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

function updateIndexes($update=false) {
    $local_file = basename($_SERVER['PHP_SELF']) == basename(__FILE__);
	if( $local_file) 	{
    	$update = true;
	}

	$localFileName='indexes.xml';
	// check each 30 minutes
	if(!$update && file_exists($localFileName) && time() - filemtime($localFileName) < 60 * 30) {
		return;
	}
	if($local_file) {
		echo '<h1>File update : </h1> <br>';
    }

	$dom = new DomDocument();


	$output = new DOMDocument();
	$output->formatOutput = true;

	$outputIndexes = $output->createElement( "osmand_regions" );
	$outputIndexes->setAttribute('mapversion','1');
	$output->appendChild( $outputIndexes );


	/// 2. append local indexes
		// Open a known directory, and proceed to read its contents
	
    loadIndexesFromDir($output, $outputIndexes, 'indexes/', 'region', 'map');
    loadIndexesFromDir($output, $outputIndexes, 'road-indexes/', 'road_region', 'road_map');
    loadIndexesFromDir($output, $outputIndexes, 'srtm-countries/', 'srtmcountry', 'srtm_map');
    loadIndexesFromDir($output, $outputIndexes, 'hillshade/', 'hillshade', 'hillshade');
	$output->save($localFileName);
}

updateIndexes(false);
?>