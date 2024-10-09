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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'">

    <link rel="stylesheet" href="asset/uikit/uikit.min.css">
    <link rel="stylesheet" href="asset/style.css">
    <script src="asset/uikit/uikit.min.js"></script>
    <script src="asset/uikit/uikit-icons.min.js"></script>

    <meta name="author" content="https://www.bananas-playground.net/projekt/aranea" />
    <title><?php echo $TemplateData['pageTitle']; ?> / aranea</title>
</head>
<body class="uk-container">
    <header>
        <?php require_once $ViewMenu; ?>
    </header>

    <main>
        <section>
            <?php require_once $ViewMessage; ?>
        </section>
        <section>
            <?php require_once $View; ?>
        </section>
    </main>
    <hr>
    <footer>
        <div class="uk-text-small">
            Copyright &copy; 2022 - <?php echo date("Y"); ?> <a href="https://www.bananas-playground.net/projekt/aranea">aranea</a>
        </div>
    </footer>
</body>
</html>
