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

package Aranea::Common;
use 5.36.0;
use strict;
use warnings;
use utf8;
use Term::ANSIColor qw(:constants colorstrip);

use DateTime;
use Exporter qw(import);


our @EXPORT_OK = qw(sayLog sayYellow sayGreen sayRed addToStats queryLog);

sub sayLog {
	my ($string) = @_;
	my $dt = DateTime->now;
	say "[".$dt->datetime."] DEBUG: ".$string if $main::DEBUG>1;
}

sub sayYellow {
	my ($string) = @_;
	my $dt = DateTime->now;
	my $s = CLEAR . YELLOW . "[".$dt->datetime."] ".$string . RESET;
	say $main::DEBUG < 1 ? colorstrip($s) : $s;
}

sub sayGreen {
	my ($string) = @_;
	my $dt = DateTime->now;
	my $s = CLEAR . GREEN . "[".$dt->datetime."] ".$string . RESET;
	say $main::DEBUG < 1 ? colorstrip($s) : $s;
}

sub sayRed {
	my ($string) = @_;
	my $dt = DateTime->now;
	my $s = BOLD . RED . "[".$dt->datetime."] ".$string . RESET;
	say $main::DEBUG < 1 ? colorstrip($s) : $s;
}

## subroutine to add something to the stats table
## if $value or $onDuplicateValue is empty, NOW() is used. This is done with the COALESCE mysql method
sub addToStats {
	my ($dbh, $action, $value, $onDuplicateValue) = @_;

	if(!defined $action || $action eq "") {
		return;
	}

	my $queryStr = "INSERT INTO `stats` SET `action` = ?, `value` = COALESCE(?, NOW())";
	$queryStr .= " ON DUPLICATE KEY UPDATE `value` = COALESCE(?, NOW())";
	my $query = $dbh->prepare($queryStr);

	$query->bind_param(1,$action);
	$query->bind_param(2,$value);
	$query->bind_param(3,$onDuplicateValue);

	$query->execute();
}

sub queryLog {
	my ($query) = @_;
	sayLog $query->{Statement};
	sayLog "$_ $query->{ParamValues}{$_}" for (keys %{$query->{ParamValues}});
}

1;
