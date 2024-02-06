#!/usr/bin/perl
# ui-lib.pl
# Library for UI stuff

=head1 UI Library

Some UI library functions to quickly display info/error boxes, headings etc.

=cut

=head2 alert_box(type, title, desc)

Displays an alert box and parses the type correctly.
Type: error | warning | info | success -> Default: error
Title: Gets displayed in the same row as the type
Desc: Gets displayed after a br.

=cut

sub alert_box {
	my $alert_box_type = 'danger';
	if (@_[0] eq 'success') { $alert_box_type = 'success' }
	elsif (@_[0] eq 'warning') { $alert_box_type = 'warn' }
	elsif (@_[0] eq 'info') { $alert_box_type = 'info' }

	my $title = (defined @_[1]) ? @_[1]."<br/>" : "";
	my $desc = (defined @_[2]) ? @_[2] : "";

	print ui_alert_box($title.$desc, $alert_box_type);
}

=head2 collapsible_box(type, title, desc)

Displays a collapsible box and parses the type correctly.
Type: error | warning | info | success -> Default: error
Title: Gets displayed in the same row as the title row
Desc: Gets displayed in the collapsible part

=cut

sub collapsible_box {
	print ui_details({
		'title' => @_[1],
		'content' => @_[2],
		'class' => @_[0],
		'html' => 1},
		1);
}

=head2 box_with_collapsible(type, title, content)

Displays a generic box based on the type title and content provided.
type: danger | warning | info  -> Else success

=cut

sub alert_box_with_collapsible {
	alert_box(@_[0]);
	collapsible_box(@_[0], @_[1], @_[2]);
}

1;