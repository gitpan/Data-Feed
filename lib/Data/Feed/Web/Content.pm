# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Web/Content.pm 67717 2008-08-02T21:56:07.486475Z daisuke  $

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

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=head1 NAME

Data::Feed::Web::Content - Role For Web-Related Feed Entry Content

=cut
