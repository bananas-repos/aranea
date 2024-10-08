# Requirements

Please check the requirements file first.

# Database

You need a MySQL installation and an existing database.

Use `setup.sql` to create the tables into your existing database: `mysql --user=user -p databasename < setup.sql`

# Config

Copy `config.default.txt` to `config.txt` and edit at least to match the database name and server settings.

Make sure the directory `storage` can be written.
