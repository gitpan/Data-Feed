# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Atom.pm 88595 2008-10-20T16:13:11.386706Z daisuke  $

package Data::Feed::Atom;
use Moose;
use Data::Feed::Atom::Entry;
use XML::Atom::Feed;
use XML::Atom::Person;
use XML::Atom::Util qw( iso2dt );
use List::Util qw( first );
use DateTime::Format::W3CDTF;

with 'Data::Feed::Web::Feed';

__PACKAGE__->meta->make_immutable;

no Moose;

use constant format => 'Atom';

BEGIN {
    my $meta = __PACKAGE__->meta;
    my %methods = map { ($_ => $_) }
        qw(title copyright language generator id updated tagline as_xml);
    $methods{description} = 'tagline';
    while (my($name, $proxy) = each %methods) {
        $meta->add_method($name => Moose::Meta::Method->wrap(
            package_name => __PACKAGE__,
            name         => $name,
            body         => sub { shift->feed->$proxy(@_) }
        ));
    }
}

sub BUILDARGS {
    my $class = shift;
    my $args  = @_ == 1 ? $_[0] : { @_ };

    $args->{feed} ||= XML::Atom::Feed->new;
    return $args;
}

sub link {
    my $self = shift;
    if (@_) {
        $self->feed->add_link({ rel => 'alternate', href => $_[0],
                                  type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $self->feed->link;
        $l ? $l->href : undef;
    }
}

sub author {
    my $self = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Namespace => $self->feed->ns, Version => 1.0);
        $person->name($_[0]);
        $self->feed->author($person);
    } else {
        my $person = $self->feed;
        return $person->author ? $person->author->name : ();
    }
}

sub modified {
    my $self = shift;
    if (@_) {
        $self->feed->modified(DateTime::Format::W3CDTF->format_datetime($_[0]));
    } else {
        $self->feed->modified ? iso2dt($self->feed->modified) : undef;
    }
}

sub entries {
    my $self = shift;

    my @entries;
    for my $entry ($self->feed->entries) {
        push @entries, Data::Feed::Atom::Entry->new(entry => $entry);
    }

    return @entries;
}

sub add_entry {
    my ($self, $entry) = @_;
    return $self->feed->add_entry($entry->entry);
}

1;

__END__

=head1 NAME

Data::Feed::Atom - Atom Feed

=head2 add_entry

=head2 author

=head2 copyright

=head2 description

=head2 entries

=head2 format

=head2 generator

=head2 language

=head2 link

=head2 modified

=head2 title


=cut

