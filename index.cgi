#!/usr/bin/perl
# index.cgi
# Show Palworld Server Configuration

require 'paldmin-lib.pl';

my $module_name = get_module_name();
my $module_info = get_module_info($module_name);
my $module_version = $module_info{'version'};

ui_print_header(text('index_subtitle', $module_version), $text{'index_title'}, "", "intro", 1, 1);

# Validate the base config of the module
my ($ety, $eti, $ec) = validate_config();
if (defined $ety) {
	display_box($ety, $eti, $ec);
	ui_print_footer("/", $text{"index"});
	exit;
}

# Validate palserver directory and savegame
my ($wty, $wti, $wc) = validate_savegame();
if (defined $wty) {
	display_box($wty, $wti, $wc);
	ui_print_footer("/", $text{"index"});
	exit;
}

my $running = is_server_running();

# Basic Info
print ui_table_start($text{'index_basic'}, undef, 2);
print ui_table_row($text{'basic_state_title'}, $running ? $text{'online'} : $text{'offline'});
if ($running) {
	print ui_table_row($text{'basic_upsince_title'}, up_since());
}
print ui_table_end();
print ui_hr();

# Icon Table
print ui_subheading($text{'index_glop'});

my @links = ( 'edit_ws.cgi', 'edit_config.cgi' );
my @titles = ( $text{'glop_ws'}, $text{'glop_config'} );
my @images = ( 'images/glop_ws.png', 'images/glop_config.png' );

icons_table(\@links, \@titles, \@images, 5);

print ui_hr();

# Footer
print ui_buttons_start();
if ($running > 0) {
	print ui_buttons_row("restart.cgi", $text{'index_restart'}, $text{'index_restartmsg'});
	print ui_buttons_row("stop.cgi", $text{'index_stop'}, $text{'index_stopmsg'});
} else {
	print ui_buttons_row("start.cgi", $text{'index_start'}, $text{'index_startmsg'});
}
print ui_buttons_end();

1;
