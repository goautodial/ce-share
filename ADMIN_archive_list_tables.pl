#!/usr/bin/perl
############################################################################################
####  Name:             ADMIN_archive_list_tables.pl                                    ####
####  Type:             perl script                                                     ####
####  Version:          3.0                                                             ####
####  Build:            1366106153                                                      ####
####  Copyright:        GOAutoDial Inc. (c) 2011-2013 - <dev@goautodial.com>            ####
####  Written by:       Christopher P. Lomuntad                                         ####
####  License:          AGPLv2                                                          ####
############################################################################################

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
		print "Allowed run time options:\n";
		print "  [--weeks=XX] = number of weeks to archive past, must be 52 or less, default is 8\n";
		print "  [--months=XX] = number of months to archive past, must be 12 or less, default is 2\n";
		print "  [--quiet] = quiet mode\n";
		print "  [-t] = test mode\n\n";
		exit;
		}
	else
		{
		if ($args =~ /-quiet/i)
			{
			$q=1;   $Q=1;
			}
		if ($args =~ /-t/i)
			{
			$T=1;   $TEST=1;
			print "\n----- TESTING -----\n\n";
			}
		if ($args =~ /--weeks=/i)
			{
			@data_in = split(/--weeks=/,$args);
			$CLIvalue = $data_in[1];
			$CLIvalue =~ s/ .*$//gi;
			$CLIvalue =~ s/\D//gi;
                        $isWeeks=1;
			if ($CLIvalue > 52)
				{$CLIvalue=52;}
			if ($Q < 1) 
				{print "\n----- WEEKS OVERRIDE: $CLIvalue -----\n\n";}
			}
		if ($args =~ /--months=/i)
			{
			@data_in = split(/--months=/,$args);
			$CLIvalue = $data_in[1];
			$CLIvalue =~ s/ .*$//gi;
			$CLIvalue =~ s/\D//gi;
                        $isMonths=1;
			if ($CLIvalue > 12)
				{$CLIvalue=12;}
			if ($Q < 1) 
				{print "\n----- MONTHS OVERRIDE: $CLIvalue -----\n\n";}
			}
		}
	}
else
	{
	print "no command line options set\n";
	}
### end parsing run-time options ###
if ($isMonths) {
        $interVal = "MONTH";
        if ( ($CLIvalue > 12) || ($CLIvalue < 1) )
                {$CLIvalue=2;}
}
if ($isWeeks) {
        $interVal = "WEEK";
        if ( ($CLIvalue > 52) || ($CLIvalue < 1) )
                {$CLIvalue=8;}
}

$secX=time();
# default path to astguiclient configuration file:
$PATHconf =		'/etc/astguiclient.conf';

open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
	{
	$line = $conf[$i];
	$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
	if ( ($line =~ /^PATHhome/) && ($CLIhome < 1) )
		{$PATHhome = $line;   $PATHhome =~ s/.*=//gi;}
	if ( ($line =~ /^PATHlogs/) && ($CLIlogs < 1) )
		{$PATHlogs = $line;   $PATHlogs =~ s/.*=//gi;}
	if ( ($line =~ /^PATHagi/) && ($CLIagi < 1) )
		{$PATHagi = $line;   $PATHagi =~ s/.*=//gi;}
	if ( ($line =~ /^PATHweb/) && ($CLIweb < 1) )
		{$PATHweb = $line;   $PATHweb =~ s/.*=//gi;}
	if ( ($line =~ /^PATHsounds/) && ($CLIsounds < 1) )
		{$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
	if ( ($line =~ /^PATHmonitor/) && ($CLImonitor < 1) )
		{$PATHmonitor = $line;   $PATHmonitor =~ s/.*=//gi;}
	if ( ($line =~ /^VARserver_ip/) && ($CLIserver_ip < 1) )
		{$VARserver_ip = $line;   $VARserver_ip =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_server/) && ($CLIDB_server < 1) )
		{$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_database/) && ($CLIDB_database < 1) )
		{$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_user/) && ($CLIDB_user < 1) )
		{$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_pass/) && ($CLIDB_pass < 1) )
		{$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_port/) && ($CLIDB_port < 1) )
		{$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
	$i++;
	}

# Customized Variables
$server_ip = $VARserver_ip;		# Asterisk server IP

use DBI;
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "$VARDB_user", "$VARDB_pass")
 or die "Couldn't connect to database: " . DBI->errstr;


# Get DB time
if ($CLIvalue > 0)
        {
        $stmtA = "SELECT DATE_SUB(NOW(), INTERVAL $CLIvalue $interVal) AS `interval`;";
        $sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
        $sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
        $del_time=$sthA->fetchrow_array;
        }


if (!$Q) {print "\n\n-- ADMIN_archive_list_tables.pl --\n\n";}
if (!$Q) {print " This program is designed to put all records from  vicidial_lists and vicidial_list\n";}
if (!$Q) {print " in relevant _archive tables and delete records in original tables older than\n";}
if (!$Q) {print " $CLIvalue ", lc($interVal),"s ( $del_time ) from current date and time\n\n";}

if (!$T) 
	{
	##### vicidial_lists
	$stmtA = "SELECT list_id FROM vicidial_lists WHERE active='N' AND list_id NOT IN ('998','999') AND list_changedate  < DATE_SUB(NOW(), INTERVAL $CLIvalue $interVal);";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
        $vicidial_lists_count=$sthArows;
        $rec_count=0;
	while ($sthArows > $rec_count)
		{
		@aryA = $sthA->fetchrow_array;
		$vicidial_lists_ids[$rec_count] =	"$aryA[0]";
                
                $rec_count++;
		}
        $vicidial_lists_ids = join("','",@vicidial_lists_ids);
	$sthA->finish();

	$stmtA = "SELECT count(*) from vicidial_lists_archive;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if ($sthArows > 0)
		{
		@aryA = $sthA->fetchrow_array;
		$vicidial_lists_archive_count =	$aryA[0];
		}
	$sthA->finish();

	if (!$Q) {print "\nProcessing vicidial_lists table...  ($vicidial_lists_count|$vicidial_lists_archive_count)\n";}
	$stmtA = "INSERT IGNORE INTO vicidial_lists_archive SELECT * from vicidial_lists WHERE active='N' AND list_id NOT IN ('998','999') AND list_changedate  < DATE_SUB(NOW(), INTERVAL $CLIvalue $interVal);";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows = $sthA->rows;
	if (!$Q) {print "$sthArows rows inserted into vicidial_lists_archive table\n";}
	
	$rv = $sthA->err();
	if (!$rv)
		{
		#$stmtA = "DELETE FROM vicidial_lists WHERE active='N' AND list_id NOT IN ('998','999') AND list_changedate  < DATE_SUB(NOW(), INTERVAL $CLIvalue $interVal);";
		#$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		#$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		#$sthArows = $sthA->rows;
		#if (!$Q) {print "$sthArows rows deleted from vicidial_lists table \n";}
	
		$stmtA = "optimize table vicidial_lists;";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	
		$stmtA = "optimize table vicidial_lists_archive;";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		}

	##### vicidial_list
	$stmtA = "SELECT count(*) from vicidial_list WHERE list_id IN ('$vicidial_lists_ids');";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if ($sthArows > 0)
		{
		@aryA = $sthA->fetchrow_array;
		$vicidial_list_count =	$aryA[0];
		}
	$sthA->finish();
	
	$stmtA = "SELECT count(*) from vicidial_list_archive;";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows=$sthA->rows;
	if ($sthArows > 0)
		{
		@aryA = $sthA->fetchrow_array;
		$vicidial_list_archive_count =	$aryA[0];
		}
	$sthA->finish();
	
	if (!$Q) {print "\nProcessing vicidial_list table...  ($vicidial_list_count|$vicidial_list_archive_count)\n";}
	$stmtA = "INSERT IGNORE INTO vicidial_list_archive SELECT * from vicidial_list WHERE list_id IN ('$vicidial_lists_ids');";
	$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
	$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	$sthArows = $sthA->rows;
	if (!$Q) {print "$sthArows rows inserted into vicidial_list_archive table\n";}
	
	$rv = $sthA->err();
	if (!$rv)
		{
		$stmtA = "DELETE FROM vicidial_list WHERE list_id IN ('$vicidial_lists_ids');";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		$sthArows = $sthA->rows;
		if (!$Q) {print "$sthArows rows deleted from vicidial_list table \n";}
	
		$stmtA = "optimize table vicidial_list;";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
	
		$stmtA = "optimize table vicidial_list_archive;";
		$sthA = $dbhA->prepare($stmtA) or die "preparing: ",$dbhA->errstr;
		$sthA->execute or die "executing: $stmtA ", $dbhA->errstr;
		}
        }


#$dbhA->disconnect();
#print "$del_time\n\n";


### calculate time to run script ###
$secY = time();
$secZ = ($secY - $secX);
$secZm = ($secZ /60);
if (!$Q) {print "\nscript execution time in seconds: $secZ     minutes: $secZm\n";}

exit;
