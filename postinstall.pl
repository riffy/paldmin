require "paldmin-lib.pl"; 

=head1 Post Install

=cut

=head2 module_install()
	Checks if the config exists.
	If not, copies the default paldmin config to the config directory
=cut
sub module_install {
	if (!-r "$config{"paldmin_config"}") {
    	copy_source_dest("$module_root_directory/config", "$config{"paldmin_config"}");
    }
}