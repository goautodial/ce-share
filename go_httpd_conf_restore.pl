#!/usr/bin/perl
############################################################################################
####  Name:             go_httpd_conf_restore.pl                                        ####
####  Version:          2.0                                                             ####
####  Copyright:        GOAutoDial Inc. - Januarius Manipol <januarius@goautodial.com>  ####
####  License:          AGPLv2                                                          ####
############################################################################################

#### LIBRARIES ####
use DBI;
use DBD::mysql;

#### CURRENT unix_timestamp ####
my $unix_timestamp = time;

#### DATABASE ####
$PATHconf = '/etc/goautodial.conf';

open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
        {
        $line = $conf[$i];
        $line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
        if ($line =~ /^VARDBserver/)            {$VARDBserver = $line;          $VARDBserver =~ s/.*=//gi;}
        if ($line =~ /^VARDBdatabase/)          {$VARDBdatabase = $line;        $VARDBdatabase =~ s/.*=//gi;}
        if ($line =~ /^VARDBuser/)              {$VARDBuser = $line;            $VARDBuser =~ s/.*=//gi;}
        if ($line =~ /^VARDBpass/)              {$VARDBpass = $line;            $VARDBpass =~ s/.*=//gi;}
        if ($line =~ /^VARDBport/)              {$VARDBport = $line;            $VARDBport =~ s/.*=//gi;}
        $i++;
        }
        
my $dbh;
my $sthA;
my $DB   = "database=$VARDBdatabase;host=$VARDBserver;port=$VARDBport";
my $DS   = "DBI:mysql:$DB";
my $USER = "$VARDBuser";
my $PASS = "$VARDBpass";

$dbh  = DBI->connect( $DS, $USER, $PASS ) or die "Can't connect to
$DS: $dbh->errstr\n"; #connect to mysql database

#### DIRECTORY SETTINGS 
my $dbfirewallres = "/usr/share/goautodial/godbhttpd";

### CREATE and DROP TABLES
`mysql -u$USER -p$PASS $VARDBdatabase -e "\\. ${dbfirewallres}/go_recording_access.sql "`;
`mysql -u$USER -p$PASS $VARDBdatabase -e "\\. ${dbfirewallres}/go_sysbackup_access.sql "`;

#### CHECK IF HTTPD CONF DB TABLE HAS CONTENTS####
$stmtA = "SELECT * from go_recording_access;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;

if ($sthArows > 0)
{
    print "SUCCESS go_firewall_rules";
}
else
{
    print "FAILED go_firewall_rules";
}
$sthA->finish();

### RUN THE GENERATED HTTPD CONF SCRIPT
`/usr/share/goautodial/go_httpd_conf.pl`;