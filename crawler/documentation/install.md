# Requirements

Please check the requirements file first.

# Database

You need a MySQL installation and an existing database.

Use `setup.sql` to create the tables into your existing database: `mysql --user=user -p databasename < setup.sql`

# Config

Copy `config.default.ini` to `config.ini` and edit at least to match the database name and server settings.

Make sure the directory `storage` and `log` can be written.
