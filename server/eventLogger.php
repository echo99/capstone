<?php
session_start();

/**
 * Write the passed events to the given log file handle
 */
function write_events($handle, $events) {
  foreach ($events as $event) {
    $line = $event['time'] . ' ' . $event['event'] . ' ' 
          . json_encode($event['param']) . "\n";
    fwrite($handle, $line);
  }
}

$session_id = session_id();
$events = $_POST['events'];
$seed = $_POST['seed'];
$id = $_POST['id'];

// Only write to log if session ID exists (although it should never be empty)
if ($id != '') {
  $filename = 'event_logs/'.$id.'.txt';
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
      echo "File ($filename) is not writable";
      exit;
    }
    
    if ($handle) {
      write_events($handle, $events);
      echo "Success, wrote events to ($filename)<br>";
      fclose($handle);
    }
  } else {
    // File does not exist, so create a new one
    echo "The file $filename is does not exist<br>";
    if (!$handle = fopen($filename, 'w')) {
      echo "Cannot open file ($filename)";
      exit;
    } 
    fwrite($handle, 'seed: ' . $seed . "\nEvents:\n");
    fclose($handle);
  }
}

?>