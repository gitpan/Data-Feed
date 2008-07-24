# $Id$

package Data::Feed::RSS::Entry;
use Moose;
use Data::Feed::Web::Content;
use DateTime::Format::Mail;
use DateTime::Format::W3CDTF;

with 'Data::Feed::Web::Entry';

no Moose;

sub title {
    my $item = shift->entry;
    @_ ? $item->{title} = $_[0] : $item->{title};
}

sub link {
    my $item = shift->entry;
    if (@_) {
        $item->{link} = $_[0];
        ## For RSS 2.0 output from XML::RSS. Sigh.
        $item->{permaLink} = $_[0];
    }
    else {
        $item->{link} || $item->{guid};
    }
}

sub summary {
    my $item = shift->entry;

    if (@_) {
        $item->{description} = blessed $_[0] eq 'Data::Feed::Web::Content' ?
            $_[0]->body : $_[0];
        ## Because of the logic below, we need to add some dummy content,
        ## so that we'll properly recognize the description we enter as
        ## the summary.
        if (!$item->{content}{encoded} &&
            !$item->{'http://www.w3.org/1999/xhtml'}{body}) {
            $item->{content}{encoded} = ' ';
        }
    }
    else {
        ## Some RSS feeds use <description> for a summary, and some use it
        ## for the full content. Pretty gross. We don't want to return the
        ## full content if the caller expects a summary, so the heuristic is:
        ## if the <entry> contains both a <description> and one of the elements
        ## typically used for the full content, use <description> as summary.
        my $txt;
        if ($item->{description} &&
            ($item->{content}{encoded} ||
             $item->{'http://www.w3.org/1999/xhtml'}{body})) {
            $txt = $item->{description};
        }
        Data::Feed::Web::Content->new(
            type => 'text/html',
            body => $txt,
        );
    }
}

sub content {
    my $item    = shift->entry;

    if (@_) {
        my $c = blessed $_[0] eq 'Data::Feed::Web::Content' ? $_[0]->body : $_[0];
        $item->{content}{encoded} = $c;
    }
    else {
        my $body =
            $item->{content}{encoded} ||
            $item->{'http://www.w3.org/1999/xhtml'}{body} ||
            $item->{description};
        Data::Feed::Web::Content->new(
            type => 'text/html',
            body => $body,
        );
    }
}

sub category {
    my $item = shift->entry;
    if (@_) {
        $item->{category} = $item->{dc}{subject} = $_[0];
    }
    else {
        $item->{category} || $item->{dc}{subject};
    }
}

sub author {
    my $item = shift->entry;
    if (@_) {
        $item->{author} = $item->{dc}{creator} = $_[0];
    }
    else {
        $item->{author} || $item->{dc}{creator};
    }
}

## XML::RSS doesn't give us access to the rdf:about for the <item>,
## so we have to fall back to the <link> element in RSS 1.0 feeds.
sub id {
    my $item = shift->entry;

    if (@_) {
        $item->{guid} = $_[0];
    }
    else {
        $item->{guid} || $item->{link};
    }
}

sub issued {
    my $item = shift->entry;

    if (@_) {
        $item->{dc}{date} = DateTime::Format::W3CDTF->format_datetime($_[0]);
        $item->{pubDate} = DateTime::Format::Mail->format_datetime($_[0]);
    }
    else {
        ## Either of these could die if the format is invalid.
        my $date;
        eval {
            if (my $ts = $item->{pubDate}) {
                my $parser = DateTime::Format::Mail->new;
                $parser->loose;
                $date = $parser->parse_datetime($ts);
            } elsif ($ts = $item->{dc}{date}) {
                $date = DateTime::Format::W3CDTF->parse_datetime($ts);
            }
        };
        return $date;
    }
}

sub modified {
    my $item = shift->entry;

    if (@_) {
        $item->{dcterms}{modified} =
            DateTime::Format::W3CDTF->format_datetime($_[0]);
    }
    else {
        if (my $ts = $item->{dcterms}{modified}) {
            return eval { DateTime::Format::W3CDTF->parse_datetime($ts) };
        }
    }
}

sub enclosures {
    my $self = shift;

    die if @_;

    my @enclosures;
    for my $enclosure ($self->__enclosures) {
        push @enclosures, Data::Feed::Web::Enclosure->new(
            %$enclosure
        );
    }

    @enclosures;
}

sub __enclosures {
    my $item = shift->entry;

    ref $item->{enclosure} eq 'ARRAY' ?
        @{ $item->{enclosure} } :
        $item->{enclosure}
    ;
}

1;

__END__

=head1 NAME

Data::Feed::RSS::Entry - An RSS Entry

=head1 METHODS

=head2 author

=head2 category

=head2 content

=head2 enclosures

=head2 id

=head2 issued

=head2 link

=head2 modified

=head2 summary

=head2 title

=cut