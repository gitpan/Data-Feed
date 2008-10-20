# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Web/Feed.pm 88595 2008-10-20T16:13:11.386706Z daisuke  $

package Data::Feed::Web::Feed;
use Moose::Role;

has 'feed' => (
    is => 'rw',
);

requires qw(
    add_entry
    as_xml
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
