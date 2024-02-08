#!/usr/bin/perl
# start.cgi
# Start the PalServer daemon

require "./paldmin-lib.pl";
init_service();

ReadParse();
error_setup($text{"start_err"});
my $err = start_server();
error($err) if ($err);
webmin_log("start");
redirect("");