#!/usr/bin/perl
# schedule_restart.cgi
# Apply the scheduled restart

require './paldmin-lib.pl';
ReadParse();
ui_print_header(undef, $text{'scheduler_schedule'}, "");
error_setup($text{'scheduler_err'});

# Update the cron job
$cron = foreign_installed("cron");
if (!$cron) {
	error($text{'scheduler_ecron_missing'});
}
foreign_require("cron");

# Retrieve the job and overwrite values, or create new
@jobs = cron::list_cron_jobs();
my $cmd = "$module_config_directory/cron_restart.pl";
($job) = grep { $_->{'command'} eq $cmd } @jobs;
$oldjob = $job;
$job ||= { 'command' => $cmd,
		   'user' => 'root',
		   'active' => 1 };
cron::parse_times_input($job, \%in);

# Create a wrapper for the cron_restart.pl file
lock_file($cmd);
cron::create_wrapper($cmd, $module_name, "cron_restart.pl");
unlock_file($cmd);

# Lock the cron file and create entry into it or delete old entry
lock_file(cron::cron_file($job));
my $what = "";
if ($in{'sched'} && !$oldjob) {
	# Need to create cron job
	cron::create_cron_job($job);
	$what = "scheduler_ccron";
} elsif (!$in{'sched'} && $oldjob) {
	# Need to delete cron job
	cron::delete_cron_job($job);
	$what = "scheduler_dcron";
} elsif ($in{'sched'} && $oldjob) {
	# Need to update cron job
	cron::change_cron_job($job);
	$what = "scheduler_ucron";
} else {
	# Nothing really changed (stayed disabled)
	$what = "scheduler_ncron";
}
unlock_file(cron::cron_file($job));

# Update the announcement
$config{'scheduler_announce'} = (%in{'scheduler_announce'} == 1 ? 1 : 0);
my $what_ann = ($config{'scheduler_announce'} == 1) ? "yes" : "no";
save_module_config();

display_box(
	($what eq 'scheduler_ncron') ? 'info' : 'success', 
	$text{'scheduler_upd'},
	$text{$what}."<br/>".text('scheduler_ann_result', $text{$what_ann})
);

ui_print_footer("", $text{'index_return'});

