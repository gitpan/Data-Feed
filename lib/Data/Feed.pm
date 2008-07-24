# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed.pm 66960 2008-07-24T23:33:24.943063Z daisuke  $

package Data::Feed;
use Moose;
use URI::Fetch;

our $VERSION = '0.00002';

has 'parser' => (
    is => 'rw',
    does => 'Data::Feed::Parser',
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub parse {
    my ($self, $stream) = @_;

    if (! blessed $self) {
        $self = $self->new();
    }

    if (! $stream) {
        confess "No stream to parse was provided to parse()";
    }

    my $content_ref = $self->fetch_stream($stream);

    my $parser = $self->parser;
    if ($parser) {
        # If we get a parser, then use it
        return $parser;
    }

    # otherwise, attempt to figure out what we're parsing
    $parser = $self->find_parser( $content_ref );

    if (! $parser) {
        confess "Failed to find a suitable parser";
    }

    return $parser->parse( $content_ref );
}

sub find_parser {
    my ($self, $content_ref) = @_;

    my $format = $self->guess_format($content_ref);
    if (! $format) {
        confess "Unable to guess format from stream content";
    }

    my $class = join( '::', blessed $self, 'Parser', $format );

    Class::MOP::load_class($class);

    return $class->new();
}

sub guess_format {
    my ($self, $content_ref) = @_;

    # Auto-detect feed type based on first element. This is prone
    # to breakage, but then again we don't want to parse the whole
    # feed ourselves.

    # XXX - Make this extensible!

    { 
        my $tag;

        while ($$content_ref =~ /<(\S+)/sg) {
            (my $t = $1) =~ tr/a-zA-Z0-9:\-\?!//cd;
            my $first = substr $t, 0, 1;
            $tag = $t, last unless $first eq '?' || $first eq '!';
        }

        if (! $tag) {
            # confess "Could not find the first XML element";
            return ();
        }

        $tag =~ s/^.*://;

        if ($tag eq 'rss' || $tag eq 'RDF') {
            return 'RSS';
        } elsif ($tag eq 'feed') {
            return 'Atom';
        }
    }

    return ();
}

sub fetch_stream {
    my ($self, $stream) = @_;

    my $content = '';
    my $ref = blessed $stream || '';
    if (! $ref ) {
        # if given a string, it's a filename
        open( my $fh, '<', $stream )
            or confess "Could not open file $stream: $!";
        $content = do { local $/; <$fh> };
        close $fh;
    } else {
        if ( $stream->isa('URI') ) {
            # XXX - Shouldn't using LWP suffice here?
            my $res = URI::Fetch->fetch($stream)
                or confess "Failed to fetch URI $stream: " . URI::Fetch->errstr;

            if ( $res->status == URI::Fetch::URI_GONE() ) {
                confess "This feed has been permanently removed";
            }
            $content = $res->content;
        } elsif ( $stream->isa('SCALAR') ) {
            $content = $$stream;
        } elsif ( $stream->isa('GLOB') ) {
            $content = do { local $/; <$stream> };
        } else {
            confess "Don't know how to fetch '$ref'";
        }
    }

    return \$content;
}

1;

__END__

=head1 NAME

Data::Feed - Extensible Feed Parsing Tool

=head1 SYNOPSIS

  use Data::Feed;

  # from a file
  $feed = Data::Feed->parse( '/path/to/my/feed.xml' );

  # from an URI
  $feed = Data::Feed->parse( URI->new( 'http://example.com/atom.xml' ) );

  # from a string
  $feed = Data::Feed->parse( \$feed );

  # from a handle
  $feed = Data::Feed->parse( $fh );

  # Data::Feed auto-guesses the type of a feed by its contents, but you can
  # explicitly tell what parser to use

  $feed = Data::Feed->new( parser => $myparser )->parse(...);

=head1 DESCRIPTION

Data::Feed is a frontend for feeds. It will attempt to auto-guess what type
of feed you are passing it, and will generate the appropriate feed object.

What, another XML::Feed? Yes, but this time it's extensible. It's cleanly
OO (until you get down to the XML nastiness), and it's easy to add your own
parser to do whatever you want it to do.

=head1 METHODS

=head2 parse($stream)

=head2 find_parser($stream)

=head2 guess_format($stream)

=head2 fetch_stream($stream)

=head1 TODO

Be able to /set/ enclosures (We can already get enclosures).

=head1 AUTHORS

Daisuke Maki C<< <daisuke@endeworks.jp> >>

Taro Funaki C<< <t@33rpm.jp> >>

A /Lot/ of the code is based on code from XML::Feed.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
