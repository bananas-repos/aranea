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

# Ignores

The table `url_to_ignore` does have a small amount of domains
and part of domains which will be ignored. Adding a global SPAM list would be overkill.

A good idea is to run it with a DNS filter, which has a good blocklist.

# Webinterface

The folder `webroot` does contain a webinterface which displays the gathered data and status.
It does not provide a way to execute the crawler.
