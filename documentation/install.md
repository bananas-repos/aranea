# Requirements

Please check the requirements file first.

# Database

You need a MySQL installation and a user which can create a database.

Use setup.sql to create the `aranea` database and its tables. `mysql --user=user -p < setup.sql`

# Config

Copy `config.default.txt` to `config.txt` and edit at least to match the database server settings.

Make sure the directory `storage` can be written.
