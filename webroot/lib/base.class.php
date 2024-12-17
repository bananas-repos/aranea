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

abstract class Base {
    /**
     * the database object
     *
     * @var mysqli
     */
    protected mysqli $_DB;

    /**
     * Options for db queries
     *  'limit' => int,
     *  'offset' => int,
     *  'orderby' => string,
     *  'sortDirection' => ASC|DESC
     *
     * @var array
     */
    protected array $_queryOptions;

    /**
     * The available sort columns.
     * Used in query and sort options in FE
     *
     * @var array|array[]
     */
    protected array $_sortOptions = array();

    /**
     * @var string $_searchValue
     */
    protected string $_searchValue = '';

    /**
     * @var bool $_wildcardsearch
     */
    protected bool $_wildcardsearch = false;

    /**
     * Set the following options which can be used in DB queries
     * array(
     *  'limit' => RESULTS_PER_PAGE,
     *  'offset' => (RESULTS_PER_PAGE * ($_curPage-1)),
     *  'orderby' => $_sort,
     *  'sortDirection' => $_sortDirection
     * );
     *
     * @param array $options
     */
    public function setQueryOptions(array $options): void {

        if(!isset($options['limit'])) $options['limit'] = 20;
        if(!isset($options['offset'])) $options['offset'] = false;

        if(isset($options['sort']) && isset($this->_sortOptions[$options['sort']])) {
            $options['sort'] = $this->_sortOptions[$options['sort']]['col'];
        } else {
            $options['sort'] = '';
        }

        if(isset($options['sortDirection'])) {
            $options['sortDirection'] = match ($options['sortDirection']) {
                'desc' => "DESC",
                default => "ASC",
            };
        } else {
            $options['sortDirection'] = '';
        }

        $this->_queryOptions = $options;
    }

    /**
     * Return the available sort options and the active used one
     *
     * @return array|array[]
     */
    public function getSortOptions(): array {
        return $this->_sortOptions;
    }

    /**
     * Prepare and set the searchvalue.
     * Check for wildcardsearch and make it safe
     *
     * @param string $searchValue
     * @return bool
     */
    public function prepareSearchValue(string $searchValue): bool {
        if(str_contains($searchValue,'*')) {
            $this->_wildcardsearch = true;
            $searchValue = preg_replace('/\*{1,}/', '%', $searchValue);

            if(strlen($searchValue) < 3) {
                return false;
            }

            if(strlen($searchValue) === 3) {
                if(substr_count($searchValue, '%') > 1) return false;
            }
        }

        if(strlen($searchValue) < 2) {
            return false;
        }

        $this->_searchValue = $searchValue;

        return true;
    }

    /**
     * set some defaults by init of the class
     *
     * @return void
     */
    protected function _setDefaults(): void {
        // default query options
        $options['limit'] = 50;
        $options['offset'] = false;
        $options['sort'] = 'default';
        $options['sortDirection'] = '';
        $this->setQueryOptions($options);
    }
}
