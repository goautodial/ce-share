#!/usr/bin/perl
############################################################################################
####  Name:             go_firewall.pl                                                  ####
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

#### CREATE / GENERATE A FIREWALL SCRIPT FILE ####
`touch /usr/share/goautodial/go_firewall_rule.pl`;
`chmod +x /usr/share/goautodial/go_firewall_rule.pl`;

`echo "### Firewall script / configuration written by GoAutoDial - go_firewall.pl" > /usr/share/goautodial/go_firewall_rule.pl`;
`echo "### Manual customization of this file is not recommended." >> /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -F INPUT"                         >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -F OUTPUT"                        >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -F FORWARD"                       >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -t nat -F PREROUTING"             >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -t nat -F OUTPUT"                 >>  /usr/share/goautodial/go_firewall_rule.pl`;     
`echo "/sbin/iptables -t nat -F POSTROUTING"            >>  /usr/share/goautodial/go_firewall_rule.pl`;      
`echo "/sbin/iptables -t mangle -F PREROUTING"          >>  /usr/share/goautodial/go_firewall_rule.pl`;      
`echo "/sbin/iptables -t mangle -F OUTPUT"              >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -F RH-Firewall-1-INPUT"           >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -X"                               >>  /usr/share/goautodial/go_firewall_rule.pl`;      
`echo "/sbin/iptables -P INPUT ACCEPT"                  >>  /usr/share/goautodial/go_firewall_rule.pl`;
`echo "/sbin/iptables -P OUTPUT ACCEPT"                 >>  /usr/share/goautodial/go_firewall_rule.pl`;      
`echo "/sbin/iptables -P FORWARD ACCEPT"                >>  /usr/share/goautodial/go_firewall_rule.pl`;


#### QUERY FIREWALL INTERFACES / CONTENT ####
$stmtA = "SELECT * from go_firewall_interfaces order by interface_id asc;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;
$count=0;
while ($sthArows > $count)
{
        @aryA            = $sthA->fetchrow_array;
        $interface_id    = $aryA[0];
        $interface       = $aryA[1];
        $command         = $aryA[2];
        $type            = $aryA[3];
        $target          = $aryA[4];
        $active          = $aryA[5];
    
# IF
# INTERFACE ne NULL
# COMMAND ne NULL
# TYPE ne NULL
# TARGET ne NULL
# ACTIVE eq Y

if ($interface ne '' && $command ne '' && $type ne '' && $target ne '' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type -i $interface -j $target"         >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }
        
$count++;
}
$sthA->finish(); #finish mysql connection


#### QUERY FIREWALL RULES / CONTENT ####
$stmtA = "SELECT * from go_firewall_rules order by rule_number asc;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;
$count=0;
while ($sthArows > $count)
{
        @aryA            = $sthA->fetchrow_array;
        $rule_id         = $aryA[0];
        $rule_number     = $aryA[1];
        $command         = $aryA[2];
        $type            = $aryA[3];
        $state           = $aryA[4];
        $protocol        = $aryA[5];
        $match_protocol  = $aryA[6];
        $source          = $aryA[7];
        $destination     = $aryA[8];
        $port_from       = $aryA[9];
        $port_to         = $aryA[10];
        $target          = $aryA[11];
        $active          = $aryA[12];
         
if ($protocol eq 'all')
        {
                $protocols = "";
                if (($port_from ne '') || ($port_from > 0))
                        {
                                if (($port_to ne '') || ($port_to > 0))
                                        {        
                                        $port = "-p $port_from:$port_to";
                                        }
                                        else
                                        {
                                        $port = "-p $port_from";        
                                        }
                        }
                        else
                        {
                        $port = "";        
                        }
        }
        else
        {
                $protocols = "-p $protocol";
                if (($port_from ne '') || ($port_from > 0))
                        {
                                if (($port_to ne '') || ($port_to > 0))
                                        {
                                        $port = "--dport $port_from:$port_to";
                                        }
                                        else
                                        {
                                        $port = "--dport $port_from";        
                                        }
                        }
                        else
                        {
                        $port = "";        
                        }
        }
        
if ($match_protocol eq 'N')
        {
                $match_protocols = "";
        }
        else
        {
                $match_protocols = "-m $protocol";        
        }
        
if (($source eq '') || ($source eq '0.0.0.0/0'))
        {
                $sources = "";
        }
        else
        {
                $sources = "-s $source";        
        }
        
if (($destination eq '') || ($destination eq '0.0.0.0/0'))
        {
                $destinations = "";
        }
        else
        {
                $destinations = "-d $destination";        
        }

    
# IF
# STATE = NULL
# MATCH_PROTOCOL = N
# ACTIVE = Y

if ($state eq '' && $match_protocol eq 'N' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type $protocols $sources $destinations $port -j $target"   >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }
        
# IF
# STATE = NULL
# MATCH_PROTOCOL = Y
# ACTIVE = Y

if ($state eq '' && $match_protocol eq 'Y' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type $match_protocols $protocols $sources $destinations $port -j $target"   >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }

# IF
# STATE != NULL
# MATCH_PROTOCOL = N
# ACTIVE = Y

if ($state ne '' && $match_protocol eq 'N' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type -m state --state $state $protocols $sources $destinations $port -j $target"   >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }

# IF
# STATE != NULL
# MATCH_PROTOCOL = Y
# ACTIVE = Y
        
if ($state ne '' && $match_protocol eq 'Y' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type -m state --state $state $match_protocols $protocols $sources $destinations $port -j $target"   >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }
        
$count++;
}
$sthA->finish(); #finish mysql connection


#### QUERY FIREWALL WHITELIST / CONTENT ####
$stmtA = "SELECT * from go_firewall_whitelist order by white_id asc;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;
$count=0;
while ($sthArows > $count)
{
        @aryA            = $sthA->fetchrow_array;
        $white_id        = $aryA[0];
        $command         = $aryA[1];
        $type            = $aryA[2];
        $source          = $aryA[3];
        $target          = $aryA[4];
        $active          = $aryA[5];
    
# IF
# COMMAND ne NULL
# TYPE ne NULL
# SOURCE ne NULL
# TARGET ne NULL
# ACTIVE eq Y

if ($command ne '' && $type ne '' && $source ne '' &&  $target ne '' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type -s $source -j $target"         >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }
        
$count++;
}
$sthA->finish(); #finish mysql connection


#### LOG WARNING
#### `echo "/sbin/iptables -A INPUT -i eth0 -m limit --limit 2/sec -j LOG --log-level 7"    >>  /usr/share/goautodial/go_firewall_rule.pl`;
#### `echo "/sbin/iptables -A OUTPUT -m limit --limit 2/sec -j LOG --log-level 4"    >>  /usr/share/goautodial/go_firewall_rule.pl`;

#### QUERY FIREWALL BLOCKLIST / CONTENT ####
$stmtA = "SELECT * from go_firewall_blocklist order by block_id asc;";
$sthA = $dbh->prepare($stmtA) or die "preparing: ",$dbh->errstr;
$sthA->execute or die "executing: $stmtA ", $dbh->errstr;
$sthArows=$sthA->rows;
$count=0;
while ($sthArows > $count)
{
        @aryA            = $sthA->fetchrow_array;
        $block_id        = $aryA[0];
        $command         = $aryA[1];
        $type            = $aryA[2];
        $source          = $aryA[3];
        $target          = $aryA[4];
        $active          = $aryA[5];
    
# IF
# COMMAND ne NULL
# TYPE ne NULL
# SOURCE ne NULL
# TARGET ne NULL
# ACTIVE eq Y

if ($command ne '' && $type ne '' && $source ne '' &&  $target ne '' && $active eq 'Y')
        {
                `echo "/sbin/iptables $command $type -s $source -j $target"         >>  /usr/share/goautodial/go_firewall_rule.pl`;
        }

$count++;
}
$sthA->finish(); #finish mysql connection

#### ACCEPT STATE 
`echo "/sbin/iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT"  >>  /usr/share/goautodial/go_firewall_rule.pl`;

#### DROP UDP
`echo "/sbin/iptables -A INPUT -p udp -j DROP"                                  >>  /usr/share/goautodial/go_firewall_rule.pl`;

#### DROP SYN
`echo "/sbin/iptables -A INPUT -p tcp --syn -j DROP"                            >>  /usr/share/goautodial/go_firewall_rule.pl`;

#### ENABLE ICMP
`echo "/sbin/iptables -A INPUT -p icmp --icmp-type any -j ACCEPT"               >>  /usr/share/goautodial/go_firewall_rule.pl`;

#### REJECT ICMP
`echo "/sbin/iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited"    >>  /usr/share/goautodial/go_firewall_rule.pl`;

### RUN THE GENERATED IPTABLES SCRIPT
`/usr/share/goautodial/go_firewall_rule.pl`;

### SAVE IPTABLES
`/usr/share/goautodial/goautodialc.pl "/etc/init.d/iptables save"`;

### RESTART IPTABLES
`/usr/share/goautodial/goautodialc.pl "/etc/init.d/iptables restart"`;
