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
 * Everything about the unique_domain table and its data
 */

require_once 'lib/base.class.php';

class Domains extends Base {

    /**
     * The available sort columns.
     * Used in query and sort options in FE
     *
     * @var array|array[]
     */
    public array $_sortOptions = array(
        'default' => array('col' => 'd.url', 'displayText' => 'URL (default)'),
        'created' => array('col' => 'd.created', 'displayText' => 'Created')
    );

    /**
     * Domains constructor.
     *
     * @param mysqli $databaseConnectionObject
     */
    public function __construct(mysqli $databaseConnectionObject) {
        $this->_DB = $databaseConnectionObject;
        $this->_setDefaults();
    }

    /**
     * latest 10 created entries in unique_domain
     *
     * @return array
     */
    public function latest(): array {
        $ret = array();

        $queryStr = "SELECT id,url
                    FROM `unique_domain`
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

    public function getDomains(): array {
        $ret = array();

        $querySelect = "SELECT d.id, d.url, d.created";
        $queryFrom = " FROM `unique_domain` AS d";

        $queryWhere = '';
        if(!empty($this->_searchValue)) {
            $queryWhere = " WHERE d.url";

            if($this->_wildcardsearch) {
                $queryWhere .= " LIKE '".$this->_DB->real_escape_string($this->_searchValue)."'";
            } else {
                $queryWhere .= " = '".$this->_DB->real_escape_string($this->_searchValue)."'";
            }
        }

        $queryOrder = " ORDER BY";
        if (!empty($this->_queryOptions['sort'])) {
            $queryOrder .= " ".$this->_queryOptions['sort'];
        }
        else {
            $queryOrder .= " ".$this->_sortOptions['default']['col'];
        }

        if (!empty($this->_queryOptions['sortDirection'])) {
            $queryOrder .= " ".$this->_queryOptions['sortDirection'];
        }
        else {
            $queryOrder .= " ASC";
        }

        $queryLimit = '';
        if(!empty($this->_queryOptions['limit'])) {
            $queryLimit .= " LIMIT ".$this->_queryOptions['limit'];
            # offset can be 0
            if($this->_queryOptions['offset'] !== false) {
                $queryLimit .= " OFFSET ".$this->_queryOptions['offset'];
            }
        }

        $queryStr = $querySelect.$queryFrom.$queryWhere.$queryOrder.$queryLimit;
        if(QUERY_DEBUG) Helper::sysLog("[QUERY] ".__METHOD__." query: ".Helper::cleanForLog($queryStr));

        try {
            $query = $this->_DB->query($queryStr);

            if($query !== false && $query->num_rows > 0) {
                while(($result = $query->fetch_assoc()) != false) {
                    $ret['results'][$result['id']] = $result;
                }

                $queryStrCount = "SELECT COUNT(*) AS amount ".$queryFrom.$queryWhere;

                if(QUERY_DEBUG) Helper::sysLog("[QUERY] ".__METHOD__." query: ".Helper::cleanForLog($queryStrCount));
                $query = $this->_DB->query($queryStrCount);
                $result = $query->fetch_assoc();
                $ret['amount'] = $result['amount'];
            }
        }
        catch (Exception $e) {
            Helper::sysLog("[ERROR] ".__METHOD__." mysql catch: ".$e->getMessage());
        }

        return $ret;
    }
}
