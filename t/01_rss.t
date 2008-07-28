use strict;
use Test::More (tests => 25);

my $HAVE_NETWORK;

BEGIN {
    if ( $ENV{DATA_FEED_NETWORK_TEST}) {
        $HAVE_NETWORK = 1;
    } else {
        eval {
            require IO::Socket::INET;
            my $socket = IO::Socket::INET->new(
                PeerAddr => '4u.straightline.jp',
                PeerPort => 80
            );
            if ($socket || !$@) {
                $HAVE_NETWORK = 1;
            }
        };
    }


    use_ok("Data::Feed");
}

{
    my $rss = Data::Feed->parse( 't/data/rss10.xml' );

    isa_ok($rss, "Data::Feed::RSS");

    is( $rss->title, 'First Weblog' );

    my @entries = $rss->entries;
    is( @entries, 2 );

    for my $entry (@entries) {
        ok( $entry->title );
    }
}

SKIP: {
    skip( "No network connection", 19 ) unless $HAVE_NETWORK;
    my $rss = eval {
        Data::Feed->parse( URI->new('http://4u.straightline.jp/rss') )
    };
    if ($@ && $@ =~ /Failed to fetch/) {
        skip( "Failed to fetch rss (skipping for sanity's sake", 19 );
    }

    ok( $rss, "Fetch successful" );
    isa_ok($rss, "Data::Feed::RSS");

    is( $rss->title, '4U' );

    my @entries = $rss->entries;
    is( @entries, 15 );

    for my $entry (@entries) {
        ok( $entry->enclosures );
    }
}
