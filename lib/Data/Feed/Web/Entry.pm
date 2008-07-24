# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Web/Entry.pm 66819 2008-07-24T12:49:10.752170Z 33rpm  $

package Data::Feed::Web::Entry;
use Moose::Role;
use Data::Feed::Web::Enclosure;

with 'Data::Feed::Item';

has 'entry' => (
    is => 'rw',
    isa => 'HashRef',
    required => 1,
);

requires 'title';
requires 'link';
requires 'content';
requires 'summary';
requires 'category';
requires 'author';
requires 'id';
requires 'issued';
requires 'modified';
requires 'enclosures';

no Moose;

1;

__END__

=head1 NAME

Data::Feed::Web::Entry - Role For Web-Related Feed Entry

=cut
