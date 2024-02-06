#!/usr/bin/perl
# index.cgi
# Show Palworld Server Configuration

require "./paldmin-ui-lib.pl";
require "./paldmin-lib.pl";
require "./rcon-lib.pl";

my $module_name = get_module_name();
my $module_info = get_module_info($module_name);
my $module_version = $module_info{"version"};

ui_print_header(text("index_subtitle", $module_version), $text{"index_title"}, "", "intro", 1, 1);

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

# TODO: Improve this by calling init:: in lib ?
my %service = get_service_status();

my $running = $service{"state"} eq "active";
my $rcon_ok = 0;

# Basic Info
print ui_table_start($text{"index_service_info"}, undef, 2);
print ui_table_row($text{"state"}, $service{"state"});
if ($running) {
	print ui_table_row($text{"index_service_upsince_title"}, (!defined $service{"upsince"}) ? "?" : $service{"upsince"});
	print ui_table_row($text{"basic_ram_usage"}, (!defined $service{"memory"}) ? "?" : $service{"memory"});
}
print ui_table_end();
print ui_hr();

# RCON Info
print ui_table_start($text{"index_rcon_title"}, undef, 2);

if (defined $rcon{"msg"}{"content"}) {
	alert_box($rcon{"msg"}{"type"}, "", $rcon{"msg"}{"content"});
}

if ($rcon{"valid"}) {
	my %rcon_info = get_rcon_info_index();
	if (defined $rcon_info{"error"}) {
		$rcon_ok = 0;
		alert_box("error", "", $rcon_info{"error"});
	} else {
		$rcon_ok = 1;
		my $slots = get_setting("ServerPlayerMaxNum");
		print ui_table_row($text{"state"}, $rcon_ok ? $text{"ok"} : $text{"nok"});
		print ui_table_row($text{"basic_players"}, "".$rcon_info{"active"}."/".$slots);
		print ui_table_row($text{"info"}, $rcon_info{"info"});
	}	
}

print ui_table_end();
print ui_hr();

# Broadcast Form
print ui_subheading("Broadcast Message");
print ui_form_start("broadcast.cgi");
print ui_textbox("msg", undef, 40, (!$rcon_ok));
print ui_submit("Send", "submit", (!$rcon_ok));
print $text{"index_broadcast_desc"};
print ui_form_end();

# Icon Table
print ui_subheading($text{"index_glop"});

my @links = ( "edit_ws.cgi", "edit_config.cgi");
my @titles = ( $text{"glop_ws"}, $text{"glop_config"} );
my @images = ( "images/glop_ws.png", "images/glop_config.png" );

if ($rcon_ok) {
	push(@links, ( "list_players.cgi", "custom_rcon.cgi"));
	push(@titles, ( $text{"glop_playerlist"}, $text{"glop_rcon"} ));
	push(@images, ( "images/glop_users.png", "images/glop_rcon.png" ));
}


push(@links, ( "list_bans.cgi", "scheduler.cgi" ));
push(@titles, ( $text{"glop_banlist"}, $text{"glop_scheduler"}));
push(@images, ( "images/glop_banlist.png", "images/glop_scheduler.png" ));

icons_table(\@links, \@titles, \@images, 5);

print ui_hr();

# Footer
print ui_buttons_start();
if ($running > 0) {
	print ui_buttons_row("restart.cgi", $text{"index_restart"}, $text{"index_restartmsg"});
	print ui_buttons_row("stop.cgi", $text{"index_stop"}, $text{"index_stopmsg"});
} else {
	print ui_buttons_row("start.cgi", $text{"index_start"}, $text{"index_startmsg"});
}

# TODO: Use foreign_require("init") to safely check for start at boot
#foreign_require("init");
#my $st = &init::action_status( $config{"systemctl"}); <- State goes here

print ui_buttons_row(
	"atboot.cgi",
	$text{"index_atboot"},
	$text{"index_atbootdesc"},
	undef,
	ui_radio("boot", $service{"atboot"} eq "enabled" ? 1 : 0,
			[ [ 1, $text{"yes"} ], [ 0, $text{"no"} ] ]));
print ui_buttons_end();

1;
