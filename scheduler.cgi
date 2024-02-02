#!/usr/bin/perl
# restart_scheduler.cgi
# Page for configuring restart scheduler

require './paldmin-lib.pl';

ui_print_header($text{'glop_scheduler'}, $text{'index_title'}, "");

# Check if cron is installed
my $cron = foreign_installed("cron");
if (!$cron) {
	print ui_alert_box($text{'scheduler_ecron_missing'}, 'danger');
	ui_print_footer("", $text{'index_return'});
	exit;
}

# Check if the source file is executable
my $fcmd = "$module_root_directory/cron_restart.pl";
if ((!-x $fcmd)) {
	print ui_alert_box("<br/>".text('scheduler_ecron_exe', $fcmd), 'danger');
	ui_print_footer("", $text{'index_return'});
	exit;
}

print ui_form_start("schedule_restart.cgi", "post");
# CRON Schedule
print ui_hidden_table_start($text{'scheduler_schedule'}, "width=100%", 2, "sched", 1, [ "width=30%" ]);
foreign_require("cron", "cron-lib.pl");
my $cmd = "$module_config_directory/cron_restart.pl";
@jobs = cron::list_cron_jobs();
($job) = grep { $_->{'command'} eq $cmd } @jobs;

print ui_table_row(
	$text{'scheduler_sched'},
	ui_radio("sched", $job ? 1 : 0, [ [ 0, $text{'no'} ], [ 1, $text{'scheduler_sched1'} ] ])
	);

$job ||= { 'mins' => 0,
		'hours' => 0,
		'days' => '*',
		'months' => '*',
		'weekdays' => '*' };
print cron::get_times_input($job);

print ui_hidden_table_end("sched");

# Restart Options
print ui_hidden_table_start($text{'scheduler_announce'}, "width=100%", 2, "announce", 1, [ "width=30%" ]);

print "</br>".$text{'scheduler_announce_note'}."</br>"."</br>";

my $rcon_validation = validate_rcon();
my $rcon_valid = (!defined $rcon_validation);
if (!$rcon_valid) {
	print ui_alert_box("<br/>". $rcon_validation . "<br/>" . $text{'index_features_disabled'}, 'warn');
	print "<br/>";
}
print ui_table_row(
	$text{'scheduler_ann'},
	ui_radio("scheduler_announce", ($rcon_valid && $config{'scheduler_announce'} == 1) ? 1 : 0, [ [ 0, $text{'no'} ], [ 1, $text{'yes'} ] ], ($rcon_valid) ? 0 : 1)
);

print ui_hidden_table_end("announce");


print ui_form_end([[ "save", $text{'save'} ]]);

ui_print_footer("", $text{'index_return'});