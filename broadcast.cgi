#!/usr/bin/perl
# broadcast.cgi
# Broadcasts a message

require "./paldmin-lib.pl";
require "./rcon-lib.pl";

ReadParse();
error_setup($text{"error"});
my $msg = %in{"msg"};
my ($ok, $exec, $output) = broadcast($msg);
if (!$ok) {
	error("<tt>".text("rcon_command_failed", $exec, $output)."</tt>");
}
redirect("");