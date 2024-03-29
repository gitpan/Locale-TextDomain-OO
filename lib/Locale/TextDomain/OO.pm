package Locale::TextDomain::OO; ## no critic (TidyCode)

use strict;
use warnings;

our $VERSION = '1.016';

use Locale::TextDomain::OO::Translator;

sub new {
    my ($class, @args) = @_;

    return Locale::TextDomain::OO::Translator->new(
        Locale::TextDomain::OO::Translator->load_plugins(@args),
    );
}

sub instance {
    my ($class, @args) = @_;

    require Locale::TextDomain::OO::Singleton::Translator;
    my $instance = Locale::TextDomain::OO::Singleton::Translator->_has_instance; ## no critic (PrivateSubs)
    $instance
        and return $instance;

    return Locale::TextDomain::OO::Singleton::Translator->instance(
        Locale::TextDomain::OO::Singleton::Translator->load_plugins(@args),
    );
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO - Perl OO Interface to Uniforum Message Translation

$Id: OO.pm 551 2014-11-01 06:46:51Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/module/trunk/lib/Locale/TextDomain/OO.pm $

=head1 VERSION

1.016

Starting with version 1.000 the interface has changed.

=head1 DESCRIPTION

This module provides a high-level interface to Perl message translation.

=head2 Why a new module?

This module is similar
to L<Locale::TextDomain|Locale::TextDomain>
and L<Locale::Maketext|Locale::Maketext>.

This module is not using/changing any system locale
like L<Locale::TextDomain|Locale::TextDomain>.

This module has no magic in how to get the language
like L<Locale::Maketext|Locale::Maketext>.
You decide what you need.

There are some plugins, so it is possible
to use the maketext and/or getext style.

Locale::TextDomain::OO has a flexible object oriented interface
based on L<Moo|Moo>.

Creating the Lexicon and translating are two splitted things.
So it is possible to create the lexicon during the initialisation phase.
The connection between both is the singleton mechanimsm of the lexicon module.

=head2 How to extract?

Use module Locale::TextDomain::OO::Extract.
This is a base class for all source scanner to create pot files.
Use this base class and give this module the rules
or use one of the already exteded classes.
Locale::TextDomain::OO::Extract::Perl is a extension for Perl code and so on.

=head2 Do not follow the dead end of Locale::Maketext!

What is the problem of?

=over

=item *

Locale::Maketext allows 2 plural forms (and zero) only.
This is changable,
but the developer has to control the plural forms.
He is not an omniscient translator.

Gettext allows as much as needed plural forms at destination language.

=item *

'quant' inside a phrase is the end of the automatic translation
because quant is an 'or'-construct.

    begin of phrase [quant,_1,singular,plural,zero] end of phrase

Gettext used full qualified sentences.

=item *

The plural form is allowed after a number,
followed by a whitespace,
not a non-breaking whitespace.

    1 book
    2 books

A plural form can not be before a number.

    It is 1 book.
    These are 2 books.

Gettext used full qualified sentences.

=item *

There is no plural form without a number in the phrase.

    I like this book.
    I like these books.

Gettext used an extra count to select the plural form.
Placeholders are placeholders not combined things.

=item *

Placeholders are numbered serially.
It is difficult to translate this
because the sense of the phrase could be lost.

    Still [_1] [_2] to [_3].

    Still 5 hours to midnight.
    Still 15 days to Olympics.

Locale::TextDomain::OO used named placeholders like

    Still {count :num} {datetime unit} to {event}.

=item *

But there are lots of modules around Locale::Maketext.

=back

This is the reason for another module to have:

=over

=item *

Endless (real: up to 6) plural forms
controlled by the translater and not by the developer.

=item *

Named placeholders.

=back

=head2 More informations

Run the examples of this distribution (folder example).

=head2 Overview

 Application calls         Application calls   Application calls
 gettext methods           getext and          maketext methods
 (hint: select this)       maketext methods            |
         |                               |             |
         v                               v             v
 .-----------------------------------------------------------------.
 | Locale::TextDomain::OO                                          |
 | with plugin LanguageOfLanguages                                 |
 | with plugins Locale::TextDomain::OO::Plugin::Expand::...        |
 |-----------------------------------------------------------------|
 | Gettext                          |\       /| Maketext           |
 | Gettext::DomainAndCategory       | |     | | Maketext::Loc      |
 | Gettext::Loc (hint: select this) | > and < | Maketext::Localise |
 | Gettext::Loc::DomainAndCategory  | |     | | Maketext::Localize |
 | Gettext::Named                   |/       \|                    |
 `-----------------------------------------------------------------'
                            ^
                            |
 .--------------------------'-----------------.
 | Locale::TextDomain::OO::Singleton::Lexicon |------------------------.
 `--------------------------------------------'                        |
                            ^                                          |
                            |                                          |
 .--------------------------'-------------------------------.          |
 | build lexicon using Locale::TextDomain::OO::Lexicon::... |          |
 |----------------------------------------------------------|          |
 |           Hash              |   File::MO     | File::PO  |          |
 `----------------------------------------------------------'          |
       ^               ^               ^              ^                |
       |               |               |              |                |
 .-----'-----.    _____|_____    .-----'----.       .-----'----.       |
 | Perl      |   /_ _ _ _ _ _\   | mo files |-.     | po files |-.     |
 | data      |   |           |   `----------' |-.   `----------' |-.   |
 | structure |   | Database  |     `----------' |     `----------' |   |
 `-----------'   `-----------'       `----------'       `----------'   |
                                       ^                   ^           |
                                       |                   |           |
                                  build using        build using       |
                                  gettext tools      gettext tools     |
                                                                       |
                                  .------------------------------------'
                                  |
                                  v
 .------------------------------------------------------------------.
 | build JSON lexicon using Locale::TextDomain::OO::Lexicon::ToJSON |
 |------------------------------------------------------------------|
 |      to_json      |      to_javascript      |      to_html       |
 `------------------------------------------------------------------'
                                  |
                                  v
              .---------------------------------------.
              | var localeTextDomainOOLexicon = json; |
              `---------------------------------------'
                                  ^
                                  |
 .--------------------------------'-------------------------------------------------.
 | requires:                                                                        |
 | - http://jquery.com/                                                             |
 | - javascript/Locale/TextDomain/OO/Util/Constants.js                              |
 | - javascript/Locale/TextDomain/OO/Util/JoinSplitLexiconKeys.js                   |
 | - javascript/Locale/Utils/PlaceholderNamed.js                                    |
 |                                                                                  |
 | implemented:                                                                     |
 | javascript/Locale/TextDomain/OO.js                                               |
 | javascript/Locale/TextDomain/OO/Plugin/Expand/Gettext.js                         |
 | javascript/Locale/TextDomain/OO/Plugin/Expand/Gettext/DomainAndCategory.js       |
 | javascript/Locale/TextDomain/OO/Plugin/Expand/Gettext/Loc.js (hint: select this) |
 | javascript/Locale/TextDomain/OO/Plugin/Expand/Gettext/Loc/DomainAndCategory.js   |
 |                                                                                  |
 | not implemented:                                                                 |
 | javascript/Locale/TextDomain/OO/Expand/Maketext.js                               |
 | javascript/Locale/TextDomain/OO/Expand/Maketext/Loc.js                           |
 | javascript/Locale/TextDomain/OO/Expand/Maketext/Localise.js                      |
 | javascript/Locale/TextDomain/OO/Expand/Maketext/Localize.js                      |
 |                                                                                  |
 | Example:                                                                         |
 | javascript/Example.html                                                          |
 `----------------------------------------------------------------------------------'
         ^                     ^                  ^
         |                     |                  |
 JavaScript calls      JavaScript calls   JavaScript calls
 gettext methods       getext and         maketext methods
 (hint: select this)   maketext methods   (not implemented)
                       (not implemented)

=head1 SYNOPSIS

    require Locale::TextDomain::OO;
    my $loc = Locale::TextDomain::OO->new(
        # all parameters are optional
        plugins  => [ qw(
            Expand::Gettext::Loc
            +My::Special::Plugin
        ) ],
        language => 'de',          # default is i-default
        category => 'LC_MESSAGES', # default is q{}
        domain   => 'MyDomain',    # default is q{}
        filter   => sub {
            my ($self, $translation_ref) = @_;
            # encode if needed
            # run a formatter if needed, e.g.
            ${$translation_ref} =~ s{__ ( .+? ) __}{<b>$1</b>}xmsg;
            return;
        },
        logger   => sub {
            my ($message, $arg_ref) = @_;
            my $type = $arg_ref->{type}; # debug or warn
            Log::Log4perl->get_logger(...)->$type($message);
            return;
        },
    );

This configuration would be use Lexicon "de:LC_MESSAGES:MyDomain".
That lexicon should be filled with data.

=head2 as singleton

Instead of method new call method instance to get a singleton.

    my $instance = Locale::TextDomain::OO->instance(
        # Same parameters like new,
        # Initialization on first call only.
    );
    $same_instance = Locale::TextDomain::OO->instance;

=head2 Attributes handled with plugin Expand::Gettext

This plugin can handle named placeholders like C<{name}>.
For numeric placeholders add attribute C<:num>.
That allows easier automatic translation and to localize numbers.
E.g. write C<{books :num}> to msgid, msgid_plural.

Grammar rules for string placeholders are able to handle affixes.
The translation office can add attributes,
e.g. C<{town :accusative}> to msgstr, msgstr[n].

Add the modifier code like that to handle that attributes.

    $loc->expand_gettext->modifier_code(
        sub {
            my ( $value, $attribute ) = @_;
            if ( $loc->language eq 'ru' ) {
                if ( $attribute eq 'accusative' ) {
                   ...
                }
            }
            elsif ( $loc->language eq 'de' }xms ) {
                if ( $attribute eq 'numf' ) {
                    ...
                    $value =~ tr{.,}{,.};
                }
            }
            return $value;
        },
    );

=head2 Attributes handled with plugin Expand::Gettext::Loc

Like before but a little difference. Instead of

    $loc->expand_gettext->modifier_code(...

write

    $loc->expand_gettext_loc->modifier_code(...

=head2 Attributes handled with plugin Expand::Gettext::Loc

Like before but a little difference. Instead of

    $loc->expand_gettext->modifier_code(...

write

    $loc->expand_gettext_named->modifier_code(...

=head2 Localize numbers with plugin Expand::Maketext

Add the code to localize numbers.

    $loc->expand_maketext->formatter_code(
        sub {
            my $value = shift;
            if ( $loc->language eq 'de' ) {
                ...
                $value =~ tr{.,}{,.};
            }
            return $value;
        },
    );

=head1 JAVASCRIPT

How to use the JavaScript framework see
L<Locale::TextDomain::OO::JavaScript|Locale::TextDomain::OO::JavaScript>.

=head1 SUBROUTINES/METHODS

=head2 method new

see SYNOPSIS

=head2 method instance

When using the singleton mechanism,
the object need not be transported through all the subroutines.

Instead of

    my $loc = Locale::TextDomain::OO->new(...);
    ...
    $loc->any_method(...);

write

    Locale::TextDomain::OO->instance(...);
    ...
    my $loc = Locale::TextDomain::OO->instance;
    $loc->any_method(...);

In case of webserver child or similar,
set the language for every reqeuest not as parameter of the first instance call.

=head2 method language

Set the language an prepare the translation.
You know exactly how to set.
This module is stupid.

    $loc->language( $language );

Get back

    $language = $loc->language;

=head2 method category

You are able to ignore or set the category.
That depends on your project.

    $loc->category($category || q{} );
    $category = $loc->category;

=head2 method domain

You are able to ignore or set the domain.
That depends on your project.

    $loc->domain($domain || q{} );
    $domain = $loc->domain;

=head2 method filter

You are allowed to run code after each translation.

    $loc->filter( sub {
        my ( $self, $translation_ref ) = @_;

        # $self is $loc
        # manipulate ${$translation_ref}
        # do not undef ${$translation_ref}

        return;
    } );

Switch off the filter

    $loc->filter(undef);

=head2 method logger

Set the logger

    $loc->logger(
        sub {
            my ($message, $arg_ref) = @_;
            my $type = $arg_ref->{type};
            Log::Log4perl->get_logger(...)->$type($message);
            return;
        },
    );

$arg_ref contains

    object => $loc, # the object itself
    type   => 'debug', # or 'warn'
    event  => 'language,selection', # 'language,selection,fallback'
                                    # or 'translation,fallback'

=head2 method translate

Do never call that method in your project.
This method was called from expand plugins only.

    $translation
        = $self->translate($msgctxt, $msgid, $msgid_plural, $count, $is_n);

=head2 method run_filter

Do never call that method in your project.
This method was called from expand plugins only.

    $self->filter(\$translation);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Read the file README there.
Then run the *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Locale::TextDomain::OO::Translator|Locale::TextDomain::OO::Translator>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

In the gettext manual you can read at
"15.5.18.9 Bugs, Pitfalls, And Things That Do Not Work"
something that is not working with Perl.
The examples there are rewritten and explained here.

=head2 string interpolation and joined strings

    print <<"EOF";
        $loc->__(
            'The dot operator'
            . ' does not work'
            . ' here!'
        )
        Likewise, you cannot @{[ $loc->__('interpolate function calls') ]}
        inside quoted strings or quote-like expressions.
    EOF

The fist call can not work.
Methods are not callable in interpolated strings/"here documents".
The . operator is normally not implemented at the extractor.
The first parameter of method __ must be a constant.

There is no problem for the second call because the extractor
extracts the Perl file as text and did not parse the code.

=head2 Regex eval

This example is no problem here, because the file is extracted as text.

    s/<!--START_OF_WEEK-->/$loc->__('Sunday')/e;

=head2 named placeholders

Method __ is an alias for method __x.
But {OPTIONS} is not a placeholder
because key "OPTIONS" is not in parameters.

    die $loc->__("usage: $0 {OPTIONS} FILENAME...\n");

    die $loc->__x("usage: {program} {OPTIONS} FILENAME...\n", program => $0);

=head1 SEE ALSO

L<Locale::TextDoamin|Locale::TextDoamin>

L<Locale::Maketext|Locale::Maketext>

L<http://www.gnu.org/software/gettext/manual/gettext.html>

L<http://en.wikipedia.org/wiki/Gettext>

L<http://translate.sourceforge.net/wiki/l10n/pluralforms>

L<http://rassie.org/archives/247>
The choice of the right module for the translation.

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 - 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
