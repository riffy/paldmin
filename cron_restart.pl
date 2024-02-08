#!/usr/bin/perl
# cron_restart.pl
# Called by cron to restart the server
# If called with announce on, restart is delay and broadcast messages are sent
# if RCON is valid and enabled

$no_acl_check++;
require "./paldmin-lib.pl";
require "./rcon-lib.pl";

init_service();
init_rcon();

if ($config{'scheduler_announce'} != 1) {
	print STDOUT "Skipping announcement: Announcement not set.\n";
	goto RESTART;
}
if (!is_server_running()) {
	print STDOUT "Skipping announcement: Server not running.\n";
	goto RESTART;
}
if (!$rcon{"valid"}) {
	print STDOUT "Skipping announcement: RCON Setup is no valid:\n";
	print STDOUT $rcon{"msg"}{"content"}."\n";
	goto RESTART;
}

my ($ok, $exec, $output) = broadcast("Scheduled Restart in 15min...");
if (!$ok) {
	print STDOUT "Skipping announcement: Failed to make announcement #1.\n";
	goto RESTART;
}
sleep(5 * 60);

($ok, $exec, $output) = broadcast("Scheduled Restart in 10min...");
if (!$ok) {
	print STDOUT "Skipping announcement: Failed to make announcement #2.\n";
	goto RESTART;
}
sleep(5 * 60);

($ok, $exec, $output) = broadcast("Scheduled Restart in 5min...");
if (!$ok) {
	print STDOUT "Skipping announcement: Failed to make announcement #3.\n";
	goto RESTART;
}
sleep(4 * 60);

($ok, $exec, $output) = broadcast("Scheduled Restart in 1min...");
if (!$ok) {
	print STDOUT "Skipping announcement: Failed to make announcement #4.\n";
	goto RESTART;
}
sleep(60);


RESTART:
print STDOUT "Restarting server...";
restart_server();

exit(0);