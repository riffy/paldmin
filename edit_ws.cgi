#!/usr/bin/perl
# edit_ws.cgi
# Show and edit Palworld Server config

require 'paldmin-lib.pl';

my $module_name = get_module_name();
my $module_info = get_module_info($module_name);
my $module_version = $module_info{'version'};

ui_print_header($text{'glop_ws'}, $text{'index_title'}, "", "intro", 1, 1);
display_box('info', $text{'glop_ws_info'}, $text{'glop_ws_info_desc'}.$text{'change_restart_required'});

# Validate palserver directory and savegame
my %world_settings = get_world_settings();
if (!%world_settings || !keys %world_settings) {
	display_box('error', $text{'glop_ws_e'}, $text{'glop_ws_eread'});
} else {
	# World Settings Edit
	print ui_form_start("save_ws.cgi", "post");
	print ui_table_start($text{'glop_ws_header'}, "width=100%", 2);

	# Sort keys alphabetically
	my @sorted_keys = sort keys %world_settings;
	foreach my $key (@sorted_keys) {
		# RCONenabled doesn't start with lowercase b
		if ($key =~ /^b/ || $key eq "RCONEnabled") {
			print ui_table_row($key, ui_yesno_radio($key, $world_settings{$key}, "True", "False"));
		} else {
			print ui_table_row($key, ui_textbox($key, $world_settings{$key}, 50));
		}
	}

	print ui_table_end();
	print ui_form_end([["save", $text{'save'}]]);

	# World Settings Reset
	print ui_buttons_row('reset_ws.cgi/?xnavigation=1', $text{'reset_to_default'}, $text{'glop_ws_reset_desc'});
}

ui_print_footer("", $text{'index_return'});

1;