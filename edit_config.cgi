#!/usr/bin/perl
# edit_config.cgi
# Show a config file for manual editing

require './paldmin-lib.pl';
ReadParse();
ui_print_header($text{'glop_config'}, $text{'index_title'}, "");


# File Selector
my ($esd, $sd) = get_savedir_validation();
if ($esd > 0) {
	display_box('danger', 'Palworld Config Missing', text('index_wsave_dir',"<tt>$sd</tt>"))
} else {
	my $dir = "$sd/Config/LinuxServer";
	print "<b>".text("glop_config_txt", $dir)."</b><br/><br/>";
	my @files = get_files_in_dir($dir);
	@files = sort @files;
	$in{'config'} ||= $files[0];
	# Full path to config file
	my $file = $dir."/".$in{'config'};

	print ui_form_start("edit_config.cgi");
	print $form_hiddens;
	print "<b>$text{'glop_config_file'}</b>\n",
		ui_select("config", $in{'config'}, \@files),"\n",
		ui_submit('Edit');
	print ui_form_end();

	# Config editor
	print ui_form_start("save_config.cgi", "form-data");
	print $form_hiddens;
	print ui_hidden("config", $in{'config'});
	print ui_table_start(undef, undef, 2);
	print ui_table_row(undef, ui_textarea("data", read_file_contents($file), 20, 80), 2);
	print ui_table_end();
	print ui_form_end([ [ undef, $text{'save'} ] ]);
}

ui_print_footer("", $text{'index_return'});
