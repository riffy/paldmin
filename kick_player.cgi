#!/usr/bin/perl
# kick_player.cgi
# Kicks a Player

require './paldmin-lib.pl';
require './rcon-lib.pl';

ReadParse();
error_setup($text{'error'});
my $steamid = %in{'steamid'};
my ($ok, $exec, $output) = kick_player($steamid);
if (!$ok) {
	error("<tt>".text('rcon_command_failed', $exec, $output)."</tt>");
}
redirect("");