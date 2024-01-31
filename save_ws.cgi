#!/usr/bin/perl
# save_ws.cgi
# Save the given Palworld Settings by POST

require './paldmin-lib.pl';

error_setup($text{'glop_ws_esave_title'});
ReadParse();
my ($efile, $ini) = get_saveconfig_validation();
if ($efile > 0) {
	error(text('index_wsave_conf', $ini));
} else {
	# Remove the "save" post
	delete $in{'save'};

	# Construct the contents of the ini file
	my $total_keys = scalar(keys %in);
	my $current_key_count = 0;
	my @c = ("[/Script/Pal.PalGameWorldSettings]");
	my $option_settings = "OptionSettings=(";
	for my $key (keys %in) {
		$current_key_count++;
		$option_settings .= $key."=".%in{$key};
		# Append a comma if it's not the last key
    	$option_settings .= "," unless $current_key_count == $total_keys;
	}
	$option_settings .= ")";
	push(@c, $option_settings);

	# Delete the old ini file
	unlink_file($ini);

	# Write content array to file
	open_tempfile(CONF, ">$ini");
	for my $line (@c) {
		print_tempfile(CONF, $line."\n");
	}
	close_tempfile(CONF);

	webmin_log("save_ws");
}
redirect("");