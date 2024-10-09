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

# set to true if you need debug messages in error log file
const DEBUG = true;
# set to ture if you need query log messages in error log file.
const QUERY_DEBUG = true;

# timezone settings
const TIMEZONE = 'Europe/Berlin';

# path settings
const PATH_ABSOLUTE = '/home/banana/code/aranea/webroot';
const PATH_LOG = PATH_ABSOLUTE.'/log';
const LOGFILE = PATH_LOG.'/aranea.log';

# db settings
const DB_HOST = 'localhost';
const DB_USERNAME = 'user';
const DB_PASSWORD = 'test';
const DB_NAME = 'aranea';
