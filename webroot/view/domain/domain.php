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
<h1>Domain details</h1>

<table class="uk-table uk-table-striped">
    <tr>
        <td>URL</td>
        <td>
            <?php echo $TemplateData['domain']['url'] ?? ''; ?>
	        <a href="<?php echo $TemplateData['domain']['url']; ?>" target=_blank><span uk-icon="link-external"></span></a>
        </td>
    </tr>
    <tr>
        <td>Created</td>
        <td>
            <?php echo $TemplateData['domain']['created'] ?? ''; ?>
        </td>
    </tr>
</table>

<h2>Relations</h2>
<p>
	Where was this domain found and where does this domain lead to.
</p>

<ul class="uk-tab">
	<li class="<?php if($TemplateData['tab'] == "from") echo 'uk-active'; ?>"><a href="index.php?p=domain&id=<?php echo $TemplateData['domain']['id'] ?? ''; ?>&tab=from">From</a></li>
	<li class="<?php if($TemplateData['tab'] == "to") echo 'uk-active'; ?>"><a href="index.php?p=domain&id=<?php echo $TemplateData['domain']['id'] ?? ''; ?>&tab=to">To</a></li>
</ul>

<p>
	Search based on the chosen relation.
</p>
<form method="get" class="uk-form-stacked" action="#panchor" id="panchor">
	<div class="uk-margin">
		<label class="uk-form-label" for="url">URL</label>
		<div class="uk-form-controls">
			<input class="uk-input" type="text" placeholder="Searchterm. Use * as a wildcard" id="url" name="st" value="<?php echo $TemplateData['searchInput']; ?>">
		</div>
	</div>
	<div class="uk-margin">
		<input type="hidden" name="p" value="domain" />
		<input type="hidden" name="id" value="<?php echo $TemplateData['domain']['id'] ?? ''; ?>">
		<input type="hidden" name="tab" value="<?php echo $TemplateData['tab'] ?? ''; ?>">
		<input class="uk-button uk-button-primary" type="submit" value="Search">
		<a class="uk-button uk-button-default" href="index.php?p=domain&id=<?php echo $TemplateData['domain']['id'] ?? ''; ?>&tab=<?php echo $TemplateData['tab'] ?? ''; ?>#panchor">Reset</a>
	</div>
</form>

<?php include_once 'view/system/pagination.inc.php'; ?>

<table class="uk-table uk-table-striped">
	<thead>
	<tr>
		<th role="columnheader">Origin</th>
		<th role="columnheader">Target</th>
		<th role="columnheader">Created</th>
		<th role="columnheader">Amount</th>
	</tr>
	</thead>
	<tbody>
    <?php
    if(isset($TemplateData['searchresults']['results']) && !empty($TemplateData['searchresults']['results'])) {
        foreach($TemplateData['searchresults']['results'] as $key=>$entry) {
            ?>
			<tr>
				<td>
					<?php echo $entry['origin']; ?>
					<a href="index.php?p=domains&st=<?php echo urlencode($entry['origin']); ?>"><span uk-icon="more"></span></a>
					<a href="<?php echo $entry['origin']; ?>" target=_blank><span uk-icon="link-external"></span></a>
				</td>
				<td>
					<?php echo $entry['target']; ?>
					<a href="index.php?p=domains&st=<?php echo urlencode($entry['target']); ?>"><span uk-icon="more"></span></a>
					<a href="<?php echo $entry['target']; ?>" target=_blank><span uk-icon="link-external"></span></a>
				</td>
				<td><?php echo $entry['created'] ?? ''; ?></td>
				<td><?php echo $entry['amount'] ?? ''; ?></td>
			</tr>
            <?php
        }
    }
    ?>
	</tbody>
</table>
