#!/usr/bin/perl
# start.cgi
# Start the PalServer daemon

use strict;
use warnings;
no warnings 'redefine';
no warnings 'uninitialized';

require './paldmin-lib.pl';

ReadParse();
error_setup($text{'start_err'});
my $err = start_server();
error($err) if ($err);
webmin_log("start");
redirect("");