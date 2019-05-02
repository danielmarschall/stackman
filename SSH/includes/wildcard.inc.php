<?php

function mywc($arg) {
	$wildcard = $arg;
	$wildcard = str_replace('*', '%', $wildcard);
	$wildcard = str_replace('?', '%', $wildcard);
	#$wildcard = '%'.$wildcard.'%';
	while (strpos($wildcard, '%%') !== false) {
		$wildcard = str_replace('%%', '%', $wildcard);
	}
	# echo "Wildcard: $wildcard\n";
	return $wildcard;
}
