#!/usr/bin/perl
############################################################################################
####  Name:             g_parser.pl                                                     ####
####  Version:          2.0                                                             ####
####  Copyright:        GOAutoDial Inc. - Januarius Manipol <januarius@goautodial.com>  ####
####  License:          AGPLv2                                                          ####
############################################################################################

$fname = $ARGV[0];

open(DAT, $fname) || die("Cannot Open File");
@raw_data=<DAT>;
close(DAT);

open(DAT, ">:", "$fname") || die("Cannot Open File");
chomp;
print DAT @raw_data;
close(DAT); 

#system("sudo -u root chmod 777 $fname");
#system("sudo -u root /usr/bin/dos2unix $fname"); 
system("/bin/chmod 777 $fname");
system("/usr/bin/dos2unix $fname"); 
exit();
