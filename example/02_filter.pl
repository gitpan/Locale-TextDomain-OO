#!perl -T ## no critic (TidyCode)

use strict;
use warnings;
use Locale::TextDomain::OO;

our $VERSION = 0;

my $loc = Locale::TextDomain::OO->new(
    plugins   => [ qw( Expand::Gettext ) ],
    logger    => sub { () = print shift, "\n" },
    filter    => sub {
        my ( $self, $translation_ref ) = @_;
        ${$translation_ref} .= ' filter added: ' . $self->language;
        return;
    },
);

# translation with empty default lexicon i-default::
() = print map { "$_\n" }
    $loc->__('Hello World 1!'),
    $loc->__('Hello World 2!');

#$Id: 02_filter.pl 456 2014-01-05 16:29:05Z steffenw $

__END__

Output:

Hello World 1! filter added: i-default
Hello World 2! filter added: i-default

