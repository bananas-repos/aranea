#!/usr/bin/perl -w
use 5.20.0;
use strict;
use warnings;
use utf8;
use Term::ANSIColor qw(:constants);
use Data::Dumper;

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
    RaiseError=>1 # turn on error reporting via die() 
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
$query->finish();


# get the string to ignore
my @urlStringsToIgnore;
$queryStr = "SELECT `searchfor` FROM `url_to_ignore`";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
$query->execute();
while(my @row = $query->fetchrow) {
	push(@urlStringsToIgnore, $row[0])
}
$query->finish();


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

	if($counter >= 50) {

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
	foreach my $link (@links) {

		if(!is_uri($link)) {
			sayYellow "Ignore URL it is invalid: $link";
			next;
		}

		my $url = url($link);
		if(!defined($url->scheme) || index($url->scheme,"http") == -1) {
			sayYellow "Ignore URL because of scheme: $link";
			next;
		}
		
		$md5->add($link);
		my $digest = $md5->hexdigest;
		$query->execute($digest, $link, $url->scheme."://".$url->host);
		$md5->reset;

		sayLog $link if ($DEBUG);
		sayLog $digest if ($DEBUG);
		sayLog $url->scheme if ($DEBUG);
		sayLog $url->host if ($DEBUG);
		sayLog $query->{Statement} if ($DEBUG);
		sayLog Dumper($query->{ParamValues}) if ($DEBUG);

		sayLog "Inserted: $link" if($DEBUG);
	}
	$query->finish();
}
