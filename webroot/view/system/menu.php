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
?>
<nav class="uk-navbar-container">
    <div class="uk-container">
        <div class="uk-navbar">
            <div class="uk-navbar-left">
                <ul class="uk-navbar-nav">
                    <li>
                        <a class="uk-navbar-item uk-logo" href="index.php" aria-label="Back to Home">&#128375;</a>
                    </li>
                    <li class="<?php if($_requestMode == "domains") echo 'uk-active'; ?>">
                        <a href="index.php?p=domains">Domains</a>
                    </li>
                    <li class="<?php if($_requestMode == "urls") echo 'uk-active'; ?>">
                        <a href="index.php?p=urls">URLs</a>
                    </li>
	                <li class="<?php if($_requestMode == "ignore") echo 'uk-active'; ?>">
		                <a href="index.php?p=ignore">Ignore</a>
	                </li>
                    <li class="<?php if($_requestMode == "stats") echo 'uk-active'; ?>">
                        <a href="index.php?p=stats">Stats</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</nav>
