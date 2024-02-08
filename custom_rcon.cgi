#!/usr/bin/perl
# custom_rcon.cgi
# Webinterface for rcon terminal

require "./paldmin-ui-lib.pl";
require "./paldmin-lib.pl";
require "./rcon-lib.pl";

init_rcon();

ReadParse();

ui_print_unbuffered_header($text{"glop_rcon"}, $text{"index_title"}, "");

if (defined $rcon{"msg"}{"content"}) {
	alert_box($rcon{"msg"}{"type"}, "", $rcon{"msg"}{"content"});
	ui_print_footer("", $text{"index_return"});
	exit;
} elsif (!foreign_installed("proc")) {
	alert_box($rcon{"msg"}{"type"}, "", $text{"custom_missing_proc"});
	ui_print_footer("", $text{"index_return"});
	exit;
} elsif (!$rcon{"valid"}) {
	ui_print_footer("", $text{"index_return"});
	exit;
}

collapsible_box("info", $text{"info"}, $text{"custom_info"});

# Command Block
print ui_subheading($text{"glop_rcon_cc"});
print ui_form_start("custom_rcon.cgi");
print ui_textbox("cmd", $cmd, 40, (!$rcon{"valid"}));
print ui_submit($text{"send"}, "submit", (!$rcon{"valid"}));
print ui_form_end();
print "<br/>";

print "<pre>";
if (%in{"cmd"}) {
	print "Command: ".$in{"cmd"}."<br/><br/>";
	my ($ok, $exec, $output) = rcon_command($in{"cmd"});
	print "$output";
}
print "</pre>";

ui_print_footer("", $text{"index_return"});

1;