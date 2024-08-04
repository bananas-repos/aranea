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
use 5.20.0;
use strict;
use warnings;
use utf8;
use Term::ANSIColor qw(:constants);

use DateTime;
use Exporter qw(import);


our @EXPORT_OK = qw(sayLog sayYellow sayGreen sayRed);

sub sayLog {
	my ($string) = @_;
	my $dt = DateTime->now;
	say "[".$dt->datetime."] DEBUG: ".$string;
}

sub sayYellow {
	my ($string) = @_;
	my $dt = DateTime->now;
	say CLEAR,YELLOW, "[".$dt->datetime."] ".$string, RESET;
}

sub sayGreen {
	my ($string) = @_;
	my $dt = DateTime->now;
	say CLEAR,GREEN, "[".$dt->datetime."] ".$string, RESET;
}

sub sayRed {
	my ($string) = @_;
	my $dt = DateTime->now;
	say BOLD, RED, "[".$dt->datetime."] ".$string, RESET;
}

1;
