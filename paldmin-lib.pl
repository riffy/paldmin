=head1 paldmin-lib.pl

Functions for the Palworld Server configuration.

=cut

use WebminCore;

init_config();

=head2 Validation

Validation of config, files, accessing, etc.
Returns errors

=cut

=head2 validate_config()

Checks if the paldmin config is correct.
Also validates the values of the paldmin config.

Returns:
	@[type, title, content]
	or
	empty list on success

=cut

sub validate_config() {
	# Check if paldmin config file exists
	if (!-r $config{'paldmin_config'}) {
		return ('error', 'Module Config', text('index_econfig',"<tt>$config{'paldmin_config'}</tt>", "@{[&get_webprefix()]}/config.cgi?$module_name"))
	}

	my ($e, $sp) = get_script_validation();
	if ($e > 0) {
		return ('error', 'Module Config', text('index_epalworld',"<tt>$sp</tt>", "@{[&get_webprefix()]}/config.cgi?$module_name"))
	}

	my $ectl = get_systemctl_validation();
	if ($ectl > 0) {
		return ('error', 'Module Config', text('index_eservice',"<tt>$config{'systemctl'}</tt>", "@{[&get_webprefix()]}/config.cgi?$module_name"))
	}

	return;
}

=head2 get_script_validation

Checks if the configured palworld install directory is correct and the shell script exists
and is executable.

Returns:
	@[
		>0 if error, 0 on success
		checked script path
	]

=cut

sub get_script_validation() {
	my $script_path = "$config{'palserver'}/PalServer.sh";
	return ((!-x $script_path), $script_path)
}

=head2 get_systemctl_validation()

Checks if the daemon service in the config is correctly configured
and registered as systemctl service.
Returns 0 on success or 1 on error / not found.

=cut

sub get_systemctl_validation() {
	my $systemctlcmd = has_command("systemctl");
	if (!defined $systemctlcmd) {
		return 1;
	}
	my $output = backquote_command("systemctl list-unit-files $config{'systemctl'} 2>&1");
	# Check if the output contains any unit files for the service
    if ($output =~ /(\d+)\s+unit files listed/) {
        my $num_unit_files = $1;
        if ($num_unit_files > 0) {
            # Success (service found)
            return 0;
        } else {
            # Error (service not found)
            return 1;
        }
    } else {
        # Error (unexpected output)
        return 1;
    }
}

=head2 validate_savegame()

Checks if the server has run before.
Returns:
	@[type, title, content]
	or
	empty list on success

=cut

sub validate_savegame() {
	my ($e, $sd) = get_savedir_validation();
	if ($e > 0) {
		return ('warning', 'Palworld Savegame Missing', text('index_wsave_dir',"<tt>$sd</tt>"))
	}
	($e, $sd) = get_saveconfig_validation();
	if ($e > 0) {
		return ('warning', 'Palworld Savegame Config Missing', text('index_wsave_conf',"<tt>$sd</tt>"))
	}
	return;
}

=head2 get_savedir_validation()

Checks if palserver contains a save directory. Returns either the save directory or undef

=cut

sub get_savedir_validation() {
	my $sd = "$config{'palserver'}/Pal/Saved";
	return ((!-d $sd), $sd);
}

=head2 get_saveconfig_validation()

Checks if palserver contains a config file (PalworldSettings.ini)
in the config dir inside the save directory.
Returns:
	@[
		>0 if error, 0 on success
		checked config path
	]

=cut

sub get_saveconfig_validation() {
	my ($esd, $sd) = get_savedir_validation();
	my $conf_world_settings = "$sd/Config/LinuxServer/PalWorldSettings.ini";
	return ((!-r $conf_world_settings), $conf_world_settings);
}

=head1 Service Info

Basic Service Info about status etc

=cut

=head2 is_server_running()

Returns 1 if systemctl is running, else 0

=cut

sub is_server_running() {
	my $systemctlcmd = has_command("systemctl");
	if (!defined $systemctlcmd) {
		return 0;
	}
	my $out = backquote_command("systemctl is-active $config{'systemctl'}");
	return index($out, "inactive") != -1 ? 0 : 1;
}

=head2 up_since()

Returns the timestamp the service was started.
Returns ? if the server is offline

=cut
sub up_since() {
	my $out = backquote_command("systemctl show $config{'systemctl'} --property=ActiveEnterTimestamp");
	# Extract everything after "ActiveEnterTimestamp="
    if ($out =~ /ActiveEnterTimestamp=(.+)/) {
        return $1;
    } else {
        return $text{'basic_upsince_not_started'};
    }
}

=head1 Server Control

Basic things to control the server, such as start, stop, restart, etc.

=cut

=head2 start_server()

Starts the server by the service

=cut

sub start_server() {
	if ($config{'systemctl'}) {
		my $out = backquote_logged("systemctl start $config{'systemctl'} 2>&1 </dev/null");
		if ($?) { 
			return "<pre>$out</pre>"; 
		}
	} else {
		return text('missing_cmd', "@{[&get_webprefix()]}/config.cgi?$module_name");
	}
}

=head2 stop_server()

Stop the server by the service

=cut

sub stop_server {
	if ($config{'systemctl'}) {
		my $out = backquote_logged("systemctl stop $config{'systemctl'} 2>&1 </dev/null");
		if ($?) { 
			return "<pre>$out</pre>"; 
		}
	} else {
		return text('missing_cmd', "@{[&get_webprefix()]}/config.cgi?$module_name");
	}
	return undef;
}

=head2 restart_server(force_restart)

Restarts the server. If force is set, uses the stop and start routine.
Returns undef on success, else the out of the restart

=cut

sub restart_server {
	my ($force_restart) = @_;
	my $out;
	$out = &backquote_logged("systemctl restart $config{'systemctl'} 2>&1 </dev/null") if (!$force_restart);
	if ($? || $force_restart) {
		stop_server();
		$out = start_server();
	}
	return $? ? $out : undef;
}

=head1 Palworld Config 

Basic stuff to configure the palworld server

=cut

=head2 get_world_settings()

Retrieves the default world settings and the save world settings.
Combines them by replacing the default world settings with save world settings if applicable.
Returns undefined on error (if either setting doesn't exist).

=cut

sub get_world_settings() {
	my %def = get_default_world_settings();
	if (!%def) {
		return undef;
	}
	my %save = get_save_world_settings();
	if (!%save) {
		return %def;
	}
	foreach my $savek (keys %save) {
		$def{$savek} = $save{$savek};
	}
	return %def;
}

=head2 get_default_world_settings()

Returns the default world settings from the ini file.

=cut

sub get_default_world_settings() {
	return settings_file_read("$config{'palserver'}/DefaultPalWorldSettings.ini");
}

=head2 get_save_world_settings()

Returns the world settings from the ini file.

=cut

sub get_save_world_settings() {
	my ($e, $ini) = get_saveconfig_validation();
	if ($e > 0) {
		return undef;
	}
	return settings_file_read($ini);
}

=head2 settings_file_read(file)

Reads a given settings file.
Returns undefined on error, else returns the settings as a 2D Array.

Returns:
	[
		[Key, Value]
	]

=cut

sub settings_file_read() {
	my $ini = @_[0];
	if (!-r $ini) {
		return undef;
	}
	my %rv;
	open_readfile(INI, $ini) || return undef;	
	while(<INI>) {
		my $option_settings_line = $_;
		if ($option_settings_line =~ /OptionSettings=\((.*?)\)/) {
			my $options_str = $1;
			my @pairs = split /,/, $options_str;

			foreach my $pair (@pairs) {
				my ($key, $value) = split /=/, $pair;
				$rv{$key} = $value;
			}
		} 
	}
	close(INI);
	return %rv;
}

# Utility

=head2 display_box(type, title, content)

Displays a generic box based on the type title and content provided.
type: danger | warning | info  -> Else success

=cut

sub display_box() {
	my $alert_box_type = 'success';
	if (@_[0] eq 'danger') { $alert_box_type = 'error' }
	elsif (@_[0] eq 'warning') { $alert_box_type = 'warn' }
	elsif (@_[0] eq 'info') { $alert_box_type = 'info' }

	print ui_alert_box('', $alert_box_type);
	print ui_details({
		'title' => @_[1],
		'content' => @_[2],
		'class' => @_[0],
		'html' => 1},
		1);
}

1;