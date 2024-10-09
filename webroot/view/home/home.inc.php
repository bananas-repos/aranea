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

$TemplateData['pageTitle'] = 'Home';

require_once 'lib/domains.class.php';
$Domains = new Domains($DB);

require_once 'lib/urls.class.php';
$Urls = new Urls($DB);

$TemplateData['latestDomains'] = $Domains->latest();
$TemplateData['latestUrls'] = $Urls->latest();
