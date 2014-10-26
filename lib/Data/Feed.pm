# $Id: /mirror/coderepos/lang/perl/Data-Feed/trunk/lib/Data/Feed.pm 102566 2009-03-20T01:59:02.444375Z daisuke  $

package Data::Feed;
use 5.008;
use Any::Moose;
use Carp();
use Scalar::Util ();
use URI::Fetch;

use constant DEBUG => exists $ENV{DATA_FEED_DEBUG} ? $ENV{DATA_FEED_DEBUG} : 0;

our $VERSION = '0.00009';
our $AUTHORITY = 'cpan:DMAKI';

has 'parser' => (
    is => 'rw',
    does => 'Data::Feed::Parser',
);

__PACKAGE__->meta->make_immutable;

no Any::Moose;

sub parse {
    my ($self, $stream) = @_;

    if (! Scalar::Util::blessed($self) ){
        $self = $self->new();
    }

    if (! $stream) {
        Carp::confess("No stream to parse was provided to parse()");
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
        Carp::confess("Failed to find a suitable parser");
    }

    return $parser->parse( $content_ref );
}

sub find_parser {
    my ($self, $content_ref) = @_;

    my $format = $self->guess_format($content_ref);
    if (! $format) {
        Carp::confess("Unable to guess format from stream content");
    }

    my $class = join( '::', Scalar::Util::blessed($self), 'Parser', $format );

    Any::Moose::load_class($class);

    return $class->new();
}

sub guess_format {
    my ($self, $content_ref) = @_;

    # Auto-detect feed type based on first element. This is prone
    # to breakage, but then again we don't want to parse the whole
    # feed ourselves.

    # XXX - Make this extendable!

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
    my $ref = ref $stream || '';
    if (! $ref ) {
        # if given a string, it's a filename
        open( my $fh, '<', $stream )
            or Carp::confess("Could not open file $stream: $!");
        $content = do { local $/; <$fh> };
        close $fh;
    } else {
        if ( Scalar::Util::blessed $stream && $stream->isa('URI') ) {
            # XXX - Shouldn't using LWP suffice here?
            my $res = URI::Fetch->fetch($stream)
                or Carp::confess("Failed to fetch URI $stream: " . URI::Fetch->errstr);

            if ( $res->status == URI::Fetch::URI_GONE() ) {
                Carp::confess("This feed has been permanently removed");
            }
            $content = $res->content;
        } elsif ( $ref eq 'SCALAR' ) {
            $content = $$stream;
        } elsif ( $ref eq 'GLOB' ) {
            $content = do { local $/; <$stream> };
        } else {
            Carp::confess("Don't know how to fetch '$ref'");
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

=head1 STRUCTURE

Data::Feed has a fairly simple structure. The first layer is a "dynamic"
parser -- "dynamic" in that Data::Feed will try to find what the feed is,
and then create the appropriate parser to parse it.

This is done in Data::Feed->find_parser() and Data::Feed->guess_format().
By default we recognize RSS and Atom feeds. Should the need arise to 
either provide a custom parser or to provide more refined logic to find a
parser type, override the respective method and do what you will with it.

The second layer is a thin wrapper around RSS and Atom feed objects.
We use XML::RSS::LibXML (or XML::RSS) and XML::Atom for this purpose.

=head1 PARSING FEEDS

Data::Feed can parse files, URIs, raw strings, and file handles. All you need
to do is to pass an appropriate parameters.

For file names, we expect a plain scalar:

  Data::Feed->parse( '/path/to/feed.xml' );

For URI (which we will fetch via URI::Fetch), pass in an URI object:

  Data::Feed->parse( URI->new("http://example.com/feed.xml") );

For raw strings, pass in a scalar ref:

  Data::Feed->parse( \qq{<?xml version="1.0"><feed> .... </feed>} );

For file handles, pass in a glob:

  open(my $fh, '<', '/path/to/feed.xml' );
  Data::Feed->parse( $fh );

=head1 METHODS

=head2 parse($stream)

=head2 find_parser($stream)

Attempts to find an appropriate parser for the given stream.

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
