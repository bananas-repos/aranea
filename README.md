# aranea

https://www.bananas-playground.net/projekt/aranea

A small web crawler named aranea (Latin for spider).
The aim is to gather unique domains to show what is out there.

## Fetch

It starts with a given set of URL(s) and parses them for more
URLs. Stores them and fetches them too. Execute: `perl fetch.pl`

## Parse

Each URL result (Stored result from the call) will be parsed
for other URLs to follow. `perl parse-results.pl`

## Cleanup

After a run cleanup will gather all the unique Domains into
a table. Removes URLs from the fetch table which are already
enough. `perl cleanup.pl`

# Usage

Either run `fetch.pl`, `parse-results.pl` and `cleanup.pl` in the given order manually
or use `aranea-runner` with a cron. The cron schedule depends on the amount of URLs to be fetched and parsed.
Higher numbers needs longer run times. So plan the schedule around that by running the perl files
manually first.

## Categorization

Based on https://github.com/StevenBlack/hosts/tree/master found urls are categorized. Categories are set in the
config file sections `categorization` and `categorization_urls`. The latter defines which urls belongs to a category.

The `fetchcagegorizaion.pl` does the download, parsing and writing into the db from the urls provided in the
`categorization_urls` config section.

The `categorizeurls.pl` is a helper script to parse every found domain and tries to match
them into a category. This can take a while.

Initial categorization is done while parsing, if categorization information is provided.

# Ignores

The table `url_to_ignore` does have a small amount of domains
and part of domains which will be ignored. Adding a global SPAM list would be overkill.

A good idea is to run it with a DNS filter, which has a good blocklist.

# Webinterface

The folder `webroot` does contain a webinterface which displays the gathered data and status.
It does not provide a way to execute the crawler.

# Contribute

Want to contribute or found a problem?

See Contributing document: CONTRIBUTING.md

# Uses

See uses document: USES
