package TaggedTaint;

use 
use strict;
use warnings;

use Scalar::ValueTags qw(
  BEHAVIOR_UNIQUE_HASH
  add_value_tag
  clear_value_tags
  get_value_tags
  register_value_tags_type
  remove_value_tag
);

my $vt_type = register_value_tags_type(BEHAVIOR_UNIQUE_HASH);

sub taint_has_any_tag {
    my ( $var_ref, @expected ) = @_;
    my $tags = get_value_tags( $vt_type, $var_ref );
    return !!grep { $tags->{$_} } @expected;
}

sub taint_has_no_tags {
    my ( $var_ref, @expected ) = @_;
    my $tags = get_value_tags( $vt_type, $var_ref );
    return !grep { $tags->{$_} } @expected;
}

sub taint_add_tags {
    my ( $var_ref, @tags ) = @_;
    add_value_tag( $vt_type, $var_ref, $_ )
      for @tags;
    return;
}

sub taint_remove_tags {
    my ( $var_ref, @tags ) = @_;
    remove_value_tag( $vt_type, $var_ref, $_ )
      for @tags;
    return;
}

sub taint_clear_all_tags {
    my ( $var_ref ) = @_;
    clear_value_tags( $vt_type, $var_ref );
    return;
}

1;

__END__
=head1 NAME

TaggedTaint - mark data values with infectious tags

=head1 SYNOPSIS

    # add tag to value
    my $foo = 'foo';

    taint_add_tags( \$foo, 'user-input', 'main-app' );

    # both tags are propagated to $bar
    my $bar = 'silence is ' . $foo;

    # check whether $bar has one tag
    if ( taint_has_all_tags( \$bar, 'user-input' ) ) {
        # apply policy
    }

    # check whether $bar has both tags
    if ( taint_has_all_tags( \$bar, 'user-input', 'main-app' ) ) {
        # apply policy
    }

    # check whether $bar has either tag
    if ( taint_has_any_tags( \$bar, 'user-input', 'db-input' ) ) {
        # apply policy
    }

    # input has been validated: remove 'user-input' tag
    taint_remove_tags( \$bar, 'user-input' );

    # assigning new value also clears all tags
    $bar = 'baz';

    # clear all tags
    taint_clear_all_tags( \$foo );

=head1 DESCRIPTION

This is an example of using C<Scalar::ValueTags> (infectious value magic) for
implementing an access-control system similar to C<taint> that uses arbitrary
tags to indicate the type of taint.

C<TaggedTaint> allows you to add arbitrary tags to the value of any scalar variable.
The tags are then propagated whenever that variable's value is used to set the value
of another value in any way.

This tagging allows implementation of policy that is based on the flow of the data.

For instance, if a "user-input" tag is added to every variable that is set from
user input, then any code that passes data for display can apply policies that
prevent any user-input data from being displayed.

    if ( taint_has_any_tags( \$var, 'user-input' ) ) {

        # throw exception
        die "User input may not be displayed";

        # alternatively, display untagged data
        $var = '<user-entered data>;
    }

=head2 taint_add_tags

    # add one tag
    taint_add_tags( \$var, 'user-input' );

    # add multiple tags
    taint_add_tags( \$var, 'user-input', 'external-url' );

Adds one or more tags to the TagggedTaint annotation on a given data value.

=head2 taint_remove_tags

    # remove one tag
    taint_remove_tags( \$var, 'user-input' );

    # remove multiple tags
    taint_remove_tags( \$var, 'user-input', 'external-url' );

Removes one or more tags from the TaggedTaint annotation on a given data value.

=head2 taint_has_any_tags

    # has at least 'user-input' tag
    if ( taint_has_any_tags( \$var, 'user-input' ) { ... }

    # has either 'user-input' tag or 'external-url' tag
    if ( taint_has_any_tags( \$var, 'user-input', 'external-url' ) { ... }

Returns C<true> if the TaggedTaint annotation on a given data value has any
of the given tags.

=head2 taint_has_all_tags

    # has 'user-input' tag
    if ( taint_has_all_tags( \$var, 'user-input' ) { ... }

    # has both 'user-input' tag and 'external-url' tag
    if ( taint_has_all_tags( \$var, 'user-input', 'external-url' ) { ... }

Returns C<true> if the TaggedTaint annotation on a given data value has all
of the given tags.

=head2 taint_clear_all_tags

    taint_clear_all_tags( \$var );

Clears all tags from the TaggedTaint annotation on a given data value.

=AUTHORS

=over

=item * Noel Maddy <zhtwnpanta@gmail.com>

=back

=cut

