#!/usr/bin/perl
# uninstall.pl
# Performs uninstall stuff

require 'paldmin-lib.pl'; 

=head1 Uninstall

=cut

=head2 module_uninstall ()
Performs a cleanup:
	1. Removes possible cronjob
	2. Deletes the config file
=cut
sub module_uninstall  {
	# Check if CRON needs to be deleted
	my $cron = foreign_installed("cron");
	if ($cron) {
		my $cmd = "$module_config_directory/cron_restart.pl";
		@jobs = cron::list_cron_jobs();
		($job) = grep { $_->{'command'} eq $cmd } @jobs;
		if ($job) {
			cron::delete_cron_job($job);
		}
	}

	# Delete config file
	if (-r "$config{'paldmin_config'}") {
		unlink_file($config{'paldmin_config'});
    }
}