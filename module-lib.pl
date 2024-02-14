#!/usr/bin/perl
# module-lib.cgi
# Library for version checking module

do "paldmin-lib.pl";

our $github = "https://github.com";
our $repo = "riffy/paldmin";

=head2 get_higher_version

Compares the current module version and the github release version.
Returns a hashmap:
(
	"version" => The higher version detected, undef on error or if no higher version
	"error" => Error string, undef on success
)

=cut

sub get_higher_version {
	my $module_info = get_module_info(get_module_name());
	my %remote = get_latest_version();
	if (defined $remote{"error"}) {
		return (
			"error" => $remote{"error"}
		);
	}
	return (
		"version" => compare_version_strings($module_info{"version"}, $remote{"version"}),
	);
}


=head2 compare_version_strings(version_string_a, version_string_b)

Takes two version string A and B (MAJOR.MINOR.PATCH). Compares A and B.
Returns B if B is higher than A, else undef

=cut

sub compare_version_strings {
	my %a = parse_version_string(@_[0]);
	my %b = parse_version_string(@_[1]);

	if ($b{"major"} > $a{"major"}) {
		return @_[1];
	} elsif ($a{"major"} > $b{"major"}) {
		return undef;
	} elsif ($b{"minor"} > $a{"minor"}) { # Majors are equal, compare minors
		return @_[1];
	} elsif ($a{"minor"} > $b{"minor"}) {
		return undef;
	} elsif ($b{"patch"} > $a{"patch"}) { # Minors are equal, compare patches
		return @_[1];
	} else {
		return undef;
	}
}

=head2 get_latest_version

Checks a temp file:
	If it exists and last update is < 5 minutes in delta, returns the temp version.
	Else returns the remote version and writes to temp file.
Returns:
	[
		version -> Version string with MAJOR.MINOR.PATCH
		error -> Error message, set on error, else undef
		last_update -> Timestamp of last update
	]
=cut

sub get_latest_version {
	my $file = $module_config_directory."/update_check";
	my %rv;
	read_file_cached($file, \%rv);
	# Check if a version and last_update exists
	if (!defined $rv{"version"} || !defined $rv{"last_update"}) {
		return get_remote_version();
	} elsif ((time() - $rv{"last_update"}) > 300) {
		# Check if last update is older than 5 minutes
		return get_remote_version();
	} else {
		# Use values from temporary file
		delete $rv{"error"};
		return %rv;
	}
}

=head2 get_remote_version

Retrieves the latest version from github releases.
On success, writes the result to a temp file
Returns:
	[
		version -> Version string with MAJOR.MINOR.PATCH
		error -> Error message, set on error, else undef
	]

=cut

sub get_remote_version {
	my $file = $module_config_directory."/update_check";
	my %rv = (
		"version" => undef,
		"error" => undef,
		"last_update" => undef
	);
	my $json;
	my $response = http_download(
		"api.github.com", "443", "/repos/".$repo."/releases/latest", 
		\$json, \$rv{"error"}, undef,
		1, 
		undef, undef,
		30, undef, undef, undef
	);
	if (defined $rv{"error"}) {
		return %rv;
	} elsif ($json =~ /tag_name":"(.*?)"/) {
		delete $rv{"error"};
		$rv{"version"} = $1;
		$rv{"last_update"} = time();
		write_file($file, \%rv);
	}
	return %rv;
}

=head2 parse_version_string(version_string)

Takes a version string "vA.B.C" or "A.B.C" and returns a hashmap
Returns a hash with: 
	[
		major -> Major version or undef
		minor -> Minor Version or undef
		patch -> The patch or undef
	]

=cut

sub parse_version_string {
	my %rv = (
		"major" => undef,
		"minor" => undef,
		"patch" => undef
	);
	if (@_[0] =~ /(\d+)\.(\d+)\.(\d+)/) {
		$rv{"major"} = $1;
		$rv{"minor"} = $2;
		$rv{"patch"} = $3;
	}
	return %rv;
}

1;