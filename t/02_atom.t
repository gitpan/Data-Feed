use strict;
use Test::More (tests => 28);

my $HAVE_NETWORK;

BEGIN {
    if ( $ENV{DATA_FEED_NETWORK_TEST}) {
        $HAVE_NETWORK = 1;
    } else {
        eval {
            require IO::Socket::INET;
            my $socket = IO::Socket::INET->new(
                PeerAddr => 'api.flickr.com',
                PeerPort => 80
            );
            if ($socket && !$@) {
                $HAVE_NETWORK = 1;
            }
        };
    }
        

    use_ok("Data::Feed");
}

{
    my $atom = Data::Feed->parse( 't/data/atom.xml' );

    isa_ok($atom, "Data::Feed::Atom");

    is( $atom->title, 'First Weblog' );

    my @entries = $atom->entries;
    is( @entries, 2 );

    for my $entry (@entries) {
        ok( $entry->title );
    }
}

SKIP: {
    skip( "No network connection", 22 );
    my $url = URI->new('http://api.flickr.com/services/feeds/photos_public.gne');

    my $feed = Data::Feed->parse($url);

    ok( $feed );

    my @entries = $feed->entries;

    is( @entries, 20 );
    for (@entries) {
        for ($_->enclosures) {
            ok( $_->url );
        }
    }
}
