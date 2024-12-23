<?php
/**
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see http://www.gnu.org/licenses/gpl-3.0.
*
* 2022 - 2024 https://www.bananas-playground.net/projekt/aranea
*/

mb_http_output('UTF-8');
mb_internal_encoding('UTF-8');
error_reporting(-1); // E_ALL & E_STRICT

require_once 'config.php';

## set the error reporting
ini_set('log_errors',true);
if(DEBUG === true) {
    ini_set('display_errors',true);
}
else {
    ini_set('display_errors',false);
}

# time settings
date_default_timezone_set(TIMEZONE);

# static helper class
require_once 'lib/helper.class.php';

# template vars
$TemplateData = array();
$TemplateData['pagination'] = array();
$TemplateData['pageTitle'] = 'Find where does a file come from';

# the view
$View = 'view/home/home.php';
# the script
$ViewScript = 'view/home/home.inc.php';
# the messages
$ViewMessage = 'view/system/message.php';
# the menu
$ViewMenu = 'system/menu.php';
# valid includes
$_validPages["domains"] = "domains";
$_validPages["domain"] = "domain";
$_validPages["urls"] = "urls";
$_validPages["url"] = "url";

$_requestMode = "home";
if(isset($_GET['p']) && !empty($_GET['p'])) {
    $_requestMode = trim($_GET['p']);
    $_requestMode = Helper::validate($_requestMode,'nospace') ? $_requestMode : "home";

    if(!isset($_validPages[$_requestMode])) $_requestMode = "home";

    $ViewScript = 'view/'.$_requestMode.'/'.$_requestMode.'.inc.php';
    $View = 'view/'.$_requestMode.'/'.$_requestMode.'.php';
}

## DB connection
$DB = new mysqli(DB_HOST, DB_USERNAME,DB_PASSWORD, DB_NAME);
if ($DB->connect_errno) exit('Can not connect to MySQL Server');
$DB->set_charset("utf8mb4");
$DB->query("SET collation_connection = 'utf8mb4_unicode_520_ci'");
$driver = new mysqli_driver();
$driver->report_mode = MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT;

# now include the script
# this sets information into $Data and can overwrite $View
if(!empty($ViewScript) && file_exists($ViewScript)) {
    require_once $ViewScript;
}

header("Content-type: text/html; charset=UTF-8");

## now include the main view
require_once 'view/main.php';
