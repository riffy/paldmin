#!/usr/bin/perl
# list_players.cgi
# Lists all active players

require './paldmin-lib.pl';
require 'rcon-lib.pl';

ui_print_header($text{'glop_playerlist'}, $text{'index_title'}, "");

my @activePlayers = get_active_players();
my $slots = get_setting("ServerPlayerMaxNum");

print "<bold>Note: Players with UID 00000000 are connecting or in character creation</bold></br>";

print ui_table_start($text{'basic_players'}.": ".scalar(@activePlayers)."/".$slots, undef, 3);
print ui_columns_start(['Name', 'Player UID', 'SteamID', 'Control']);
for my $ap (@activePlayers) {
	print ui_columns_row([
		$ap->{'name'},
		$ap->{'playeruid'},
		$ap->{'steamid'},
		ui_link("kick_player.cgi?steamid=".$ap->{'steamid'}, "Kick") . " / " . ui_link("ban_player.cgi?steamid=".$ap->{'steamid'}, "Ban")
	]);
}
print ui_columns_end();
print ui_table_end();


ui_print_footer("", $text{'index_return'});