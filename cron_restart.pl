#!/usr/bin/perl
# cron_restart.pl
# Called by cron to restart the server
# If called with announce on, restart is delay and broadcast messages are sent
# if RCON is valid and enabled

$no_acl_check++;
require "./paldmin-lib.pl";
require "./rcon-lib.pl";

my $rcon_validation = validate_rcon();
my $rcon_valid = (!defined $rcon_validation);

# Check for rcon and if server is running
if (is_server_running() && $rcon_valid && $config{'scheduler_announce'} == 1) {
	my ($ok, $exec, $output) = broadcast("Scheduled Restart in 15min...");
	if (!$ok) {
		# Announcement failed, do the restart
		goto RESTART;
	}
	sleep(5 * 60);
	($ok, $exec, $output) = broadcast("Scheduled Restart in 10min...");
	if (!$ok) {
		# Announcement failed, do the restart
		goto RESTART;
	}
	sleep (5 * 60);
	($ok, $exec, $output) = broadcast("Scheduled Restart in 5min...");
	if (!$ok) {
		# Announcement failed, do the restart
		goto RESTART;
	}
	sleep (4 * 60);
	($ok, $exec, $output) = broadcast("Scheduled Restart in 1min...");
	if (!$ok) {
		# Announcement failed, do the restart
		goto RESTART;
	}
	sleep (60);
}

RESTART:
restart_server();

exit(0);