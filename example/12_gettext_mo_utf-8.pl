#!perl -T

use strict;
use warnings;
use utf8;

our $VERSION = 0;

use Carp qw(croak);
use English qw(-no_match_vars $OS_ERROR);
use Encode qw(encode_utf8 decode_utf8);
require Locale::TextDomain::OO;

local $ENV{LANGUAGE}
    = Locale::TextDomain::OO
    ->get_default_language_detect()
    ->('ru');
my $text_domain = 'example';

my $loc = Locale::TextDomain::OO->new(
    text_domain => $text_domain,
    search_dirs => [qw(./LocaleData/)],
    # input filter
    input_filter => \&encode_utf8,
    # output filter
    filter       => \&decode_utf8,
);

# all unicode chars encode to UTF-8
binmode STDOUT, ':encoding(utf-8)'
    or croak "Binmode STDOUT\n$OS_ERROR";

# run all translations
() = print map {"$_\n"}
    $loc->__(
        'book',
    ),
    $loc->__(
        '§ book',
    );

# $Id: 12_gettext_mo_utf-8.pl 237 2009-12-28 08:11:59Z steffenw $

__END__

Output:

книга
§ книга
