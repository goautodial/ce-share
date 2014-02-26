#!/usr/bin/perl
############################################################################################
####  Name:             keepalive_goautodial.pl                                         ####
####  Version:          2.0                                                             ####
####  Copyright:        GOAutoDial Inc. - Januarius Manipol <januarius@goautodial.com>  ####
####  License:          AGPLv2                                                          ####
############################################################################################
#
# Originally written as ADMIN_keepalive_ALL.pl             version  2.0.5
# Copyright (C) 2009  Matt Florell <vicidial@gmail.com>    LICENSE: AGPLv2

$DB=0; # Debug flag
$MT[0]='';   $MT[1]='';
@psline=@MT;

### begin parsing run-time options ###
if (length($ARGV[0])>1)
{
	$i=0;
	while ($#ARGV >= $i)
	{
	$args = "$args $ARGV[$i]";
	$i++;
	}
	
	if ($args =~ /--help/i)
	{
	print "allowed run time options:\n  [-t] = test\n  [-debug] = verbose debug messages\n[-debugX] = Extra-verbose debug messages\n\n";
	}
	else
	{
		if ($args =~ /-debug/i)
		{
		$DB=1; # Debug flag
		}
		if ($args =~ /--debugX/i)
		{
		$DBX=1;
		print "\n----- SUPER-DUPER DEBUGGING -----\n\n";
		}
		if ($args =~ /-t/i)
		{
		$TEST=1;
		$T=1;
		}
	}
}
else
{
#	print "no command line options set\n";
}
### end parsing run-time options ###

# default path to astguiclient configuration file:
$PATHconf =		'/etc/goautodial.conf';
open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
	{
	$line = $conf[$i];
	$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
	if ($line =~ /^VARUSRPATH/)				{$VARUSRPATH = $line;   $VARUSRPATH =~ s/.*=//gi;}
	if ($line =~ /^VARKEEPALIVE/)			{$VARKEEPALIVE = $line;   $VARKEEPALIVE =~ s/.*=//gi;}
	$i++;
	}

##### list of codes for active_keepalives and what processes they correspond to
#	X - NO KEEPALIVE PROCESSES (use only if you want none to be keepalive)\n";
#	1 - GoAutoDialD\n";

if ($VARKEEPALIVE =~ /X/)
	{
	if ($DB) {print "X in active_keepalives, exiting...\n";}
	exit;
	}

$goautodiald=0;	
$runninggoautodiald=0;	

if ($VARKEEPALIVE =~ /1/) 
	{
	$goautodiald=1;
	if ($DB) {print "goautodiald set to keepalive\n";}
	}

$REGhome = $VARUSRPATH;
$REGhome =~ s/\//\\\//gi;

##### First, check and see which processes are running #####

### you may have to use a different ps command if you're not using Slackware Linux
#	@psoutput = `ps -f -C AST_update --no-headers`;
#	@psoutput = `ps -f -C AST_updat* --no-headers`;
#	@psoutput = `/bin/ps -f --no-headers -A`;
#	@psoutput = `/bin/ps -o pid,args -A`; ### use this one for FreeBSD
@psoutput = `/bin/ps -o "%p %a" --no-headers -A`;

$i=0;
foreach (@psoutput)
{
chomp($psoutput[$i]);
if ($DBX) {print "$i|$psoutput[$i]|     \n";}
@psline = split(/\/usr\/bin\/perl /,$psoutput[$i]);

	if ($psline[1] =~ /$REGhome\/goautodiald\.pl/) 
		{
		$runninggoautodiald++;
		if ($DB) {print "goautodiald RUNNING:              |$psline[1]|\n";}
		}
$i++;
}

##### Second, double-check that non-running scripts are not running #####
@psline=@MT;
@psoutput=@MT;

if (($goautodiald > 0) && ($runninggoautodiald < 1))
	{

if ($DB) {print "double check that processes are not running...\n";}

	sleep(1);

#`PERL5LIB="/usr/share/astguiclient/libs"; export PERL5LIB`;
### you may have to use a different ps command if you're not using Slackware Linux
#	@psoutput = `ps -f -C AST_update --no-headers`;
#	@psoutput = `ps -f -C AST_updat* --no-headers`;
#	@psoutput = `/bin/ps -f --no-headers -A`;
#	@psoutput = `/bin/ps -o pid,args -A`; ### use this one for FreeBSD
@psoutput2 = `/bin/ps -o "%p %a" --no-headers -A`;
$i=0;
foreach (@psoutput2)
	{
		chomp($psoutput2[$i]);
	if ($DBX) {print "$i|$psoutput2[$i]|     \n";}
	@psline = split(/\/usr\/bin\/perl /,$psoutput2[$i]);

	if ($psline[1] =~ /$REGhome\/goautodiald\.pl/) 
		{
		$runninggoautodiald++;
		if ($DB) {print "goautodiald RUNNING:              |$psline[1]|\n";}
		}
	$i++;
	}

if ( ($goautodiald > 0) && ($runninggoautodiald < 1) )
	{ 
	if ($DB) {print "starting goautodiald...\n";}
	# add a '-L' to the command below to activate logging
	`/usr/bin/screen -d -m -S goautodial_d $VARUSRPATH/goautodiald.pl`;
	#`/usr/bin/perl $VARUSRPATH/goautodiald.pl`;
	}
}

if ($DB) {print "DONE\n";}
exit;
