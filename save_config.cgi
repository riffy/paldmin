#!/usr/bin/perl
# save_config.cgi
# Save a manually edited config file

require './paldmin-lib.pl';
ReadParseMime();
error_setup($text{'glop_config_err'});

# Validate the filename, it must exist before
my ($esd, $sd) = get_savedir_validation();
if ($esd > 0) {
	error($text{'glop_config_efile'});
} else {
	my $dir = "$sd/Config/LinuxServer";
	my @files = get_files_in_dir($dir);
	$in{'config'} ||= $files[0];
	&indexof($in{'config'}, @files) >= 0 ||
		&error($text{'glop_config_efile'});
	
	# Full path to config file
	my $file = "$dir/$in{'config'}";

	$in{'data'} =~ s/\r//g;
	open_lock_tempfile(CONFIG, ">$file");
	print_tempfile(CONFIG, $in{'data'});
	close_tempfile(CONFIG);

	webmin_log("glop_config");
	redirect("");
}
