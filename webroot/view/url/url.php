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
 * 2022 - 2025 https://www.bananas-playground.net/projekt/aranea
 */
?>
<h1>URL details</h1>

<table class="uk-table uk-table-striped">
    <tr>
        <td>URL</td>
        <td>
            <?php echo $TemplateData['url']['url'] ?? ''; ?>
            <a href="<?php echo $TemplateData['url']['url'] ?? ''; ?>" target=_blank><span uk-icon="link-external"></span></a>
        </td>
    </tr>
    <tr>
        <td>Baseurl</td>
        <td>
            <?php echo $TemplateData['url']['baseurl'] ?? ''; ?>
            <a href="<?php echo $TemplateData['url']['baseurl'] ?? ''; ?>" target=_blank><span uk-icon="link-external"></span></a>
        </td>
    </tr>
    <tr>
        <td>Last fetched</td>
        <td>
            <?php echo $TemplateData['url']['last_fetched'] ?? ''; ?>
        </td>
    </tr>
    <tr>
        <td>Fetch failed</td>
        <td>
            <?php echo $TemplateData['url']['fetch_failed'] ?? ''; ?>
        </td>
    </tr>
    <tr>
        <td>Created</td>
        <td>
            <?php echo $TemplateData['url']['created'] ?? ''; ?>
        </td>
    </tr>
</table>
