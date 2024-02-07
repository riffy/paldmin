#!/usr/bin/perl
# atboot.cgi
# Enable the Palworld Server at boot, or not

require "./paldmin-lib.pl";
ReadParse();

error_setup($text{"atboot_e"});
foreign_require("init");
my $starting = init::action_status($config{"systemctl"});
if ($starting != 2 && $in{"boot"}) {
	# Enable at boot
	init::enable_at_boot($config{"systemctl"});
} elsif ($starting == 2 && !$in{"boot"}) {
	# Disable at boot
	init::disable_at_boot($config{"systemctl"});
}

redirect("");

