#!/usr/bin/perl
# stop.cgi
# Stop the PalServer daemon

require "./paldmin-lib.pl";

ReadParse();
error_setup($text{"stop_err"});
my $err = stop_server();
error($err) if ($err);
webmin_log("stop");
redirect("");
