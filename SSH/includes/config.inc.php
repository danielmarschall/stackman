<?php

// Defaults
stam_read_config(__DIR__ . '/../defaults/.stam_config');

// Read config in user dir
$home = $_SERVER['HOME'];
stam_read_config($home.'/.stam_config');

// ---

function stam_read_config($file) {
	if (!file_exists($file)) return false;
	global $stam_cfg;
	$x = file($file);
	foreach ($x as &$a) {
		$a = trim($a);
		if ($a == '') continue;
		$ary = explode('=', $a, 2);
		$name = trim($ary[0]);
		if ($name[0] == '#') continue; // Comment
		if (!isset($ary[1])) {
			// Invalid entry
			fwrite(STDERR, "Ignore invalid config line: $a\n");
			continue;
		}
		$val  = trim($ary[1]);
		$stam_cfg[$name] = $val;
	}
}
