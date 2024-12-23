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

/**
 * Everything about a single url from the url_to_fetch table
 */

require_once 'lib/base.class.php';

class Url extends Base {

    /**
     * Currently loaded url information
     * @var array
     */
    private array $_url = array();

    /**
     * Url constructor.
     *
     * @param mysqli $databaseConnectionObject
     */
    public function __construct(mysqli $databaseConnectionObject) {
        $this->_DB = $databaseConnectionObject;
        $this->_setDefaults();
    }

    /**
     * Load the data from unique_domain table by given id.
     * Populate the _domain array
     *
     * @param string $id
     * @return array
     */
    public function details(string $id): array {
        $ret = array();

        if(!empty($id)) {
            $queryStr = "SELECT `id`, `url`, `baseurl`, `created`, `fetch_failed`, `last_fetched`
                       FROM `url_to_fetch`
                       WHERE `id` = '".$this->_DB->real_escape_string($id)."'";
            if(QUERY_DEBUG) Helper::sysLog("[QUERY] ".__METHOD__." query: ".Helper::cleanForLog($queryStr));
            try {
                $query = $this->_DB->query($queryStr);

                if($query !== false && $query->num_rows > 0) {
                    $ret = $query->fetch_assoc();
                }
            }
            catch (Exception $e) {
                Helper::sysLog("[ERROR] ".__METHOD__." mysql catch: ".$e->getMessage());
            }
        }
        $this->_url = $ret;
        return $ret;
    }
}
