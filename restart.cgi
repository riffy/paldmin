#!/usr/bin/perl
# Restart the Palword Server

use strict;
use warnings;
no warnings 'redefine';
no warnings 'uninitialized';

require './paldmin-lib.pl';

our (%text);
error_setup($text{'restart_err'});
my $err = restart_server();
error("<tt>".html_escape($err)."</tt>") if ($err);
webmin_log("restart");
redirect("");