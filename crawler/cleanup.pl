#!/usr/bin/perl -w

# 2022 - 2024 https://www.bananas-playground.net/projekt/aranea

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/gpl-3.0.

# Removes urls if there are too many entries.
# Create the uniq entries in unique_domain table.
# Compares entries from unique_domain and url_to_fetch against spam info.
# This is the last part of the crawler cycle.
# Use 'aranea-runner' to execute the parts of the crawler in the correct order.

use 5.36.0;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Term::ANSIColor qw(:constants);

use lib './lib';
use Aranea::Common qw(sayLog sayYellow sayGreen sayRed addToStats queryLog);

use Config::Tiny;
use Cwd;
use DBI;
use Data::Validate::URI qw(is_web_uri);
use Proc::Pidfile;
use URI::URL;

# 0 = Write everything to log. Without terminal colors
# 1 = Print terminal output with colors. Nothing to log file.
# 2 = Print additional debug lines. Nothing to log file.
our $DEBUG = 0; # this way it can be used in Common.pm
my $config = Config::Tiny->read("config.ini", "utf8");
die "Could not read config! $Config::Tiny::errstr\n" unless ref $config;

# create the PID file and exit silently if it is already running.
my $currentdir = getcwd;
my $pid = Proc::Pidfile->new(pidfile => $currentdir."/log/aranea.pid", silent => 1);

if($DEBUG == 0) {
	open (my $LOG, '>>', 'log/aranea.log') or die "Could not open file 'log/aranea.log' $!";
	select $LOG; $| = 1; # https://perl.plover.com/FAQs/Buffering.html
}

# DB connection
my %dbAttr = (
	PrintError=>0,# turn off error reporting via warn()
    RaiseError=>1, # turn on error reporting via die()
	mysql_enable_utf8mb4 => 1
);
my $dbDsn = "DBI:mysql:database=".$config->{db}->{DB_NAME}.";host=".$config->{db}->{DB_HOST}.";port=".$config->{db}->{DB_PORT};
my $dbh = DBI->connect($dbDsn,$config->{db}->{DB_USER},$config->{db}->{DB_PASS}, \%dbAttr);
die "Failed to connect to MySQL database:DBI->errstr()" unless($dbh);

sayGreen "Cleanup starting";

# clean up url_to_fetch
my @invalidFetchUrl = ();
my $queryStr = "SELECT `id`, `url` FROM `url_to_fetch`
				WHERE `fetch_failed` = 0 AND `last_fetched` IS NULL";
my $query = $dbh->prepare($queryStr);
$query->execute();
queryLog $query;
while(my @row = $query->fetchrow_array) {
	my $url = $row[1];
	if(!is_web_uri($url)) {
		push(@invalidFetchUrl, $row[0]);
		sayLog "Not a valid URI $url";
		sayYellow "Not a valid URI $url";
	}
}

sayYellow "Invalid url_to_fetch: ".scalar @invalidFetchUrl;
$queryStr = "DELETE FROM `url_to_fetch` WHERE `id` = ?";
$query = $dbh->prepare($queryStr);
foreach my $invalidId (@invalidFetchUrl) {
	$query->execute($invalidId);
	queryLog $query;
	sayLog "Removed $invalidId from url_to_fetch";
}
sayGreen "Invalid url_to_fetch removed: ".scalar @invalidFetchUrl;

# Update the unique domains
$queryStr = "INSERT IGNORE INTO `unique_domain` (url) select DISTINCT(baseurl) as url FROM `url_to_fetch`
				WHERE `fetch_failed` = 0 AND `last_fetched` IS NOT NULL";
$query = $dbh->prepare($queryStr);
$query->execute();
queryLog $query;

# Now validate the unique ones
$queryStr = "SELECT `id`, `url` FROM `unique_domain`";
$query = $dbh->prepare($queryStr);
$query->execute();
queryLog $query;
my @invalidUrls = ();
my @toBeDeletedFromFetchAgain = ();
while(my @row = $query->fetchrow_array) {
	my $link = $row[1];
	my $id = $row[0];
	if(!is_web_uri($link)) {
		sayYellow "Ignore URL it is invalid: $link";
		push(@invalidUrls, $id);
		push(@toBeDeletedFromFetchAgain, $link);
		next;
	}

	my $url = url($link);
	if(!defined($url->scheme) || index($url->scheme,"http") == -1) {
		sayYellow "Ignore URL because of scheme: $link";
		push(@invalidUrls, $id);
		push(@toBeDeletedFromFetchAgain, $link);
		next;
	}
}

sayYellow "Invalid unique_domain: ".scalar @invalidUrls;
$queryStr = "DELETE FROM `unique_domain` WHERE `id` = ?";
$query = $dbh->prepare($queryStr);
foreach my $invalidId (@invalidUrls) {
	$query->execute($invalidId);
	queryLog $query;
	sayLog "Removed $invalidId from unique_domain";
}
sayGreen "Invalid unique_domain removed: ".scalar @invalidUrls;


# remove urls from fetch since we have enough already
$queryStr = "SELECT count(baseurl) AS amount, baseurl
				FROM `url_to_fetch`
				WHERE `last_fetched` <> 0
				GROUP BY baseurl
				HAVING amount > ".$config->{cleanup}->{CLEANUP_URLS_AMOUNT_ABOVE};
$query = $dbh->prepare($queryStr);
$query->execute();
queryLog $query;
while(my @row = $query->fetchrow_array) {
	my $baseUrl = $row[1];
	push(@toBeDeletedFromFetchAgain, $baseUrl);
}

sayYellow "Remove baseurls from url_to_fetch: ".scalar @toBeDeletedFromFetchAgain;
$queryStr = "DELETE FROM url_to_fetch WHERE `baseurl` = ?";
$query = $dbh->prepare($queryStr);
foreach my $baseUrl (@toBeDeletedFromFetchAgain) {
	$query->execute($baseUrl);
	queryLog $query;
	sayLog "Removed $baseUrl from url_to_fetch";
}
sayGreen "Removed baseurls from url_to_fetch: ".scalar @toBeDeletedFromFetchAgain;

# remove failed fetches
sayYellow "Remove fetch_failed";
$queryStr = "DELETE FROM url_to_fetch WHERE fetch_failed = 1";
$query = $dbh->prepare($queryStr);
$query->execute();
sayGreen "Remove fetch_failed done";

sayYellow "Remove invalid urls which the is_web_uri check does let pass";
$queryStr = "DELETE FROM unique_domain WHERE `url` NOT LIKE '%.%'";
$query = $dbh->prepare($queryStr);
$query->execute();
$queryStr = "DELETE FROM `url_to_fetch` WHERE `baseurl` LIKE '% %'";
$query = $dbh->prepare($queryStr);
$query->execute();
sayYellow "Remove invalid urls done";

addToStats($dbh, "cleanup");

# write itself to the last run file
open(my $fh, '>:encoding(UTF-8)', "log/last.run") or die "Could not open file 'log/last.run' $!";
print $fh "cleanup";
close($fh);

# end
$dbh->disconnect();
sayGreen "Cleanup complete";
select STDOUT;
