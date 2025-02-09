#!/usr/bin/perl -w

# 2022 - 2025 https://www.bananas-playground.net/projekt/aranea

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

# Use the entries from categorization to update uniq_domain which does not have a category yet

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
use URI::URL;

# 0 = Write everything to log. Without terminal colors
# 1 = Print terminal output with colors. Nothing to log file.
# 2 = Print additional debug lines. Nothing to log file.
our $DEBUG = 2;
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
    #AutoCommit=>0, # manually use transactions
    mysql_enable_utf8mb4 => 1
);
my $dbDsn = "DBI:mysql:database=".$config->{db}->{DB_NAME}.";host=".$config->{db}->{DB_HOST}.";port=".$config->{db}->{DB_PORT};
my $dbh = DBI->connect($dbDsn,$config->{db}->{DB_USER},$config->{db}->{DB_PASS}, \%dbAttr);
die "Failed to connect to MySQL database:DBI->errstr()" unless($dbh);

sayGreen "Categorization starting";

# Fetch the urls to fetch from the table
my %entriesToCategorize;
my $query = $dbh->prepare("SELECT `id`, `url`
                            FROM `unique_domain`
                            WHERE `category` = ''");
$query->execute();
queryLog $query;
while(my @row = $query->fetchrow_array) {
    $entriesToCategorize{$row[0]} = $row[1];
}

$query = $dbh->prepare("SELECT `category` FROM `categorization` WHERE `domain` = ?");
while ( my ($id, $url) = each %entriesToCategorize ) {
    my $URL = url($url);
    $query->execute($URL->host);
    queryLog $query;
    my $result = $query->fetchrow_hashref;
    if($result) {
        sayYellow "Found match for '$url': $result->{category}";
        my $updateQuery = $dbh->prepare("UPDATE `unique_domain` SET `category` = ? WHERE `id` = ?");
        $updateQuery->execute($result->{category}, $id);
        queryLog $updateQuery;
    }
}

# end
$dbh->disconnect();
sayGreen "Categorization complete";
select STDOUT;
