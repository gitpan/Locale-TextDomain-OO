package Locale::TextDomain::OO::JavaScript; ## no critic (TidyCode)

use strict;
use warnings;

our $VERSION = '1.011';

1;

__END__

=head1 NAME

Locale::TextDomain::OO::JavaScript - How to use the JavaScript part

$Id: OO.pm 502 2014-05-12 20:19:51Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/module/trunk/lib/Locale/TextDomain/OO.pm $

=head1 VERSION

1.011

=head1 DESCRIPTION

This module provides a high-level interface to JavaScript message translation.

Creating the Lexicon and the selection of the language are server (Perl) based.
The script gets the lexicon in a global variable
named localeTextDomainOOLexicon.

Inside of the constructor is a language attribute,
that shoud be filled from server.

It is possible to filter the lexicon.
For bigger lexicon files filter also by language to split the lexicon.
Load only the lexicon of the current language.

=head2 How to extract?

Use module Locale::TextDomain::OO::Extract.
This is a base class for all source scanner to create pot files.
Use this base class and give this module the rules
or use one of the already exteded classes.
Locale::TextDomain::OO::Extract::JavaScript::JS
is a extension for Javacript from *.js files and so on.

=head1 SYNOPSIS

Inside of this distribution is a directory named javascript.
Copy this files into your project.
Do the same with javascript files of
L<Locale::Utils::PlaceholderNamed|Locale::Utils::PlaceholderNamed>.

This scripts depending on L<http://jquery.com/> and L<http://xregexp.com/>.

Watch also the javascript/Example.html how to use.

    <!-- depends on -->
    <script type="text/javascript" src=".../jquery-...js"></script>
    <script type="text/javascript" src=".../xregexp-min.js"></script>
    <script type="text/javascript" src=".../Locale/Utils/PlaceholderNamed.js"></script>

    <!-- stores the lexicon into var localeTextDomainOOLexicon -->
    <script type="text/javascript" src=".../localeTextDomainOOLexicon.js"></script>

    <!-- depends on var localeTextDomainOOLexicon -->
    <script type="text/javascript" src=".../Locale/TextDomain/OO.js"></script>
    <script type="text/javascript" src=".../Locale/TextDomain/OO/Plugin/Expand/Gettext.js"></script>
    <script type="text/javascript" src=".../Locale/TextDomain/OO/Plugin/Expand/Gettext/DomainAndCategory.js"></script>

    <!-- initialize -->
    <script type="text/javascript">
        var ltdoo = new localeTextDomainOO({
            plugins  : [ 'localeTextDomainOOExpandGettextDomainAndCategory' ],
            language : '@{[ $language_tag ]}', // from Perl
            category : 'LC_MESSAGES', // optional category
            domain   : 'MyDomain', // optional domain
                filter   : function(translation) { // optional filter
                // modifies the translation late
                return translation;
            },
            logger   : function (message, argMap) { // optional logger
                console.log(message);
                return;
            }
        });
    </script>

This configuration would be use Lexicon "$language_tag:LC_MESSAGES:MyDomain".
That lexicon should be filled with data.

    <!-- translations -->
    <script type="text/javascript">
        // extractable, translate
        str = ltdoo.__('msgid');
        str = ltdoo.__x('msgid', {key1 : 'value1'});
        str = ltdoo.__p('msgctxt', 'msgid');
        str = ltdoo.__px('msgctxt', 'msgid', {key1 : 'value1'});
        str = ltdoo.__n('msgid', 'msgid_plural', count);
        str = ltdoo.__nx('msgid', 'msgid_plural', count, {key1 : 'value1'});
        str = ltdoo.__np('msgctxt', 'msgid', 'msgid_plural', count);
        str = ltdoo.__npx('msgctxt', 'msgid', 'msgid_plural', count, {key1 : 'value1'});

        // extractable, prepare
        arr = ltdoo.N__('msgid');
        arr = ltdoo.N__x('msgid', {key1 : 'value1'});
        arr = ltdoo.N__p('msgctxt', 'msgid');
        arr = ltdoo.N__px('msgctxt', 'msgid', {key1 : 'value1'});
        arr = ltdoo.N__n('msgid', 'msgid_plural', count);
        arr = ltdoo.N__nx('msgid', 'msgid_plural', count, {key1 : 'value1'});
        arr = ltdoo.N__np('msgctxt', 'msgid', 'msgid_plural', count);
        arr = ltdoo.N__npx('msgctxt', 'msgid', 'msgid_plural', count, {key1 : 'value1'});

        // with domain

        // extractable, translate
        str = ltdoo.__d('domain', 'msgid');
        str = ltdoo.__dx('domain', 'msgid', {key1 : 'value1'});
        str = ltdoo.__dp('domain', 'msgctxt', 'msgid');
        str = ltdoo.__dpx('domain', 'msgctxt', 'msgid', {key1 : 'value1'});
        str = ltdoo.__dn('domain', 'msgid', 'msgid_plural', count);
        str = ltdoo.__dnx('domain', 'msgid', 'msgid_plural', count, {key1 : 'value1'});
        str = ltdoo.__dnp('domain', 'msgctxt', 'msgid', 'msgid_plural', count);
        str = ltdoo.__dnpx('domain', 'msgctxt', 'msgid', 'msgid_plural', count, {key1 : 'value1'});

        // extractable, prepare
        arr = ltdoo.N__d('domain', 'msgid');
        arr = ltdoo.N__dx('domain', 'msgid', {key1 : 'value1'});
        arr = ltdoo.N__dp('domain', 'msgctxt', 'msgid');
        arr = ltdoo.N__dpx('domain', 'msgctxt', 'msgid', {key1 : 'value1'});
        arr = ltdoo.N__dn('domain', 'msgid', 'msgid_plural', count);
        arr = ltdoo.N__dnx('domain', 'msgid', 'msgid_plural', count, {key1 : 'value1'});
        arr = ltdoo.N__dnp('domain', 'msgctxt', 'msgid', 'msgid_plural', count);
        arr = ltdoo.N__dnpx('domain', 'msgctxt', 'msgid', 'msgid_plural', count, {key1 : 'value1'});

        // with category

        // extractable, translate
        str = ltdoo.__c('msgid', 'category');
        str = ltdoo.__cx('msgid', 'category', {key1 : 'value1'});
        str = ltdoo.__cp('msgctxt', 'msgid', 'category');
        str = ltdoo.__cpx('msgctxt', 'msgid', 'category', {key1 : 'value1'});
        str = ltdoo.__cn('msgid', 'msgid_plural', count, 'category');
        str = ltdoo.__cnx('msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});
        str = ltdoo.__cnp('msgctxt', 'msgid', 'msgid_plural', count, 'category');
        str = ltdoo.__cnpx('msgctxt', 'msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});

        // extractable, prepare
        arr = ltdoo.N__c('msgid', 'category');
        arr = ltdoo.N__cx('msgid', 'category', {key1 : 'value1'});
        arr = ltdoo.N__cp('msgctxt', 'msgid', 'category');
        arr = ltdoo.N__cpx('msgctxt', 'msgid', 'category', {key1 : 'value1'});
        arr = ltdoo.N__cn('msgid', 'msgid_plural', count, 'category');
        arr = ltdoo.N__cnx('msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});
        arr = ltdoo.N__cnp('msgctxt', 'msgid', 'msgid_plural', count, 'category');
        arr = ltdoo.N__cnpx('msgctxt', 'msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});

        // with domain and category

        // extractable, translate
        str = ltdoo.__dc('domain', 'msgid', 'category');
        str = ltdoo.__dcx('domain', 'msgid', 'category', {key1 : 'value1'});
        str = ltdoo.__dcp('domain', 'msgctxt', 'msgid', 'category');
        str = ltdoo.__dcpx('domain', 'msgctxt', 'msgid', 'category', {key1 : 'value1'});
        str = ltdoo.__dcn('domain', 'msgid', 'msgid_plural', count, 'category');
        str = ltdoo.__dcnx('domain', 'msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});
        str = ltdoo.__dcnp('domain', 'msgctxt', 'msgid', 'msgid_plural', count, 'category');
        str = ltdoo.__dcnpx('domain', 'msgctxt', 'msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});

        // extractable, prepare
        arr = ltdoo.N__dc('domain', 'msgid', 'category');
        arr = ltdoo.N__dcx('domain', 'msgid', 'category', {key1 : 'value1'});
        arr = ltdoo.N__dcp('domain', 'msgctxt', 'msgid', 'category');
        arr = ltdoo.N__dcpx('domain', 'msgctxt', 'msgid', 'category', {key1 : 'value1'});
        arr = ltdoo.N__dcn('domain', 'msgid', 'msgid_plural', count, 'category');
        arr = ltdoo.N__dcnx('domain', 'msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});
        arr = ltdoo.N__dcnp('domain', 'msgctxt', 'msgid', 'msgid_plural', count, 'category');
        arr = ltdoo.N__dcnpx('domain', 'msgctxt', 'msgid', 'msgid_plural', count, 'category', {key1 : 'value1'});
    </script>

=head1 SUBROUTINES/METHODS

see SYNOPSIS

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<http://jquery.com/>

L<http://xregexp.com/>

L<Locale::Utils::PlaceholderNamed|Locale::Utils::PlaceholderNamed>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
