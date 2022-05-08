# This program is free software: you can redistribute it and/or modify
# it under the terms of the COMMON DEVELOPMENT AND DISTRIBUTION LICENSE
#
# You should have received a copy of the
# COMMON DEVELOPMENT AND DISTRIBUTION LICENSE (CDDL) Version 1.0
# along with this program.  If not, see http://www.sun.com/cddl/cddl.html
#
# 2022 https://://www.bananas-playground.net/projekt/aranea

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