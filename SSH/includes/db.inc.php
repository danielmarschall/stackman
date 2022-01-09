<?php

$vts_mysqli = null;

# ---

$stam_cfg = array();
$stam_cfg['db_host'] = null;
$stam_cfg['db_user'] = null;
$stam_cfg['db_pass'] = null;
$stam_cfg['db_base'] = null;

require __DIR__ . '/config.inc.php';

$db_host = $stam_cfg['db_host'];
$db_user = $stam_cfg['db_user'];
$db_pass = $stam_cfg['db_pass'];
$db_base = $stam_cfg['db_base'];

if (!db_connect($db_host, $db_user, $db_pass)) {
	fwrite(STDERR, "MySQL connect error\n");
	exit(2);
}

if (!db_select_db($db_base)) {
	fwrite(STDERR, "MySQL DB select error\n");
	db_close();
	exit(2);
}

register_shutdown_function('db_close');

# ---

// Sendet eine Anfrage an MySQL
function db_query($query, $link_identifier=NULL) {
	global $vts_mysqli;
	return (!is_null($link_identifier) ? $link_identifier : $vts_mysqli)->query($query, $resultmode=MYSQLI_STORE_RESULT);
}

// Maskiert spezielle Zeichen innerhalb eines Strings für die Verwendung in einer SQL-Anweisung
function db_real_escape_string($unescaped_string, $link_identifier=NULL) {
	global $vts_mysqli;
	return (!is_null($link_identifier) ? $link_identifier : $vts_mysqli)->escape_string($unescaped_string);
}

// Öffnet eine Verbindung zu einem MySQL-Server
function db_connect($server=null, $username=null, $password=null, $new_link=false, $client_flags=0) {
	global $vts_mysqli;
	$ary = explode(':', $server);
	$host = $ary[0];
	$ini_port = ini_get("mysqli.default_port");
	$port = isset($ary[1]) ? (int)$ary[1] : ($ini_port ? (int)$ini_port : 3306);
	if (is_null($server)) $server = ini_get("mysqli.default_host");
	if (is_null($username)) $username = ini_get("mysqli.default_user");
	if (is_null($password)) $password = ini_get("mysqli.default_password");
	$vts_mysqli = new mysqli($host, $username, $password, /*dbname*/'', $port, ini_get("mysqli.default_socket"));
	return (empty($vts_mysqli->connect_error) && ($vts_mysqli->connect_errno == 0)) ? $vts_mysqli : false;
}

// Schließt eine Verbindung zu MySQL
function db_close($link_identifier=NULL) {
	global $vts_mysqli;
	return (!is_null($link_identifier) ? $link_identifier : $vts_mysqli)->close();
}

// Auswahl einer MySQL Datenbank
function db_select_db($database_name, $link_identifier=NULL) {
        global $vts_mysqli;
        return (!is_null($link_identifier) ? $link_identifier : $vts_mysqli)->select_db($database_name);
}

define('DB_ASSOC', MYSQLI_ASSOC);
define('DB_NUM',   MYSQLI_NUM);
define('DB_BOTH',  MYSQLI_BOTH);
function db_fetch_array($result, $result_type=DB_BOTH) {
        return $result->fetch_array($result_type);
}

// Liefert die ID, die in der vorherigen Abfrage erzeugt wurde
function db_insert_id($link_identifier=NULL) {
        global $vts_mysqli;
        return (!is_null($link_identifier) ? $link_identifier : $vts_mysqli)->insert_id;
}

// Liefert die Anzahl betroffener Datensätze einer vorhergehenden MySQL Operation
function db_affected_rows($link_identifier=NULL) {
        global $vts_mysqli;
        return (!is_null($link_identifier) ? $link_identifier : $vts_mysqli)->affected_rows;
}

// Liefert die Anzahl der Zeilen im Ergebnis
function db_num_rows($result) {
        return $result->num_rows;
}

// Liefert den Fehlertext der zuvor ausgeführten MySQL Operation
function db_error($link_identifier=NULL) {
        global $vts_mysqli;
        $x = (!is_null($link_identifier) ? $link_identifier : $vts_mysqli);
        return !empty($x->connect_error) ? $x->connect_error : $x->error;
}

