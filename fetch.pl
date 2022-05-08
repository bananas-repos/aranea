#!/usr/bin/perl -w

# This program is free software: you can redistribute it and/or modify
# it under the terms of the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE
#
# You should have received a copy of the
# COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
# along with this program.  If not, see http://www.sun.com/cddl/cddl.html
#
# 2022 https://://www.bananas-playground.net/projekt/aranea

use 5.20.0;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Term::ANSIColor qw(:constants);

use lib './lib';
use Aranea::Common qw(sayLog sayYellow sayGreen sayRed);

use open qw( :std :encoding(UTF-8) );
use DBI;
use ConfigReader::Simple;
use LWP::UserAgent;
use HTTP::Request;


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


## fetch the urls to fetch from the table
my %urlsToFetch;
my $query = $dbh->prepare("SELECT `id`, `url` 
							FROM `url_to_fetch` 
							WHERE `last_fetched` < NOW() - INTERVAL 1 WEEK
								OR `last_fetched` IS NULL
								AND `fetch_failed` = 0
							LIMIT ".$config->get("FETCH_URLS_PER_RUN"));
$query->execute();
while(my @row = $query->fetchrow_array) {
	$urlsToFetch{$row[0]} = $row[1];
}
$query->finish();

# successful fetches
my @urlsFetched;
my @urlsFailed;

# config the user agent for the request
my $request_headers = [
  'User-Agent' => $config->get("UA_AGENT"),
  'Accept' => $config->get("UA_ACCEPT"),
  'Accept-Language' => $config->get("UA_LANG"),
  'Accept-Encoding' => HTTP::Message::decodable,
  'Cache-Control' => $config->get("UA_CACHE")
];
my $ua = LWP::UserAgent->new;

## now loop over them and store the results
my $counter = 0;
while ( my ($id, $url) = each %urlsToFetch ) {
	sayYellow "Fetching: $id $url";

	my $req = HTTP::Request->new(GET => $url, $request_headers);
	my $res = $ua->request($req);
	if ($res->is_success) {
		if(index($res->content_type, "text/html") == -1) {
			sayYellow "Fetching: $id ignored. Not html";
			push(@urlsFailed, $id);
			next;
		}
		open(my $fh, '>', "storage/$id.result") or die "Could not open file 'storage/$id.result' $!";		
		print $fh $res->decoded_content();
		close($fh);
		push(@urlsFetched, $id);
		sayGreen"Fetching: $id ok";
	}
	else {
		sayRed "Fetching: $id failed: $res->code ".$res->status_line;
		push(@urlsFailed, $id);
	}
	
	if($counter >= $config->get("FETCH_URLS_PER_PACKAGE")) {
		updateFetched($dbh, @urlsFetched);
		updateFailed($dbh, @urlsFailed);
		sleep(rand(7));

		$counter = 0;
		@urlsFetched = ();
		@urlsFailed = ();
	}

	$counter++;
}
updateFetched($dbh, @urlsFetched);
updateFailed($dbh, @urlsFailed);

$dbh->disconnect();
sayGreen "Fetch complete";



## update last_fetched in the table
sub updateFetched {
	my ($dbh, @urls) = @_;
	sayYellow "Update fetch timestamps: ".scalar @urls;
	$query = $dbh->prepare("UPDATE `url_to_fetch` SET `last_fetched` = NOW() WHERE `id` = ?");
	foreach my $idToUpdate (@urls) {
		sayLog "Update fetch timestamp for: $idToUpdate" if($DEBUG);
		$query->bind_param(1,$idToUpdate);
		$query->execute();
	}
	$query->finish();
	sayGreen "Update fetch timestamps done";
}

## update fetch_failed in the table
sub updateFailed {
	my ($dbh, @urls) = @_;

	sayYellow "Update fetch failed: ".scalar @urls;
	$query = $dbh->prepare("UPDATE `url_to_fetch` SET `fetch_failed` = 1 WHERE `id` = ?");
	foreach my $idToUpdate (@urls) {
		sayLog "Update fetch failed for: $idToUpdate" if($DEBUG);
		$query->bind_param(1,$idToUpdate);
		$query->execute();
	}
	$query->finish();
	sayGreen "Update fetch failed done";	
}

