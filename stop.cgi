#!/usr/bin/perl
# stop.cgi
# Stop the PalServer daemon
use strict;
use warnings;
no warnings 'redefine';
no warnings 'uninitialized';

require './paldmin-lib.pl';

our (%text);
ReadParse();
error_setup($text{'stop_err'});
my $err = stop_server();
error($err) if ($err);
webmin_log("stop");
redirect("");
