#!/usr/bin/perl
# Restart the Palword Server

require "./paldmin-lib.pl";

ReadParse();
error_setup($text{"restart_err"});
my $err = restart_server();
error("<tt>".html_escape($err)."</tt>") if ($err);
webmin_log("restart");
redirect("");