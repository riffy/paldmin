#!/usr/bin/perl
# reset_ws.cgi
# Resets the existing palworld settings

require "./paldmin-lib.pl";
require "./paldmin-ui-lib.pl";

ui_print_header($text{"glop_reset_world"}, $text{"index_title"}, "", "intro", 1, 1);

my ($efile, $ini) = get_saveconfig_validation();
my %def = get_default_world_settings();
if (!%def || !keys %def) {
	alert_box_with_collapsible(
		"error",
		$text{"glop_ws_e"},
		$text{"glop_ws_eread"}
	);
} elsif ($efile > 0) {
	alert_box_with_collapsible(
		"error",
		$text{"glop_ws_e"},
		text("index_wsave_conf", $ini)
	);
} else {
	# Construct the contents of the ini file
	my $total_keys = scalar(keys %def);
	my $current_key_count = 0;
	my @c = ("[/Script/Pal.PalGameWorldSettings]");
	my $option_settings = "OptionSettings=(";
	for my $key (keys %def) {
		$current_key_count++;
		$option_settings .= $key."=".%def{$key};
		# Append a comma if it"s not the last key
    	$option_settings .= "," unless $current_key_count == $total_keys;
	}
	$option_settings .= ")";
	push(@c, $option_settings);

	# Delete the old ini file
	unlink_file($ini);

	# Write content array to file
	open_tempfile(CONF, ">$ini");
	for my $line (@c) {
		print_tempfile(CONF, $line."\n");
	}
	close_tempfile(CONF);

	webmin_log("reset_ws");
	alert_box_with_collapsible("success", $text{"glop_ws_header"}, text("glop_ws_reset_succ", $ini).$text{"change_restart_required"});
}

ui_print_footer("", $text{"index_return"});

1;