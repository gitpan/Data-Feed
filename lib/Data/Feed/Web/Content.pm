# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Web/Content.pm 66789 2008-07-24T11:49:26.173225Z daisuke  $

package Data::Feed::Web::Content;
use Moose;

has 'type' => (
    is => 'rw',
    isa => 'Str',
);

has 'body' => (
    is => 'rw',
    isa => 'Str',
);

no Moose;

1;

__END__

=head1 NAME

Data::Feed::Web::Content - Role For Web-Related Feed Entry Content

=cut
