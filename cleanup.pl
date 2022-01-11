#!/usr/bin/perl -w
use 5.20.0;
use strict;
use warnings;
use utf8;
use Term::ANSIColor qw(:constants);
use Data::Dumper;

use lib './lib';
use Aranea::Common qw(sayLog sayYellow sayGreen sayRed);

use DBI;
use ConfigReader::Simple;
use URI::URL;
use Data::Validate::URI qw(is_uri);


my $DEBUG = 0;
my $config = ConfigReader::Simple->new("config.txt");
die "Could not read config! $ConfigReader::Simple::ERROR\n" unless ref $config;

## DB connection
my %dbAttr = (
	PrintError=>0,# turn off error reporting via warn()
    RaiseError=>1 # turn on error reporting via die() 
);
my $dbDsn = "DBI:mysql:database=".$config->get("DB_NAME").";host=".$config->get("DB_HOST").";port=".$config->get("DB_PORT");
my $dbh = DBI->connect($dbDsn,$config->get("DB_USER"),$config->get("DB_PASS"), \%dbAttr);
die "failed to connect to MySQL database:DBI->errstr()" unless($dbh);



# update the uniqe domains
my $queryStr = "INSERT IGNORE INTO unique_domain (url) select DISTINCT(baseurl) as url FROM url_to_fetch WHERE fetch_failed = 0";
sayLog($queryStr) if $DEBUG;
my $query = $dbh->prepare($queryStr);
$query->execute();

# now validate the unique ones
$queryStr = "SELECT `id`, `url` FROM unique_domain";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
$query->execute();
my @invalidUrls = ();
while(my @row = $query->fetchrow_array) {
	my $link = $row[1];
	my $id = $row[0];
	if(!is_uri($link)) {
		sayYellow "Ignore URL it is invalid: $link";
		push(@invalidUrls, $id);
		next;
	}

	my $url = url($link);
	if(!defined($url->scheme) || index($url->scheme,"http") == -1) {
		sayYellow "Ignore URL because of scheme: $link";
		push(@invalidUrls, $id);
		next;
	}
}

sayYellow "Invalid URLs: ".scalar @invalidUrls;
$queryStr = "DELETE FROM unique_domain WHERE `id` = ?";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
foreach my $invalidId (@invalidUrls) {
	$query->execute($invalidId);
	$query->finish();
	sayLog "Removed $invalidId from unique_domain" if $DEBUG;
}
sayGreen "Invalid URLs removed: ".scalar @invalidUrls;


# remove urls from fetch since we have enough already
my @toBeDeletedFromFetchAgain = ();
$queryStr = "SELECT count(baseurl) AS amount, baseurl 
				FROM `url_to_fetch` 
				WHERE last_fetched <> 0 
				GROUP BY baseurl 
				HAVING amount > 40";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
$query->execute();
while(my @row = $query->fetchrow_array) {
	my $baseUrl = $row[1];
	push(@toBeDeletedFromFetchAgain, $baseUrl);
}
$query->finish();
sayYellow "Remove baseurls from url_to_fetch: ".scalar @toBeDeletedFromFetchAgain;
$queryStr = "DELETE FROM url_to_fetch WHERE `baseurl` = ?";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
foreach my $baseUrl (@toBeDeletedFromFetchAgain) {
	$query->execute($baseUrl);
	$query->finish();
	sayLog "Removed $baseUrl from url_to_fetch" if $DEBUG;
}
sayGreen "Remove baseurls from url_to_fetch: ".scalar @toBeDeletedFromFetchAgain;

# remove failed fetches
sayYellow "Remove fetch_failed";
$queryStr = "DELETE FROM url_to_fetch WHERE fetch_failed = 1";
$query = $dbh->prepare($queryStr);
$query->execute();
sayGreen "Remove fetch_failed done";

sayYellow "Remove invalid urls which the is_uri check does let pass";
$queryStr = "DELETE FROM unique_domain WHERE `url` NOT LIKE '%.%'";
$query = $dbh->prepare($queryStr);
$query->execute();
$queryStr = "SELECT * FROM `url_to_fetch` WHERE `baseurl` LIKE '% %'";
$query = $dbh->prepare($queryStr);
$query->execute();
sayYellow "Remove invalid urls done";


sayGreen "Cleanup complete";