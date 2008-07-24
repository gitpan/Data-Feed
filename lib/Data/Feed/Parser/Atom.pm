# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Parser/Atom.pm 66805 2008-07-24T12:19:54.882559Z daisuke  $

package Data::Feed::Parser::Atom;
use Moose;
use Data::Feed::Atom;
use XML::Atom::Feed;

with 'Data::Feed::Parser';

__PACKAGE__->meta->make_immutable;

no Moose;

sub parse {
    my ($self, $xmlref) = @_;

    return Data::Feed::Atom->new(feed => XML::Atom::Feed->new(Stream => $xmlref) );
}

1;

__END__

=head1 NAME

Data::Feed::Parser::Atom - Data::Feed Atom Parser

=head1 METHODS

=head2 parse

=cut
