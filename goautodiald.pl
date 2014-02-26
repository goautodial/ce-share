#!/usr/bin/perl
############################################################################################
####  Name:             goautodiald.pl                                                  ####
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
	if ($line =~ /^VARSERVLOGGING/)	{$VARSERVLOGGING = $line;   $VARSERVLOGGING =~ s/.*=//gi;}
	if ($line =~ /^VARSERVLOGS/)	{$VARSERVLOGS = $line;   	$VARSERVLOGS =~ s/.*=//gi;}
	$i++;
	}
	
#use strict;
#use Time::HiRes ('gettimeofday','usleep','sleep');
#use MIME::Base64
use warnings;
use Proc::Daemon;
use Proc::PID::File;
use IO::Socket;
use Net::Address::IP::Local;	
	
MAIN:
{
if (Proc::PID::File->running())
        {
                exit(0);
        }
        my $server = IO::Socket::INET->new(
                        LocalHost => $VARSERVHOST,
                        LocalPort => $VARSERVPORT,
                        Proto => 'tcp',
                        Type => SOCK_STREAM,
                        Listen => $VARSERVLISTEN,
                        Reuse => 1);
       
        if ($VARSERVLOGGING =~ /Y/)
        	{
	        	&get_time_now;
            	open (F,"+>>$VARSERVLOGS/goautodiald.log");
               	printf  F "$now_date : GoAutoDial Server Started...\n";
				close("$VARSERVLOGS/goautodiald.log");
				close F;
			}
		                        
        $server or die "no socket :$!";
        
for (;;) 
        {          	        
			while()
			    {   
			        my $new_sock = $server->accept();
			        $new_sock->autoflush(1);
        			
			        if ($VARSERVLOGGING =~ /Y/)
        			{
	        		&get_time_now;
	        		open (F,"+>>$VARSERVLOGS/goautodiald.log");			     
   			        printf  F "\n$now_date : Starting GoAutoDial client connection...\n";
			        print  F "    Socket connection established on Host: ", $new_sock->peerhost(), " | Port: ", $new_sock->peerport(), "\n";
			        close("$VARSERVLOGS/goautodiald.log");
		       		}
		       		
			        my $result;
			       
			        while(defined($Line = <$new_sock>))
			            {
				            if ($VARSERVLOGGING =~ /Y/)
        					{
			                open (F,"+>>$VARSERVLOGS/goautodiald.log");
			                print F "    Command request: ", $Line;
			                close("$VARSERVLOGS/goautodiald.log");
							}
							 
							if ($Line =~ m/nohup/i)
        					{
	        				#system($Line);
			                $data= `$Line`;	 
			                	if ($VARSERVLOGGING =~ /Y/)
        							{
	        							open (F,"+>$VARSERVLOGS/nohup.log");
			                			print F $data;
			                			close("$VARSERVLOGS/nohup.log");
		                			}
		               		}
		               		else
		               		{
			               	#system($Line);
			                $data= `$Line`;
		                	}	 
							
		                	if ($VARSERVLOGGING =~ /Y/)
        					{
			                open (F,"+>>$VARSERVLOGS/goautodiald.log");
			                print F "    Request Status:    ", $data."\r";
			                close("$VARSERVLOGS/goautodiald.log");
		               		}
			                
		               		my $send = $data;
			                print $new_sock $send;
		                	
			                if ($VARSERVLOGGING =~ /Y/)
        					{			               
	        				&get_time_now; 
			                open (F,"+>>$VARSERVLOGS/goautodiald.log");
			                printf  F "$now_date : Exiting GoAutoDial client connection...\n";
			                close("$VARSERVLOGS/goautodiald.log");                             
			                close F;
		                	}
			            }
			        close($new_sock);
			    }
        }
}

sub get_time_now
{
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = ($year + 1900);
$mon++;
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}
if ($hour < 10) {$hour = "0$hour";}
if ($min < 10) {$min = "0$min";}
if ($sec < 10) {$sec = "0$sec";}
$now_date = "$year-$mon-$mday $hour:$min:$sec";
}
