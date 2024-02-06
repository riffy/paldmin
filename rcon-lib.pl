#!/usr/bin/perl
# rcon-lib.pl
# Library for RCON functions

do "./paldmin-lib.pl";

# Global
our %rcon = init_rcon();


=head1 RCON

Basic stuff for the RCON

=cut

=head2 Config

Basic RCON configuration, including overwrite

=cut

=head2 init_rcon()

Returns configured rcon in a hash:
	enabled:
		If RCON is enabled by World Settings or if overwritten by module config
	valid:
		0 if unvalid, 1 if valid (meaning functions can be called)
	addr:
		IP:PORT for the rcon or undef
	pwd:
		Password without doublequotes or undef
	bin:
		The path to executable binary
	msg:
		type: Type for the message (info, warning, error, success,...)
		content: Message for disabled/invalid, etc when parsing config
=cut

sub init_rcon {
	my %rv = (
		"enabled" => 0,
		"valid" => 0,
		"addr" => undef,
		"pwd" => undef,
		"bin" => undef,
		"msg" => (
			"type" => undef,
			"content" => undef
		)
	);
	my %settings = get_world_settings();

	# Check if rcon is enabled and fill Address
	if (defined $config{"rcon_overwrite_addr"} && length($config{"rcon_overwrite_addr"}) > 0) {
		$rv{"enabled"} = 1;
		$rv{"addr"} = $config{"rcon_overwrite_addr"};
	} else {
		$rv{"enabled"} = ($settings{'RCONEnabled'} eq "True") ? 1 : 0;
		$rv{"addr"} = "127.0.0.1:".$settings{'RCONPort'};
	}

	if (!$rv{"enabled"}) {
		$rv{"msg"}{"type"} = "info";
		$rv{"msg"}{"content"} = text("index_ircon_disabled", $module_config_url);
		return %rv;
	}

	# Parse the Password
	if (defined $config{"rcon_overwrite_pwd"} && length($config{"rcon_overwrite_pwd"} > 0)) {
		$rv{"pwd"} = $config{"rcon_overwrite_pwd"};
	} elsif ($settings{'AdminPassword'} =~ /"([^"]*)"/) {
		my $pwd = $1;
		$rv{"pwd"} = $pwd unless (length($pwd) <= 0);
	}

	if (!defined $rv{"pwd"}) {
		$rv{"msg"}{"type"} = "warning";
		$rv{"msg"}{"content"} = text("index_wrcon_pwd", $module_config_url);
		return %rv;
	}

	# Check if RCON client is valid
	my $rcon_dir = $config{'rcon_dir'};
	if (!defined $rcon_dir || $rcon_dir eq "") {
		$rv{"msg"}{"type"} = "warning";
		$rv{"msg"}{"content"} = text('index_wrcon_conf', $module_config_url);
	}
	elsif (!-d $rcon_dir) {
		$rv{"msg"}{"type"} = "warning";
		$rv{"msg"}{"content"} = text('index_wrcon_dir', $rcon_dir, $module_config_url);
		return %rv;
	}
	else {
		my ($res, $rc) = get_rcon_exec_validation();
		if ($res > 0) {
			$rv{"msg"}{"type"} = "warning";
			$rv{"msg"}{"content"} = text('index_wrcon_missing_exec', $rc, $module_config_url);
		}
		else {
			$rv{"bin"} = $rc;
		}
	}

	if (defined $rv{"bin"}) {
		$rv{"valid"} = 1;
	}

	return %rv;
}

=head2 is_rcon_enabled()

Returns 1 if rcon is either enabled in the current world settings,
or if an overwrite address is provided.

=cut

sub is_rcon_enabled() {
	my %settings = get_world_settings();
	return 1 if ($settings{'RCONEnabled'} eq "True");
	return 0;
}

=head2 validate_rcon()

Checks if rcon is valid, enabled, etc.

=cut
sub validate_rcon {
	# Check if RCON is in module config
	my $rcon_dir = $config{'rcon_dir'};
	if (!defined $rcon_dir || $rcon_dir eq "") {
		return text('index_wrcon_conf', "@{[&get_webprefix()]}/config.cgi?$module_name");
	}
	elsif (!-d $rcon_dir) {
		return text('index_wrcon_dir', $rcon_dir, "@{[&get_webprefix()]}/config.cgi?$module_name");
	}
	else {
		my ($res, $rc) = get_rcon_exec_validation();
		if ($res > 0) {
			return text('index_wrcon_missing_exec', $rc, "@{[&get_webprefix()]}/config.cgi?$module_name");
		}
		elsif (!is_rcon_enabled()) {
			return text('index_ircon_disabled');
		}
		elsif (!is_rcon_password_valid()) {
			return text('index_wrcon_pwd');
		}
		return undef;
	}
}

=head2 get_rcon_exec_validation()

Checks if rcon executable is at configured path.
Returns:
	@[
		>0 if error, 0 on success
		checked path
	]

=cut

sub get_rcon_exec_validation {
	my $rc = "$config{'rcon_dir'}/rcon";
	return ((!-x $rc), $rc);
}

=head2 get_rcon_password()

Returns the rcon password in between the "" from settings or undefined

=cut

sub get_rcon_password {
	my %settings = get_world_settings();
	if ($settings{'AdminPassword'} =~ /"([^"]*)"/) {
		my $pwd = $1;
		return undef if (length($pwd) <= 0);
		return $1;
	} else {
		return undef;
	}
}

=head2 is_rcon_password_valid()

Checks if the current admin password from world settings is valid.
Return 0 on error, 1 on succes

=cut

sub is_rcon_password_valid {
	my $pwd = get_rcon_password();
	return 0 if (!defined $pwd);
	return 1;
}

=head2 Summaries

Collection of summaries for pages like index etc

=cut

=head3 get_rcon_info_index()

Returns a hash with info for the index.
Returns:
	info: Result of the "Info" command
	active: Number of active players
	error: Message when error occured, else undef

=cut

sub get_rcon_info_index {
	my %rv = (
		"info" => "",
		"active" => "?",
		"error" => undef
	);
	my ($ok, $exec, $output) = get_info();
	if (!$ok) {
		$rv{"error"} = text('rcon_command_failed', $exec, $output);
		return %rv;
	}
	$rv{"info"} = $output;
	$rv{"active"} = scalar(get_active_players());
	return %rv;
}

=head2 Commands

Implemented commands from Palworld

=cut

=head3 get_info()

Returns the info string in the output

=cut

sub get_info {
	return rcon_command_2("Info");
}

=head3 get_active_players()

Returns the active players an array.

=cut

sub get_active_players {
	my @rv;
	my ($ok, $exec, $output) = rcon_command("ShowPlayers");
	if (!$ok) {
		return @rv;
	}
	my @lines = split /\n/, $output;
	# Extract column headers
	my $header_line = shift @lines;
	my @headers = split /,/, $header_line;

	# Process each line and create a hashmap for each player
	foreach my $line (@lines) {
		my @values = split /,/, $line;
		my %player_info;

		for my $i (0 .. $#headers) {
			$player_info{$headers[$i]} = $values[$i];
		}

		push @rv, \%player_info;
	}

	return @rv;
}

=head3 broadcast(msg)

Takes a messages, replaces all whitespaces with underscores and issues the command.
Checks if the message returned starts with "Broadcasted:" to indicate success.

=cut

sub broadcast {
	my ($msg) = @_;
	# Replace all white spaces with underscores
	$msg =~ s/\s+/_/g;
	my ($ok, $exec, $output) = rcon_command("Broadcast ". $msg);
	$ok = $ok && ($output =~ /^Broadcasted:/);
	return ($ok, $exec, $output);
}

=head3 kick_player(steamid)

Takes a steamid and kicks the player.

=cut

sub kick_player {
	my ($steamid) = @_;
	my ($ok, $exec, $output) = rcon_command("KickPlayer ".$steamid);
	$ok = $ok && ($output =~ /^Kicked:/);
	return ($ok, $exec, $output);
}

=head3 ban_player(steamid)

Takes a steamid and bans the player.

=cut

sub ban_player {
	my ($steamid) = @_;
	my ($ok, $exec, $output) = rcon_command("BanPlayer ".$steamid);
	# Spelling of the result is messed up.
	$ok = $ok && ($output =~ /^Baned:/);
	return ($ok, $exec, $output);
}

=head3 rcon_command(cmd)

Executes a command, using the executeable, port on localhost.
Checks the output if it starts with cli: (indicating rcon error), or Unknown Command
Returns:
	[
		0 if error, 1 on success
		the fully executed command
		the output
	]

=cut

sub rcon_command {
	my ($cmd) = @_;
	my %settings = get_world_settings();
	my ($res, $rc) = get_rcon_exec_validation();
	my $exec = "$rc -a 127.0.0.1:" . $settings{'RCONPort'} . " -p " . get_rcon_password() . " \"$cmd\"";
	my $ok = 0;
	if (length($cmd) <= 0) {
		return ($ok, $exec, text('rcon_no_command'));
	}

	if ($res > 0) {
		return ($ok, $exec, text('index_wrcon_missing_exec', $rc, "@{[&get_webprefix()]}/config.cgi?$module_name"));
	}

	my $output = backquote_command($exec . " 2>&1 </dev/null ");
	$ok = (($output =~ /^cli:/ || $output eq "Unknown command\n" || $output =~ /^Usage:/) ? 0 : 1);
	return ($ok, $exec, $output);
}


sub rcon_command_2 {
	my ($cmd) = @_;
	my $ok = 0;
	my $exec = "";
	if (!$rcon{"valid"}) {
		return ($ok, $exec, text('rcon_config_invalid'));
	}
	
	$exec = $rcon{"bin"}." -a ".$rcon{"addr"}." -p ".$rcon{"pwd"}." \"$cmd\"";
	if (length($cmd) <= 0) {
		return ($ok, $exec, text('rcon_no_command'));
	}

	my $output = backquote_command($exec . " 2>&1 </dev/null ");
	$ok = (($output =~ /^cli:/ || $output eq "Unknown command\n" || $output =~ /^Usage:/) ? 0 : 1);
	return ($ok, $exec, $output);
}
1;