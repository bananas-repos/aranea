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

use 5.20.0;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Term::ANSIColor qw(:constants);

use lib './lib';
use Aranea::Common qw(sayLog sayYellow sayGreen sayRed addToStats);

use open qw( :std :encoding(UTF-8) );
use DBI;
use ConfigReader::Simple;
use HTML::LinkExtor;
use URI::URL;
use File::Basename;
use Digest::MD5 qw(md5_hex);
use Data::Validate::URI qw(is_web_uri);
use Proc::Pidfile;
use Cwd;

my $DEBUG = 0;
my $config = ConfigReader::Simple->new("config.txt");
die "Could not read config! $ConfigReader::Simple::ERROR\n" unless ref $config;

# create the PID file and exit silently if it is already running.
my $currentdir = getcwd;
my $pid = Proc::Pidfile->new(pidfile => $currentdir."/log/aranea.pid", silent => 1);

if(!$DEBUG) {
	open (my $LOG, '>>', 'log/aranea.log') or die "Could not open file 'log/aranea.log' $!";
	select $LOG; $| = 1; # https://perl.plover.com/FAQs/Buffering.html
}

# DB connection
my %dbAttr = (
	PrintError=>0,# Turn off error reporting via warn()
    RaiseError=>1, # Turn on error reporting via die()
	AutoCommit=>0, # Manually use transactions
	mysql_enable_utf8mb4 => 1
);
my $dbDsn = "DBI:mysql:database=".$config->get("DB_NAME").";host=".$config->get("DB_HOST").";port=".$config->get("DB_PORT");
my $dbh = DBI->connect($dbDsn,$config->get("DB_USER"),$config->get("DB_PASS"), \%dbAttr);
die "failed to connect to MySQL database:DBI->errstr()" unless($dbh);


# Get the fetched files
my @results = glob("storage/*.result");
die "Nothing to parse. No files found." unless(@results);

# Build clean ids for query
my @queryIds = @results;
foreach (@queryIds) {
	$_ =~ s/.result//g;
	$_ =~ s|storage/||g;
}

# Get the baseurls to create absolute links to insert while parsing the file
my %baseUrls;
my $queryStr = "SELECT `id`, `baseurl` FROM `url_to_fetch` WHERE `id` IN (".join(', ', ('?') x @queryIds).")";
sayLog($queryStr) if $DEBUG;
my $query = $dbh->prepare($queryStr);
$query->execute(@queryIds);
while(my @row = $query->fetchrow_array) {
	$baseUrls{$row[0]} = $row[1];
}

# Get the string to ignore
my @urlStringsToIgnore;
$queryStr = "SELECT `searchfor` FROM `url_to_ignore`";
sayLog($queryStr) if $DEBUG;
$query = $dbh->prepare($queryStr);
$query->execute();
while(my @row = $query->fetchrow) {
	push(@urlStringsToIgnore, $row[0])
}

# Prepare linkExtor and its callback.
# The callback extracts only a tags.
my @links = ();
sub leCallback {
   my($tag, %attr) = @_;
   return if $tag ne 'a';  # we only look closer at <a ...>
   # do some cleanup first to avoid empty or urls which point to itself
   return if $attr{"href"} eq "";
   return if rindex($attr{"href"}, "#", 0) != -1; # does not begin with #
   return if $attr{"href"} eq "/";
   push(@links, $attr{'href'});
}
my $le = HTML::LinkExtor->new(\&leCallback);

# Now parse each file and get the links from it.
foreach my $resultFile (@results) {
	sayYellow "Parsing file: $resultFile";
	@links = ();
	my $fileId = basename($resultFile,".result");

	if (exists $baseUrls{$fileId}) {
		sayYellow "Baseurl: $baseUrls{$fileId}";

		my $origin = $baseUrls{$fileId};

		$le->parse_file($resultFile);

		# Create absolute links with the help of the baseurl if the url is not already absolute
		@links = map { $_ = url($_, $origin)->abs->as_string; } @links;

		@links = cleanLinks(\@links, \@urlStringsToIgnore);
		insertIntoDb($dbh, \@links, $origin);

		unlink($resultFile);
		sayGreen "Parsing done: ".scalar @links;
	}
	else {
		sayRed "No entry found for file $resultFile";
	}
}

addToStats($dbh, 'parse');
$dbh->commit();

# write itself to the last run file
open(my $fh, '>:encoding(UTF-8)', "log/last.run") or die "Could not open file 'log/last.run' $!";
print $fh "parse";
close($fh);

# end
$dbh->disconnect();
sayGreen "Parse complete";
select STDOUT;


## cleanup the found links
sub cleanLinks {
	my ($linkArray, $urlStringsToIgnore) = @_;
	my @linkArray = @{ $linkArray };
	my @urlsToIgnore = @{ $urlStringsToIgnore };

	sayYellow "Clean found links: ".scalar @linkArray;
	foreach my $toSearch (@urlsToIgnore) {
		sayYellow "Clean links from: ".$toSearch if $DEBUG;
		@linkArray = grep {!/$toSearch/i} @linkArray;
	}
	sayGreen "Cleaned found links: ".scalar @linkArray;

	return @linkArray;
}


## update the DB with the new found links
sub insertIntoDb {
	my ($dbh, $links, $origin) = @_;
	my @links = @{ $links };

	sayYellow "Insert links into DB: ".scalar @links;
	$queryStr = "INSERT IGNORE INTO `url_to_fetch` SET
					`id` = ?,
					`url` = ?,
					`baseurl` = ?,
					`created` = NOW()";
	sayLog $queryStr if $DEBUG;
	$query = $dbh->prepare($queryStr);

	my $queryOriginStr = "INSERT INTO `url_origin` SET
						`origin` = ?,
						`target` = ?,
						`created` = NOW(),
						`amount` = 1
						ON DUPLICATE KEY UPDATE `amount` = `amount`+1";
	sayLog $queryOriginStr if $DEBUG;
	my $queryOrigin = $dbh->prepare($queryOriginStr);

	my $md5 = Digest::MD5->new;
	my $counter = 0;
	my $allLinks = 0;
	my $allFailedLinks = 0;
	foreach my $link (@links) {

		sayLog $link if ($DEBUG);

		if(!is_web_uri($link)) {
			sayYellow "Ignore URL it is invalid: $link";
			$allFailedLinks++;
			next;
		}

		my $url = url($link);
		if(!defined($url->scheme) || ($url->scheme ne "http" && $url->scheme ne "https")) {
			sayYellow "Ignore URL because of scheme: $link";
			$allFailedLinks++;
			next;
		}

		$md5->add($link);
		my $digest = $md5->hexdigest;
		my $baseurl = $url->scheme."://".$url->host;
		$query->execute($digest, $link, $baseurl);
		$md5->reset;

		# update relation
		$queryOrigin->execute($origin, $baseurl) if($origin ne $baseurl);

		$counter++;
		$allLinks++;

		if($counter >= $config->get("PARSE_URLS_PER_PACKAGE")) {
			$counter = 0;
			sayYellow "Commit counter of PARSE_URLS_PER_PACKAGE reached. Commiting";
			$dbh->commit();
		}
	}

	# stats stuff
	addToStats($dbh, 'parsesuccess', $allLinks, $allLinks);
	addToStats($dbh, 'parsefailed', $allFailedLinks, $allFailedLinks);

	sayYellow "Final commit";
	$dbh->commit();
}
