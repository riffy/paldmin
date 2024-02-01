do "paldmin-lib.pl";


=head1 RCON

Basic stuff for the RCON

=cut


=head2 get_active_players()

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

=head2 broadcast(msg)

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

=head2 kick_player(steamid)

Takes a steamid and kicks the player.

=cut

sub kick_player {
	my ($steamid) = @_;
	my ($ok, $exec, $output) = rcon_command("KickPlayer ".$steamid);
	$ok = $ok && ($output =~ /^Kicked:/);
	return ($ok, $exec, $output);
}

=head2 ban_player(steamid)

Takes a steamid and bans the player.

=cut

sub ban_player {
	my ($steamid) = @_;
	my ($ok, $exec, $output) = rcon_command("BanPlayer ".$steamid);
	# Spelling of the result is messed up.
	$ok = $ok && ($output =~ /^Baned:/);
	return ($ok, $exec, $output);
}

=head2 rcon_command(cmd)

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
1;