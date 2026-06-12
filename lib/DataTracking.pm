package DataTracking;

use v5.44;  # for value magic

use parent Exporter;

our @EXPORT_OK = qw(
    clear_data_sources
    export_and_clear_data_sources
    export_data_sources
    get_data_sources
    set_data_source
);

use Scalar::ValueTags qw(
    SVTAGS_UNIQUE_ARRAY_REF
    add_value_tag
    clear_value_tags
    get_value_tags
    register_value_tags_types
);

my $vt_type = register_value_tags_type(SVTAGS_UNIQUE_ARRAY_REF);

my $output_stream;

sub set_data_source ( $var_ref, $source_metadata ) {
    add_value_tag( $vt_type, $var_ref, $source_metadata );
}

sub get_data_sources ( $var_ref ) {
    get_value_tags( $vt_type, $var_ref );
}

sub clear_data_sources ( $var_ref ) {
    clear_value_tags( $vt_type, $var_ref );
}

sub export_and_clear_data_sources ( $var_ref, $sink_metadata ) {
    my $data_sources = get_data_sources($var_ref);

    # convert data sources into desired export structure; include sink metadata
    send( $output_stream, [ $sink_metadata, $data_sources ] );

    clear_data_sources($var_ref);
}

1;
__END__

=head1 NAME

DataTracking - track inherited source of data values

=head1 SYNOPIS

    # add tracking data sources when data is received from external sources
    my $names = $dbh->selectcol_arrayref('select name from user where user_id = %s", undef, $id);
    my $name = $names->[0];
    add_data_source(\$name,
        { table => 'user', column => 'name', id => $id, file => __FILE__, line => __LINE__ }
    );

    # data sources are propagated to $salutation
    my $salutation = "Hello, $name";

    # get data sources
    my $data_sources = get_data_sources(\$salutation); # returns data sources set on $name

    # capture data sources when data is sent to external sink, including sending metadata
    export_and_clear_data_sources( \$salutation, { var => 'salutation', file => __FILE__, line => __LINE__ } );

=head1 DESCRIPTION

This is an example of using C<Scalar::ValueTags> (infectious value magic) for
implementing data flow tracking that can be used to populate data lineage
systems such as OpenLineage.

C<DataTracking> allows arbitrary tracking data to be attached to data values when the
values are received from an external system, propagates the tracking data any time
that other data is derived from the original data, and captures the tracking data
from the value when it is sent to an external sink.

When the tracking items are propagated, they are de-duplicated using the refaddr
of the data structure set in C<set_data_source>.

The tracking data may be formatted in any way, such as OpenLineage.

=head2 Implementation

C<DataTracking> uses the C<SVTAGS_UNIQUE_REF_ARRAY> behavior, which allows arbitrary
reference data structures to be added to the value magic, and de-duplicates the structures
by C<refaddr> when propagating them to subsequent data values.

=head1 FUNCTIONS

=head2 set_data_source

    set_data_source( \$var, { this => 1, that => 2 } );

Set the data source for the value of the given C<$var> to be the given data structure.

=head2 get_data_sources

    $data_sources = get_data_sources(\$var);
    for my $data_source (@$data_sources) { ... }

Returns arrayref of all data sources inherited by value in given C<$var>.

=head2 clear_data_sources

    clear_data_sources(\$var);

Clears all data sources on value in given C<$var>.

=head2 export_and_clear_data_sources

    export_and_clear_data_sources( \$var, { sink => 'database', table => 'user', id => $id } );

Captures and sends the tracking data from C<$var>, adding the given metadata to indicate
where the data is being exported from.

=head1 AUTHORS

=over

=item * Noel Maddy <zhtwnpanta@gmail.com>

=back

=cut

