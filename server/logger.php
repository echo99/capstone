<?php
session_start();

/**
 * Write the passed events to the given log file handle
 */
function write_events($handle, $events) {
  foreach ($events as $event) {
    $line = $event['time'] . ': ' . $event['event'] . ' (' 
          . json_encode($event['param']) . ')' . "\n";
    fwrite($handle, $line);
  }
}

$session_id = session_id();
$events = $_POST['events'];

// Only write to log if session ID exists (although it should never be empty)
if ($session_id != '') {
  $filename = 'logs/'.$session_id.'.txt';
  $handle = null;

  // Let's make sure the file exists and is writable first.
  if (file_exists($filename)) {
    if (is_writable($filename)) {
      // If file exists, append to it
      if (!$handle = fopen($filename, 'a')) {
        echo "Cannot open file ($filename)";
        exit;
      }
    } else {
      echo "File $filename is not writable";
      exit;
    }
  } else {
    // File does not exist, so create a new one
    echo "The file $filename is does not exist<br>";
    if (!$handle = fopen($filename, 'w')) {
      echo "Cannot open file ($filename)";
      exit;
    } 
  }
  if ($handle) {
    write_events($handle, $events);
    echo "Success, wrote events to ($filename)<br>";
    fclose($handle);
  }
}

?>