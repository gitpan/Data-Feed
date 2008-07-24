# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Web/Feed.pm 66812 2008-07-24T12:31:04.820139Z daisuke  $

package Data::Feed::Web::Feed;
use Moose::Role;

has 'feed' => (
    is => 'rw',
    handles => [ qw(as_string) ]
);

requires qw(
    add_entry
    author
    copyright
    description
    entries
    format
    generator
    language
    link
    modified
    title
);

no Moose;

1;

__END__

=head1 NAME

Data::Feed::Web::Feed - Role For Web-Related Feeds

=cut
