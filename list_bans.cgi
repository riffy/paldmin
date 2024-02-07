#!/usr/bin/perl
# list_bans.cgi
# Lists all active banned players

require "./paldmin-lib.pl";
require "./rcon-lib.pl";
require "./paldmin-ui-lib.pl";

ui_print_header($text{"glop_banlist"}, $text{"index_title"}, "");
alert_box_with_collapsible("info", $text{"change_restart_required"}, $text{"banlist_info"});

# Banlist Table

my @bannedPlayers = get_banned_steamids();
print ui_form_start("edit_banlist.cgi", "post");
print ui_table_start($text{"glop_banlist"}.": ".scalar(@bannedPlayers), undef, 2);
print ui_columns_start(["", "SteamID"]);
for my $bp (@bannedPlayers) {
	print ui_checked_columns_row([$bp], undef, "rem_steamid", "steam_".$bp);
}
print ui_table_end();
print $text{"banlist_new_ban"}.": <br/>";
print "steam_".ui_textbox("add_steamid", "00000000000000000");
print ui_form_end([["add", $text{"add"}], [ "remove", $text{"banlist_unban"} ]]);

print ui_hr();

ui_print_footer("", $text{"index_return"});