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
<h1>Home</h1>

<div class="uk-grid uk-child-width-1-1 uk-child-width-1-2@m uk-child-width-1-3@l">
	<div class="uk-overflow-auto">
        <h3>Latest Domains</h3>
        <table class="uk-table uk-table-striped">
            <thead>
            <tr>
                <th role="columnheader">Domain</th>
            </tr>
            </thead>
            <tbody>
            <?php
            if(!empty($TemplateData['latestDomains'])) {
                foreach($TemplateData['latestDomains'] as $k=>$value) {
                    ?>
                    <tr>
                        <td><?php echo $value['url']; ?></a></td>
                    </tr>
                    <?php
                }
            }
            ?>
            </tbody>
        </table>
    </div>
    <div class="uk-overflow-auto">
        <h3>Latest URLs</h3>
        <table class="uk-table uk-table-striped">
            <thead>
            <tr>
                <th role="columnheader">URL</th>
            </tr>
            </thead>
            <tbody>
            <?php
            if(!empty($TemplateData['latestUrls'])) {
                foreach($TemplateData['latestUrls'] as $k=>$value) {
                    ?>
                    <tr>
                        <td><?php echo $value['url']; ?></a></td>
                    </tr>
                    <?php
                }
            }
            ?>
            </tbody>
        </table>
    </div>
	<div class="uk-overflow-auto">
		<h3>Info</h3>
		<table class="uk-table uk-table-striped">
			<thead>
			<tr>
				<th role="columnheader">Action</th>
				<th role="columnheader">#</th>
			</tr>
			</thead>
			<tbody>
            <?php
            if(!empty($TemplateData['stats'])) {
                foreach($TemplateData['stats'] as $k=>$value) {
                    ?>
					<tr>
						<td><?php echo $value['action']; ?></a></td>
						<td><?php echo $value['value']; ?></a></td>
					</tr>
                    <?php
                }
            }
            ?>
			</tbody>
		</table>
	</div>
</div>
