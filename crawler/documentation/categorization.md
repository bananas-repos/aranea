# Categorization of all urls

The `categorizeurls.pl` script does a categorization of all existing found unique domains. This can take a while.
Categorization is done while parsing but only with new entries.

# Fetch categorization

`fetchcategorization.pl` does fetch the listed urls defined in `categorization_urls` config setting and stores
its entries in the database.

`IGNORE_TO_BE_FETCH_AGAIN` config settings tells if either all urls which are categorized or only specific 
categories will be ignored from fetching again.
