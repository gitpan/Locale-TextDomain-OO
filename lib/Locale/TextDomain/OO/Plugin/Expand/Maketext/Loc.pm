package Locale::TextDomain::OO::Plugin::Expand::Maketext::Loc; ## no critic (TidyCode)

use strict;
use warnings;
use Moo::Role;
use namespace::autoclean;

our $VERSION = '1.000';

with qw(
    Locale::TextDomain::OO::Plugin::Expand::Maketext
);

{
    no warnings qw(redefine); ## no critic (NoWarnings)
    *loc    = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::maketext;
    *loc_p  = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::maketext_p;
    *Nloc   = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::Nmaketext;
    *Nloc_p = \&Locale::TextDomain::OO::Plugin::Expand::Maketext::Nmaketext_p;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Plugin::Expand::Maketext::Loc - Alternative maketext methods

$Id: Loc.pm 439 2013-12-19 20:42:34Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/module/trunk/lib/Locale/TextDomain/OO/Plugin/Expand/Maketext/Loc.pm $

=head1 VERSION

1.000

=head1 DESCRIPTION

This module provides alternative maketext methods.

=head1 SYNOPSIS

    my $loc = Locale::TextDomain::OO->new(
        plugins => [ qw(
            Expand::Maketext::Loc
            ...
        ) ],
        ...
    );

=head1 SUBROUTINES/METHODS

=head2 methods loc, loc_p, Nloc, Nloc_p

This methods are aliases to method
maketext, maketext_p, Nmaketext and Nmaketext_p.

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

nothing

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo::Role|Moo::Role>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Plugin::Expand::Maketext|Locale::TextDomain::OO::Plugin::Expand::Maketext>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
