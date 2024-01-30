#!/usr/bin/perl
# stop.cgi
# Stop the PalServer daemon
use strict;
use warnings;
no warnings 'redefine';
no warnings 'uninitialized';

require './paldmin-lib.pl';

ReadParse();
error_setup($text{'stop_err'});
$err = stop_server();
error($err) if ($err);
webmin_log("stop");
redirect("");
