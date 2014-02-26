#!/usr/bin/perl
############################################################################################
####  Name:             go_httpd_conf.pl                                                ####
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

#### CREATE / GENERATE A HTTPD CONF FILE ####
`touch /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo '### HTTP CONF configuration written by GoAutoDial - go_httpd_conf.pl' > /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo '### Manual customization of this file is not recommended.' >> /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo '<Directory "/var/spool/asterisk/monitorDONE">'   	>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Order Deny,Allow'                       			>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Deny from all'                        		>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
$stmtA = "SELECT ip_address from go_recording_access where active='Y' order by access_id asc;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;
$count=0;
while ($sthArows > $count)
{
        @aryA            = $sthA->fetchrow_array;
        $ip_address      = $aryA[0];
	`echo 'Allow from '$ip_address                                  >>  /etc/httpd/conf.d/goautodial_httpd.conf`;
	$count++;
}
$sthA->finish(); #finish mysql connection
`echo 'Options Indexes FollowSymLinks'             		>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo '</Directory>'                 				>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Alias /RECORDINGS /var/spool/asterisk/monitorDONE'       >>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Alias /recordings /var/spool/asterisk/monitorDONE'       >>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo ' '              						>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo '<Directory "/usr/share/goautodial/gosysbackup">'         >>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Order Deny,Allow'                        		>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Deny from all'                        		>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
$stmtA = "SELECT ip_address from go_sysbackup_access where active='Y' order by access_id asc;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;
$count=0;
while ($sthArows > $count)
{
        @aryA            = $sthA->fetchrow_array;
        $ip_address      = $aryA[0];
        `echo 'Allow from '$ip_address                                  >>  /etc/httpd/conf.d/goautodial_httpd.conf`;
        $count++;
}
$sthA->finish(); #finish mysql connection
`echo 'Options Indexes FollowSymLinks'             		>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo '</Directory>'                 				>>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Alias /gosysbackup /usr/share/goautodial/gosysbackup'    >>  /etc/httpd/conf.d/goautodial_httpd.conf`;
`echo 'Alias /GOSYSBACKUP /usr/share/goautodial/gosysbackup'    >>  /etc/httpd/conf.d/goautodial_httpd.conf`;

### RELOAD HTTPD
`/usr/share/goautodial/goautodialc.pl "/etc/init.d/httpd reload"`;