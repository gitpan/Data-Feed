use strict;
use Test::More (tests => 6);

BEGIN {
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
