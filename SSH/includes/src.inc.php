<?php

$src = exec(escapeshellcmd(__DIR__.'/../sysname'), $cont, $code);
if ($code > 0) $src = 'unknown@unknown';
$src = "lta:$src";

