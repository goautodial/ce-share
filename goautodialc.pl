#!/usr/bin/perl
############################################################################################
####  Name:             goautodialc.pl                                                  ####
####  Version:          2.0                                                             ####
####  Copyright:        GOAutoDial Inc. - Januarius Manipol <januarius@goautodial.com>  ####
####  License:          AGPLv2                                                          ####
############################################################################################

$PATHconf = '/etc/goautodial.conf';

open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
	{
	$line = $conf[$i];
	$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
	if ($line =~ /^VARSERVHOST/)	{$VARSERVHOST = $line;   	$VARSERVHOST =~ s/.*=//gi;}
	if ($line =~ /^VARSERVPORT/)	{$VARSERVPORT = $line;   	$VARSERVPORT =~ s/.*=//gi;}
	if ($line =~ /^VARSERVLISTEN/)	{$VARSERVLISTEN = $line;   	$VARSERVLISTEN =~ s/.*=//gi;}
	$i++;
	}

use IO::Socket;

$cmd_req = $ARGV[0];
#$cmd_type= $ARGV[1];
#$cmd_net = $ARGV[2];

eval 
	{
		local $SIG{ALRM} = sub { die 'Timed Out'; };
		alarm 3;
		my $sock = IO::Socket::INET->new( PF_INET,
		                                  SOCK_STREAM,
		                                  PeerAddr => $VARSERVHOST,
		                                  PeerPort => $VARSERVPORT,
		                                  Timeout => "3600",
		                                  Proto => 'tcp',); die "Could not create socket: $!\n" unless $sock;
		#print "Connection established on host: ", $sock->peerhost, " port: ", $sock->peerport, "\n";
		$sock->autoflush;
		print $sock "$cmd_req\n";
		#$sock->send($data);
		#my $res = <$sock>;
		$sock->recv($res,10240);
		#print "<br>Request results: $res\n";
		print $res;
		close($sock);
		undef $/; $data = <$sock>; $/ = "\n";
		alarm 0;
	};
alarm 0; # race condition protection
#return "Error: timeout." if ( $@ && $@ =~ /Timed Out/ );
#return "Error: Eval corrupted: $@" if $@;
