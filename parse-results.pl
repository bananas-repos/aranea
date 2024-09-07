#!/usr/bin/perl -w

# 2022 - 2024 https://://www.bananas-playground.net/projekt/aranea

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
use HTML::LinkExtor;
use URI::URL;
use File::Basename;
use Digest::MD5 qw(md5_hex);
use Data::Validate::URI qw(is_uri);

my $DEBUG = 0;
my $config = ConfigReader::Simple->new("config.txt");
die "Could not read config! $ConfigReader::Simple::ERROR\n" unless ref $config;

## DB connection
my %dbAttr = (
	PrintError=>0,# turn off error reporting via warn()
    RaiseError=>1, # turn on error reporting via die()
	AutoCommit=>0 # manually use transactions
);
my $dbDsn = "DBI:mysql:database=".$config->get("DB_NAME").";host=".$config->get("DB_HOST").";port=".$config->get("DB_PORT");
my $dbh = DBI->connect($dbDsn,$config->get("DB_USER"),$config->get("DB_PASS"), \%dbAttr);
die "failed to connect to MySQL database:DBI->errstr()" unless($dbh);


## get the fetched files
my @results = glob("storage/*.result");
die "Nothing to parse. No files found." unless(@results);

## build clean ids for query
my @queryIds = @results;
foreach (@queryIds) {
	$_ =~ s/.result//g;
	$_ =~ s|storage/||g;
}

# get the baseurls
my %baseUrls;
my $queryStr = "SELECT `id`, `baseurl` FROM `url_to_fetch` WHERE `id` IN (".join(', ', ('?') x @queryIds).")";
sayLog($queryStr) if $DEBUG;
my $query = $dbh->prepare($queryStr);
$query->execute(@queryIds);
while(my @row = $query->fetchrow_array) {
	$baseUrls{$row[0]} = $row[1];
}


# get the string to ignore
my @urlStringsToIgnore;
$queryStr = "SELECT `searchfor` FROM `url_to_ignore`";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
$query->execute();
while(my @row = $query->fetchrow) {
	push(@urlStringsToIgnore, $row[0])
}


## prepare linkExtor
my @links = ();
my @workingLinks = ();
sub leCallback {
   my($tag, %attr) = @_;
   return if $tag ne 'a';  # we only look closer at <a ...>
   push(@workingLinks, values %attr);
}
my $le = HTML::LinkExtor->new(\&leCallback);

## now parse each file and get the links
my $counter = 0;
foreach my $resultFile (@results) {
	sayYellow "Parsing file: $resultFile";

	my $fileId = basename($resultFile,".result");

	if (exists $baseUrls{$fileId}) {
		sayYellow "Baseurl: $baseUrls{$fileId}";

		$le->parse_file($resultFile);
		@workingLinks = map { $_ = url($_, $baseUrls{$fileId})->abs->as_string; } @workingLinks;
		push(@links,@workingLinks);

		unlink($resultFile);
		sayGreen "Parsing done: ".scalar @workingLinks;
	}
	else {
		sayRed "No entry found for file $resultFile";
	}

	if($counter >= $config->get("PARSE_FILES_PER_PACKAGE")) {

		@links = cleanLinks($dbh, \@links, \@urlStringsToIgnore);
		insertIntoDb($dbh, \@links);

		$counter = 0;
		@links = ();
	}

	@workingLinks = ();
	$counter++;
}

@links = cleanLinks($dbh, \@links, \@urlStringsToIgnore);
insertIntoDb($dbh, \@links);


$dbh->disconnect();
say CLEAR,GREEN, "Parse complete", RESET;


## cleanup the found links
sub cleanLinks {
	my ($dbh, $linkArray, $urlStringsToIgnore) = @_;
	my @linkArray = @{ $linkArray };
	my @urlStringsToIgnore = @{ $urlStringsToIgnore };

	sayYellow "Clean found links: ".scalar @linkArray;
	foreach my $toSearch (@urlStringsToIgnore) {
		sayYellow "Clean links from: ".$toSearch;
		@linkArray = grep {!/$toSearch/i} @linkArray;
	}
	sayGreen "Cleaned found links: ".scalar @linkArray;

	return @linkArray;
}


## update the DB with the new found links
sub insertIntoDb {
	my ($dbh, $links) = @_;
	my @links = @{ $links };

	sayYellow "Insert links into DB: ".scalar @links;
	$queryStr = "INSERT IGNORE INTO `url_to_fetch` SET
					`id` = ?,
					`url` = ?,
					`baseurl` = ?,
					`created` = NOW()";
	sayLog $queryStr if $DEBUG;
	$query = $dbh->prepare($queryStr);
	my $md5 = Digest::MD5->new;
	my $counter = 0;
	foreach my $link (@links) {

		sayLog $link if ($DEBUG);

		if(!is_uri($link)) {
			sayYellow "Ignore URL it is invalid: $link";
			next;
		}

		my $url = url($link);
		if(!defined($url->scheme) || ($url->scheme ne "http" && $url->scheme ne "https")) {
			sayYellow "Ignore URL because of scheme: $link";
			next;
		}

		$md5->add($link);
		my $digest = $md5->hexdigest;
		$query->execute($digest, $link, $url->scheme."://".$url->host);
		$md5->reset;

		$counter++;

		if($counter >= 500) {
			$counter = 0;
			sayYellow "Commit counter of 500 reached. Commiting";
			$dbh->commit();
		}

		#sayLog $digest if ($DEBUG);
		#sayLog $url->scheme if ($DEBUG);
		#sayLog $url->host if ($DEBUG);
		#sayLog $query->{Statement} if ($DEBUG);
		#sayLog Dumper($query->{ParamValues}) if ($DEBUG);

		#sayLog "Inserted: $link" if($DEBUG);
	}
	sayYellow "Final commit";
	$dbh->commit();
}
