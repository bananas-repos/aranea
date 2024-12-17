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
<h1>Domains</h1>

<form method="get" class="uk-form-stacked" action="#panchor" id="panchor">
	<div class="uk-margin">
		<label class="uk-form-label" for="url">URL</label>
		<div class="uk-form-controls">
			<input class="uk-input" type="text" placeholder="Searchterm. Use * as a wildcard" id="url" name="st" value="<?php echo $TemplateData['searchInput']; ?>">
		</div>
	</div>
	<div class="uk-margin">
		<input type="hidden" name="p" value="domains" />
		<input class="uk-button uk-button-primary" type="submit" value="Search">
	</div>
</form>

<?php include_once 'view/system/pagination.inc.php'; ?>

<table class="uk-table uk-table-striped">
	<thead>
	<tr>
		<th role="columnheader">Url</th>
		<th role="columnheader">Visit</th>
		<th role="columnheader">Details</th>
		<th role="columnheader">Created</th>
	</tr>
	</thead>
	<tbody>
    <?php
    if(isset($TemplateData['searchresults']['results']) && !empty($TemplateData['searchresults']['results'])) {
        foreach($TemplateData['searchresults']['results'] as $key=>$entry) {
            ?>
			<tr>
				<td><?php echo $entry['url']; ?></td>
				<td><a href="<?php echo $entry['url']; ?>" target=_blank><span uk-icon="link-external"></span></a></td>
				<td><a href="index.php?p=domain&id=<?php echo $entry['id']; ?>"><span uk-icon="more"></span></a></td>
				<td><?php echo $entry['created'] ?? ''; ?></td>
			</tr>
            <?php
        }
    }
    ?>
	</tbody>
</table>
