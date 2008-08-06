# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed/Parser/RSS.pm 67918 2008-08-06T03:19:45.324161Z daisuke  $

package Data::Feed::Parser::RSS;
use Moose;
use Data::Feed::RSS;

our $PARSER_CLASS;

BEGIN {
    my @candidates = $ENV{DATA_FEED_RSS_PARSERS} ?
        split(/\s+/, $ENV{DATA_FEED_RSS_PARSERS}) :
        qw(XML::RSS::LibXML XML::RSS);

    foreach my $module (@candidates) {
        eval { Class::MOP::load_class($module) };
        next if $@;

        $PARSER_CLASS = $module;
        last;
    }

    if (! $PARSER_CLASS) {
        confess "Cannot find suitable parser class from @candidates";
    }
}

with 'Data::Feed::Parser';

__PACKAGE__->meta->make_immutable;

no Moose;

sub parse {
    my ($self, $xmlref) = @_;

    my $rss = $PARSER_CLASS->new();
    $rss->parse($$xmlref);

    return Data::Feed::RSS->new(feed => $rss);
}

1;

__END__

=head1 NAME

Data::Feed::Parser::RSS - Data::Feed RSS Parser

=head1 METHODS

=head2 parse

=cut