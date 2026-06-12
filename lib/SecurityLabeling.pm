package SecurityLabeling;

use v5.44;  # for value magic

use parent Exporter;

our @EXPORT_OK = qw(
    set_security_label
    get_security_label
    assert_security_access
);

use List::Util qw( first );
use Scalar::ValueTags qw(
    SVTAGS_UNIQUE_HASH
    add_value_tag
    get_value_tags
    register_value_tags_type
);

my $vt_type = register_value_tags_type(SVTAGS_UNIQUE_HASH);

# security labels, listed highest to lowest
my @security_labels = qw(
    restricted
    confidential
    internal
    public
);

my %security_label_indexes = map { $security_labels[$_] => $_ } 0 .. $#security_labels;

sub get_security_label ( $var_ref ) {
    my $labels = get_value_tags( $vt_type, \%tags )
      or return 'public';

    my ($max_label) = first { $labels->{$_} } @security_labels;
    return $max_label;
}

sub set_security_label ( $var_ref, $label ) {
    add_value_tag( $vt_type, $var_ref, $label );
}

sub assert_security_access ( $var_ref, $access_label, $error = undef ) {
    my $security_label = get_security_label( $vt_type, $var_ref );
    if ( $access_label < $security_label ) {
        die $error // "Invalid access: label $access_label may not access label $security_label";
    }
}

1;
__END__

=head1 NAME

SecurityLabeling - enforce inherited security access labels on data

=head1 SYNOPSIS

    # set a security label
    set_security_label( \$foo, 'public' );

    # set a higher security label
    set_security_label( \$foo, 'internal' );

    # reported security label is always highest: "internal"
    $label = get_security_label(\$foo);

    # higher label is always propagated
    set_security_label( \$bar, 'public' );

    $baz = $foo + $bar;

    # returns highest label of all sources: "internal"
    $label = get_security_label(\$baz);

    # throw exception if data label is higher than provided
    assert_security_access( \$baz, "public", "Access denied" );

=head1 DESCRIPTION

This is an example of using C<Scalar::ValueTags> (infectious value magic)
for implementing security labels on data values.

For this example, the valid security labels are hardcoded within this
module.

The effective security label on a data value is the highest label that has
been inherited from any of the sources of this data.

=head1 FUNCTIONS

=head2 set_security_label

    set_security_label( \$var, 'internal' );

Sets the security label on the data value in the given C<$var>.

If the data value has a lower security label, that will be overridden
by the new label. If the data value already has a higher security
label, that label will be preserved.

=head2 get_security_label

    $label = get_security_label( \$var );

Get the current security label for the the data value in the given C<$var>.
This will be the highest security label that has been propagated to this
data value from any of its data sources.

=head2 assert_security_access

    # using default message
    assert_security_access( \$var, 'public' );

    # using custom message
    assert_security_access( \$var, 'public', "I'm sorry, Dave, I can't do that." );

Throw an exception if the current security label for the data value in the
given C<$var> is lower than the specified C<$label>.

=head1 AUTHORS

=over

=item * Noel Maddy <zhtwnpanta@gmail.com>

=back

=cut

