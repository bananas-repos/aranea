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

# Fetches the urls stored in url_to_fetch and stores the resulting answer into storage folder.
# Updates entries if no response is returned (404, timeout or error) and when the fetch happened.
# The next step is 'parse-results.pl' to parse the results from the storage folder.
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
use HTTP::Request;
use LWP::UserAgent;
use Proc::Pidfile;
use open qw( :std :encoding(UTF-8) );

# 0 = Write everything to log. Without terminal colors
# 1 = Print terminal output with colors. Nothing to log file.
# 2 = Print additional debug lines. Nothing to log file.
our $DEBUG = 0;
our $config = Config::Tiny->read("config.ini", "utf8");
die "Could not read config! $Config::Tiny::errstr\n" unless ref $config;

# create the PID file and exit silently if it is already running.
my $currentdir = getcwd;
my $pid = Proc::Pidfile->new(pidfile => $currentdir."/log/aranea.pid", silent => 1);

# write everything into log file
if($DEBUG == 0) {
    open (my $LOG, '>>', 'log/aranea.log') or die "Could not open file 'log/aranea.log' $!";
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

sayGreen "Fetch starting";

# Fetch the urls to fetch from the table
my %urlsToFetch;
my $query = $dbh->prepare("SELECT `id`, `url`
                            FROM `url_to_fetch`
                            WHERE `last_fetched` < NOW() - INTERVAL 1 MONTH
                                OR `last_fetched` IS NULL
                                AND `fetch_failed` = 0
                            LIMIT ".$config->{fetch}->{FETCH_URLS_PER_RUN});
$query->execute();
queryLog $query;
while(my @row = $query->fetchrow_array) {
    $urlsToFetch{$row[0]} = $row[1];
}

# Successful and failed fetches
my @urlsFetched;
my @urlsFailed;

# Config the user agent for the request
my $request_headers = [
    'User-Agent'      => $config->{http}->{UA_AGENT},
    'Accept'          => $config->{http}->{UA_ACCEPT},
    'Accept-Language' => $config->{http}->{UA_LANG},
    'Accept-Encoding' => HTTP::Message::decodable,
    'Cache-Control'   => $config->{http}->{UA_CACHE},
    'X-Application'   => 'crawler aranea'
];
my $ua = LWP::UserAgent->new();
$ua->timeout($config->{fetch}->{UA_TIMEOUT});
$ua->max_size($config->{fetch}->{FETCH_MAX_BYTES_PER_PAGE});

## Now loop over them and store the results
my $counter = 0;
my $allFetched = 0;
my $allFailed = 0;
while ( my ($id, $url) = each %urlsToFetch ) {
    sayYellow "Fetching: $id $url";

    my $req = HTTP::Request->new(GET => $url, $request_headers);
    my $res = $ua->request($req);
    if ($res->is_success) {
        # callback tells us to stop
        if($res->header('Client-Aborted')) {
            push(@urlsFailed, $id);
            $allFailed++;
            sayYellow "Aborted, too big.";
            next;
        }
        if(index($res->content_type, "text/html") == -1) {
            push(@urlsFailed, $id);
            $allFailed++;
            sayYellow "Fetching: $id ignored. Not html";
            next;
        }
        open(my $fh, '>:encoding(UTF-8)', "storage/$id.result") or die "Could not open file 'storage/$id.result' $!";
        print $fh $res->decoded_content();
        close($fh);
        push(@urlsFetched, $id);
        $allFetched++;
        sayGreen"Fetching: $id ok";
    }
    else {
        push(@urlsFailed, $id);
        $allFailed++;
        sayRed "Fetching: $id failed: $res->code ".$res->status_line;
    }

    if($counter >= $config->{fetch}->{FETCH_URLS_PER_PACKAGE}) {
        updateFetched($dbh, @urlsFetched);
        $dbh->commit();
        updateFailed($dbh, @urlsFailed);
        $dbh->commit();

        sleep(rand(7));

        $counter = 0;
        @urlsFetched = ();
        @urlsFailed = ();
    }

    $counter++;
}
updateFetched($dbh, @urlsFetched);
$dbh->commit();
updateFailed($dbh, @urlsFailed);
$dbh->commit();

# some stats stuff
addToStats($dbh, 'fetch');
addToStats($dbh, 'fetchfailed', $allFailed, $allFailed);
addToStats($dbh, 'fetchsuccess', $allFetched, $allFetched);
$dbh->commit();

# write itself to the last run file
open(my $fh, '>:encoding(UTF-8)', "log/last.run") or die "Could not open file 'log/last.run' $!";
print $fh "fetch";
close($fh);

# end
$dbh->disconnect();
sayGreen "Fetch complete";
select STDOUT;

## update last_fetched in the table
sub updateFetched {
    my ($dbh, @urls) = @_;

    if (!$dbh->ping) {
        $dbh = $dbh->clone() or die "Cannot connect to db at updateFetched";
    }

    sayYellow "Update fetch timestamps: ".scalar @urls;
    $query = $dbh->prepare("UPDATE `url_to_fetch` SET `last_fetched` = NOW() WHERE `id` = ?");
    foreach my $idToUpdate (@urls) {
        sayLog "Update fetch timestamp for: $idToUpdate";
        $query->bind_param(1,$idToUpdate);
        $query->execute();
        queryLog $query;
    }
    sayGreen "Update fetch timestamps done";
}

## update fetch_failed in the table
sub updateFailed {
    my ($dbh, @urls) = @_;

    if (!$dbh->ping) {
        $dbh = $dbh->clone() or die "Cannot connect to db at updateFailed";
    }

    sayYellow "Update fetch failed: ".scalar @urls;
    $query = $dbh->prepare("UPDATE `url_to_fetch` SET `fetch_failed` = 1, `last_fetched` = NOW() WHERE `id` = ?");
    foreach my $idToUpdate (@urls) {
        sayLog "Update fetch failed for: $idToUpdate";
        $query->bind_param(1,$idToUpdate);
        $query->execute();
        queryLog $query;
    }
    sayGreen "Update fetch failed done";
}
