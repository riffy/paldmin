=head1 Paldmin Library

Functions for the Palworld Server configuration.

=cut

use WebminCore;

init_config();

# Globals
our $module_config_url = "@{[&get_webprefix()]}/config.cgi?$module_name";
our %service = (
	"enabled" => 0,
	"name" => undef,
	"valid" => 0,
	"msg" => {
		"type" => undef,
		"content" => undef
	}
);

=head2 Validation

Validation of config, files, accessing, etc.
Returns errors

=cut

=head3 init_service()

Initializes the global service var.
Configured service in a hash:
	enabled:
		If service is enabled by the module config
	name:
		Name of the service to check
	valid:
		0 if unvalid, 1 if valid and service exists
	msg:
		type: Type for the message (info, warning, error, success,...)
		content: Message for disabled/invalid, etc when parsing config
=cut

sub init_service {
	# Check if enabled
	if (!defined $config{"systemctl"} || length($config{"systemctl"}) <= 0) {
		$service{"msg"}{"type"} = "info";
		$service{"msg"}{"content"} = text("service_no_service", $module_config_url);
		return;
	}
	$service{"enabled"} = 1;
	$service{"name"} = $config{"systemctl"};

	# Check if systemctl is valid
	if (has_command("systemctl")) {
		my $output = backquote_command("systemctl list-unit-files $service{'name'} 2>&1");
		# Check if the output contains any unit files for the service
		if ($output =~ /(\d+)\s+unit files listed/) {
			my $num_unit_files = $1;
			if ($num_unit_files > 0) {
				# Success (service found)
				$service{"valid"} = 1;
			}
		}
	}

	if (!$service{"valid"}) {
		$service{"msg"}{"type"} = "info";
		$service{"msg"}{"content"} = text("service_missing_daemon", $service{"name"} ,$module_config_url);
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
		return ('warning', text("validate_savegame_missing"), text('index_wsave_dir',"<tt>$sd</tt>"))
	}
	($e, $sd) = get_saveconfig_validation();
	if ($e > 0) {
		return ('warning', text("validate_savegameconf_missing"), text('index_wsave_conf',"<tt>$sd</tt>"))
	}
	return;
}

=head2 get_savedir_validation()

Checks if palserver contains a save directory. 
Returns either the save directory or undef

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

=head1 get_service_status

Retrieves the service status via systemctl and returns a hash with the info.
Returns: {
	'state': 'active' | 'loaded' | 'inactive' | ...
}

=cut

sub get_service_status {
	my %rv;
	if (!$service{"valid"}) {
		return %rv;
	}

    my $res = backquote_command("systemctl status ".$service{"name"});

	# Extract information from the command output
	if ($res =~ /Loaded: .+; (\w+); preset: \w+/) {
		$rv{'atboot'} = $1;
	}

	if ($res =~ /Active: (\w+)/) {
		$rv{'state'} = $1;
	}

	if ($res =~ /Active: \w+ \(\w+\)\ssince\s([^*].*)/) {
		$rv{'upsince'} = $1;
	}

	if ($res =~ /Memory: (\d+[^\n]*)/) {
		$rv{'memory'} = $1;
	}

	return %rv;
}


=head2 get_server_state

Returns the service state or undef if no systemctl registered

=cut

sub get_server_state {
	if (!$service{"valid"}) {
		return undef;
	}
	return (backquote_command("systemctl is-active ".$service{"name"}) =~ s/\n//r);
}

=head2 is_server_running()

Returns 1 if systemctl is running, else 0

=cut

sub is_server_running() {
	return (get_server_state() eq "active") ? 1 : 0;
}

=head1 Server Control

Basic things to control the server, such as start, stop, restart, etc.

=cut

=head2 start_server()

Starts the server by the service

=cut

sub start_server() {
	if (!$service{"valid"}) {
		return text('missing_cmd', "@{[&get_webprefix()]}/config.cgi?$module_name");
	}
	my $out = backquote_logged("systemctl start $config{'systemctl'} 2>&1 </dev/null");
	if ($?) { 
		return "<pre>$out</pre>"; 
	}
}

=head2 stop_server()

Stop the server by the service

=cut

sub stop_server {
	if (!$service{"valid"}) {
		return text('missing_cmd', $module_config_url);
	}
	my $out = backquote_logged("systemctl stop $config{'systemctl'} 2>&1 </dev/null");
	if ($?) { 
		return "<pre>$out</pre>"; 
	}
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

=head2 get_setting(settings)

Returns the configured setting for a field.
Returns undef on error

=cut

sub get_setting {
	my ($setting) = @_;
	my %settings = get_world_settings();
	return $settings{$setting};
}

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

sub settings_file_read {
	my ($ini) = @_;
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

=head2 get_banned_steamids()

Tries to read the banlist.txt.
If the file doesn't exist, returns an empty array;

=cut

sub get_banned_steamids() {
	my @rv;
	my ($esd, $sd) = get_savedir_validation();
	my $file = $sd."/SaveGames/banlist.txt";
	open_readfile(BANS, $file) || return @rv;
	while(<BANS>) {
		chomp;
		if (/steam_(\d+)/) {
            push @rv, $1;
        }
	}
	close(BANS);
	return @rv;
}

=head2 add_steamid_to_banlist(steamid)

Takes a steamid with the prefix "steamid_XXXX".
Checks if the banlist.txt exists, if not creates it.

Returns:
	a string with error
	undef on success

=cut

sub add_steamid_to_banlist {
	my ($sId) = @_;
	my ($e, $sd) = get_savedir_validation();
	if ($e > 0) {
		return text('banlist_eadd_missdir', $sd);
	}
	my $file = $sd."/SaveGames/banlist.txt";
	lock_file($file);
	my $lref = read_file_lines($file);
	push(@$lref, $sId);
	flush_file_lines($file);
	unlock_file($file);
	return undef;
}

=head2 remove_steamids_from_banlist(@steamids)

Takes an array of steamids with the prefix "steam_" 
and removes them from the banlist.txt

=cut

sub remove_steamids_from_banlist {
	my ($ids) = @_;
	my ($e, $sd) = get_savedir_validation();
	if ($e > 0) {
		return text('banlist_eadd_missdir', $sd);
	}
	my $file = $sd."/SaveGames/banlist.txt";
	my @splices = ();
	
	lock_file($file);
	my $lref = read_file_lines($file);

	# Find all line indexes with matching id
    for my $id (@$ids) {
        for my $i (0 .. $#$lref) {
			my $line = @$lref[$i];
            if (index($id, $line) >= 0) {
                push @splices, $i;
                last;  # Break the loop once the ID is found
            }
        }
    }

	
	for my $splice (reverse @splices) {
		splice(@$lref, $splice, 1);
	}

	flush_file_lines($file);
	unlock_file($file);
	
	return undef;
}

=head1 Utility

Simple Utility functions

=cut

=head1 get_files_in_dir(dir)

=cut

sub get_files_in_dir {
	my ($dir) = @_;
	opendir(DIR, $dir);
	local @rv = grep { $_ ne "." && $_ ne ".." } readdir(DIR);
	closedir(DIR);
	return @rv;
}

1;