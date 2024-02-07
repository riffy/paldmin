#!/usr/bin/perl
# edit_banlist.cgi
# Adds or removes an entry from the banlist

require "./paldmin-lib.pl";

ReadParse();

if ($in{"remove"}) {
	error_setup($text{"banlist_eremove"});
	# Get all steam ids to remove
	my @ids = split /steam_/,$in{"rem_steamid"};
	shift @ids;
	if (scalar(@ids) <= 0) {
		error("<tt>".$text{"banlist_eremove_nosteamid"}."</tt>");
	}
	@ids = map { "steam_" . $_ } @ids;
	my $err = remove_steamids_from_banlist(\@ids);
	if (defined $err) {
		error("<tt>".$err."</tt>");
	}
}
else {
	error_setup($text{"banlist_eadd"});
	my $new = $in{"add_steamid"};
	if (!$new || length($new) <= 0) {
		error("<tt>".$text{"banlist_eadd_missid"}."</tt>");
	}
	my @exist = get_banned_steamids();
	my $idx = indexof($new, @exist);
	if ($idx > 0) {
		error("<tt>".$text{"banlist_eadd_duplicate"}."</tt>");
	}

	my $err = add_steamid_to_banlist("steam_".$new);
	if (defined $err) {
		error("<tt>".$err."</tt>");
	}
}
redirect("list_bans.cgi");