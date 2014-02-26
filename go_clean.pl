#!/usr/bin/perl
############################################################################################
####  Name:             go_clean.pl                                                     ####
####  Version:          2.0                                                             ####
####  Copyright:        GOAutoDial Inc. - Januarius Manipol <januarius@goautodial.com>  ####
####  License:          AGPLv2                                                          ####
############################################################################################

use POSIX qw/strftime/;

my $gologspath = '/var/log/goautodial';
my $filename    = strftime('%d-%b-%Y-%H:%M',localtime);

#print strftime('%D %T',localtime); ## outputs 12/17/08 10:08:35
#print strftime('%d-%b-%Y-%H:%M',localtime); ## outputs 17-Dec-2008-10:08

#print $filename;

`cp $gologspath/goautodiald.log $gologspath/goautodiald.log.$filename`;
`cp $gologspath/nohup.log $gologspath/nohup.log.$filename`;

`echo "" > $gologspath/goautodiald.log`;
`echo "" > $gologspath/nohup.log`;

quit;
