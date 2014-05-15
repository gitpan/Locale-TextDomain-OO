package Locale::TextDomain::OO::Lexicon::Role::StoreFilter; ## no critic (TidyCode)

use strict;
use warnings;
use List::MoreUtils qw(any);
use Locale::TextDomain::OO::Singleton::Lexicon;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(ArrayRef);
use namespace::autoclean;

our $VERSION = '1.011';

with qw(
    Locale::TextDomain::OO::Lexicon::Role::Constants
);

has filter_language => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_category => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_domain => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_language_category => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_language_domain => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_category_domain => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has filter_language_category_domain => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub { [] },
);

has _language_category_domain_regex => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $separator = $self->lexicon_key_separator;
        my $not_separator_regex = sprintf '[^%s]', quotemeta $separator;
        return [
            (
                map {
                    qr{
                        \A
                        \Q$_\E
                        \Q$separator\E
                        $not_separator_regex*
                        \Q$separator\E
                        $not_separator_regex*
                        \z
                    }xms;
                } @{ $self->filter_language }
            ),
            (
                map {
                    qr{
                        \A
                        $not_separator_regex*
                        \Q$separator\E
                        \Q$_\E
                        \Q$separator\E
                        $not_separator_regex*
                        \z
                    }xms;
                } @{ $self->filter_category }
            ),
            (
                map {
                    qr{
                        \A
                        $not_separator_regex*
                        \Q$separator\E
                        $not_separator_regex*
                        \Q$separator\E
                        \Q$_\E
                        \z
                    }xms;
                } @{ $self->filter_domain }
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $language = $_->{language} || q{};
                    my $category = $_->{category} || q{};
                    qr{
                        \A
                        \Q$language\E
                        \Q$separator\E
                        \Q$category\E
                        \Q$separator\E
                        $not_separator_regex*
                        \z
                    }xms;
                } @{ $self->filter_language_category }
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $language = $_->{language} || q{};
                    my $domain   = $_->{domain}   || q{};
                    qr{
                        \A
                        \Q$language\E
                        \Q$separator\E
                        $not_separator_regex*
                        \Q$separator\E
                        \Q$domain\E
                        \z
                    }xms;
                } @{ $self->filter_language_domain }
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $category = $_->{category} || q{};
                    my $domain   = $_->{domain}   || q{};
                    qr{
                        \A
                        $not_separator_regex*
                        \Q$separator\E
                        \Q$category\E
                        \Q$separator\E
                        \Q$domain\E
                        \z
                    }xms;
                } @{ $self->filter_category_domain }
            ),
            (
                map { ## no critic (ComplexMappings)
                    my $language = $_->{language} || q{};
                    my $category = $_->{category} || q{};
                    my $domain   = $_->{domain}   || q{};
                    qr{
                        \A
                        \Q$language\E
                        \Q$separator\E
                        \Q$category\E
                        \Q$separator\E
                        \Q$domain\E
                        \z
                    }xms;
                } @{ $self->filter_language_category_domain }
            ),
        ],
    },
);

sub data {
    my ( $self, $arg_ref ) = @_;

    my $data  = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;
    my $regex = $self->_language_category_domain_regex;
    $data = {
        map { ## no critic (ComplexMappings)
            my $lexicon = { %{ $data->{$_} } };
            # not able to serialize code references
            delete $lexicon->{ q{} }->{plural_code};
            SEPARATOR_NAME:
            for my $separator_name ( qw( msg_key_separator plural_separator ) ) {
                my $text_separator_name = $arg_ref->{$separator_name}
                    or next SEPARATOR_NAME;
                my $binary_separator = $self->$separator_name;
                for my $lexicon_key ( keys %{$lexicon} ) {
                    my $new_key = $lexicon_key;
                    $new_key =~ s{
                        \Q$binary_separator\E
                    }{$text_separator_name}xmsg;
                    $lexicon->{$new_key}
                        = delete $lexicon->{$lexicon_key};
                }
            }
            $_ => $lexicon;
        }
        grep {
            my $lexicon_name = $_;
            @{$regex}
                ? any { $lexicon_name =~ $_ } @{$regex}
                : 1;
        }
        keys %{$data}
    };

    return $data;
}

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Lexicon::Role::StoreFilter - Filters the lexicon data before stored

$Id: StoreFilter.pm 499 2014-05-12 12:53:39Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/module/trunk/lib/Locale/TextDomain/OO/Lexicon/Role/StoreFilter.pm $

=head1 VERSION

1.011

=head1 DESCRIPTION

This module filters the lexicon date before stored.

The idea is: Not all parts of lexicon are used by other languages.

Implements attributes "filter_language", "filter_category", "filter_domain"
and combinations of that up to "filter_language_category_domain".

That filter removes also the key "plural_code" from header.
That is an already prepared Perl code reference
to calculate what plural form should used.
The other language has to create the code again from key header key "plural".
That contains that pseudo code from po/mo file
without C<;> and/or C<\n> at the end.

=head1 SYNOPSIS

    with qw(
        Locale::TextDomain::OO::Lexicon::Role::StoreFilter
    );

Usage of that optional filter

    use Locale::TextDomain::OO::Lexicon::Store...;

    my $json = Locale::TextDomain::OO::Lexicon::Store...
        ->new(
            ...
            # all parameters optional
            filter_language          => [
                # this languages and unchecked domain and category
                qw( language1 language2 ),
            ],
            filter_category        => [
                # this categories and unchecked language and domain
                qw( category1 category2 ),
            ],
            filter_domain          => [
                # this domains and unchecked language and category
                qw( domain1 domain2 ),
            ],
            filter_language_category => [
                {
                    # empty language
                    # empty category
                    # unchecked domain
                },
                {
                    language => 'language1',
                    # empty category
                    # unchecked domain
                },
                {
                    # empty language,
                    category => 'category1',
                    # unchecked domain
                },
                {
                    language => 'language1',
                    category => 'category1',
                    # unchecked domain
                },
            },
            filter_language_domain => [
                {
                    # empty language
                    # unchecked category
                    # empty domain
                },
                ...
                {
                    language => 'language1',
                    # unchecked category
                    domain   => 'domain1',
                },
            },
            filter_domain_category => [
                {
                    # unchecked language
                    # empty category
                    # empty domain
                },
                ...
                {
                    # unchecked language
                    category => 'category1',
                    domain   => 'domain1',
                },
            },
            filter_language_domain_category => [
                {
                    # empty language
                    # empty category
                    # empty domain
                },
                ...
                {
                    language => 'language1',
                    category => 'category1',
                    domain   => 'domain1',
                },
            },
        )
        ->to_...;

=head1 SUBROUTINES/METHODS

=head2 method data

Get back that filtered lexicon data.

    $data = $self->data;

or for special cases without control chars

    $data = $self->data({
        msg_key_separator => '{MSG_KEY_SEPARATOR}',
        plural_separator  => '{PLURAL_SEPARATOR}',
    });

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Run this *.pl files.

=head1 DIAGNOSTICS

none

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<List::MoreUtils|List::MoreUtils>

L<Locale::TextDomain::OO::Singleton::Lexicon|Locale::TextDomain::OO::Singleton::Lexicon>

L<Moo::Role|Moo::Role>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<namespace::autoclean|namespace::autoclean>

L<Locale::TextDomain::OO::Lexicon::Role::Constants|Locale::TextDomain::OO::Lexicon::Role::Constants>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

none

=head1 SEE ALSO

L<Locale::TextDoamin::OO|Locale::TextDoamin::OO>

=head1 AUTHOR

Steffen Winkler

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 - 2014,
Steffen Winkler
C<< <steffenw at cpan.org> >>.
All rights reserved.

This module is free software;
you can redistribute it and/or modify it
under the same terms as Perl itself.
