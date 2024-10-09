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
 * Everything about the url_to_fetch table and its data
 */

require_once 'lib/base.class.php';

class Urls extends Base {
    /**
     * Urls constructor.
     *
     * @param mysqli $databaseConnectionObject
     */
    public function __construct(mysqli $databaseConnectionObject) {
        $this->_DB = $databaseConnectionObject;
        $this->_setDefaults();
    }

    /**
     * latest 10 found urls from url_to_fetch
     *
     * @return array
     */
    public function latest(): array {
        $ret = array();

        $queryStr = "SELECT id,url,baseurl,created,fetch_failed, last_fetched
                    FROM `url_to_fetch`
                    ORDER BY created DESC
                    LIMIT 10";
        if(QUERY_DEBUG) Helper::sysLog("[QUERY] ".__METHOD__." query: ".Helper::cleanForLog($queryStr));

        try {
            $query = $this->_DB->query($queryStr);

            if($query !== false && $query->num_rows > 0) {
                while(($result = $query->fetch_assoc()) != false) {
                    $ret[] = $result;
                }
            }
        }
        catch (Exception $e) {
            Helper::sysLog("[ERROR] ".__METHOD__." mysql catch: ".$e->getMessage());
        }

        return $ret;
    }
}
