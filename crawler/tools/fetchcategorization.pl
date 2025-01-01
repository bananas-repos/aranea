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

# Update categorization table based on https://github.com/StevenBlack/hosts/tree/master
# Download, parse and insert into the db.

use 5.36.0;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Term::ANSIColor qw(:constants);

use lib '../lib';
use Aranea::Common qw(sayLog sayYellow sayGreen sayRed addToStats queryLog);

use Config::Tiny;
use DBI;
use Digest::MD5 qw(md5_hex);
use File::Basename;
use HTTP::Request;
use LWP::UserAgent;
use open qw( :std :encoding(UTF-8) );

# 0 = Write everything to log. Without terminal colors
# 1 = Print terminal output with colors. Nothing to log file.
# 2 = Print additional debug lines. Nothing to log file.
our $DEBUG = 1; # this way it can be used in Common.pm
our $config = Config::Tiny->read("../config.ini", "utf8");
die "Could not read config! $Config::Tiny::errstr\n" unless ref $config;

# write everything into log file
if($DEBUG ==  0) {
    open (my $LOG, '>>', '../log/aranea.log') or die "Could not open file '../log/aranea.log' $!";
    select $LOG; $| = 1; # https://perl.plover.com/FAQs/Buffering.html
}

# DB connection
my %dbAttr = (
    PrintError=>0,# turn off error reporting via warn()
    RaiseError=>1, # turn on error reporting via die()
    AutoCommit=>0, # manually use transactions
    mysql_enable_utf8mb4 => 1
);
my $dbDsn = "DBI:mysql:database=".$config->{db}->{DB_NAME}.";host=".$config->{db}->{DB_HOST}.";port=".$config->{db}->{DB_PORT};
my $dbh = DBI->connect($dbDsn,$config->{db}->{DB_USER},$config->{db}->{DB_PASS}, \%dbAttr);
die "Failed to connect to MySQL database:DBI->errstr()" unless($dbh);

# Config the user agent for the request
my $request_headers = [
    'User-Agent' => $config->{http}->{UA_AGENT},
    'Accept' => $config->{http}->{UA_ACCEPT},
    'Accept-Language' => $config->{http}->{UA_LANG},
    'Accept-Encoding' => HTTP::Message::decodable,
    'Cache-Control' => $config->{http}->{UA_CACHE}
];
my $ua = LWP::UserAgent->new();
$ua->timeout($config->{http}->{UA_TIMEOUT});
$ua->max_size(($config->{fetch}->{FETCH_MAX_BYTES_PER_PAGE})*2); # avoid big downloads but make sure we do get the data.

# I don't get this syntax at each %{$} ...
my $urlsToFetch = $config->{categorization_urls};
while (my ($id, $url) = each %{$urlsToFetch}) {
    sayYellow "Fetching: $id $url";
    my $req = HTTP::Request->new(GET => $url, $request_headers);
    my $res = $ua->request($req);
    if ($res->is_success) {
        # callback tells us to stop
        if($res->header('Client-Aborted')) {
            sayYellow "Aborted, too big.";
            next;
        }

        open(my $fh, '>:encoding(UTF-8)', "../storage/$id.cat.txt") or die "Could not open file '../storage/$id.cat.txt' $!";
        print $fh $res->decoded_content();
        close($fh);
        sayGreen "Done.";

    } else {
        sayRed "Fetching: $id failed: $res->code ".$res->status_line;
    }
}
sayGreen "Fetch categories urls complete.";

# Get the fetched files
my @results = glob("../storage/*.cat.txt");
die "Nothing to parse. No files found." unless(@results);

my $queryStr = "INSERT IGNORE INTO `categorization` SET
                    `id` = ?,
					`domain` = ?,
					`category` = ?";
sayLog $queryStr;
my $query = $dbh->prepare($queryStr);
my $md5 = Digest::MD5->new;
my $counter = 0;
foreach my $resultFile (@results) {
    sayYellow "Parsing file: $resultFile";
    my $category = basename($resultFile,".cat.txt");

    open(FH, '<', $resultFile) or die "Could no open file for reading '$resultFile' $!";
    while(<FH>){
        next if /^#/; # comments
        next unless /\S/; # empty
        next unless / \w/; # make sure it contains a space to split
        chomp;

        my @parts = split(/ /, $_);

        $md5->add($parts[1]);
        my $digest = $md5->hexdigest;
        $query->execute($digest, $parts[1], $category);
        $md5->reset;
        queryLog $query;

        sayYellow "Inserting $parts[1] $category";

        $counter++;

        if($counter >= $config->{fetch}->{COMMIT_PACKAGE_SIZE}) {
            $counter = 0;
            $dbh->commit();
            sleep(rand(7));
        }
    }
    close(FH);
}
if($counter > 0) {
    $dbh->commit();
}

# end
$dbh->disconnect();
sayGreen "Update categorization information complete.";
select STDOUT;
