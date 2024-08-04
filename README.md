# aranea

https://://www.bananas-playground.net/projekt/aranea

A small web crawler named aranea (Latin for spider).
The aim is to gather unique domains to show what is out there.

## Fetch

It starts with a given set of URL(s) and parses them for more
URLs. Stores them and fetches them too.
-> fetch.pl

# Parse

Each URL result (Stored result from the call) will be parsed
for other URLs to follow.
-> parse-results.pl

# Cleanup

After a run cleanup will gather all the unique Domains into
a table. Removes URLs from the fetch table which are already
enough.
-> cleanup.pl
