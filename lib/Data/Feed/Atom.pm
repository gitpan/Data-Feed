# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Atom.pm 66807 2008-07-24T12:23:19.849499Z daisuke  $

package Data::Feed::Atom;
use Moose;
use Data::Feed::Atom::Entry;

with 'Data::Feed::Web::Feed';

no Moose;

sub format { 'Atom' }

sub title { shift->feed->title(@_) }
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
sub description { shift->feed->tagline(@_) }
sub copyright   { shift->feed->copyright(@_) }
sub language    { shift->feed->language(@_) }
sub generator   { shift->feed->generator(@_) }

sub author {
    my $self = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $self->feed->author($person);
    } else {
        $self->feed->author ? $self->feed->author->name : undef;
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
    my @entries;
    for my $entry ($_[0]->feed->entries) {
        push @entries, Data::Feed::Atom::Entry->new(entry => $entry);
    }

    @entries;
}

sub add_entry {
    my $self = shift;
    my($entry) = @_;
    $self->feed->add_entry($entry->entry);
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

