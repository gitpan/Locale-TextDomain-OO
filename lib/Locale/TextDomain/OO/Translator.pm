package Locale::TextDomain::OO::Translator; ## no critic (TidyCode)

use strict;
use warnings;
use Carp qw(confess);
use Locale::TextDomain::OO::Singleton::Lexicon;
use Locale::TextDomain::OO::Util::JoinSplitLexiconKeys;
use Moo;
use MooX::StrictConstructor;
use MooX::Types::MooseLike::Base qw(Str);
use namespace::autoclean;

our $VERSION = '1.014';

with qw(
    Locale::TextDomain::OO::Role::Logger
);

sub load_plugins {
    my ( $class, @args ) = @_;

    my %arg_of = @args == 1 ? %{ $args[0] } : @args;
    my $plugins = delete $arg_of{plugins};
    if ( $plugins ) {
        ref $plugins eq 'ARRAY'
            or confess 'Attribute plugins expected as ArrayRef';
        for my $plugin ( @{$plugins} ) {
            my $package = ( 0 == index $plugin, q{+} )
                ? $plugin
                : "Locale::TextDomain::OO::Plugin::$plugin";
            with $package;
        }
    }

    return \%arg_of;
}

has language => (
    is      => 'rw',
    isa     => Str,
    default => 'i-default',
);

has category => (
    is      => 'rw',
    isa     => Str,
    default => q{},
);

has domain => (
    is      => 'rw',
    isa     => Str,
    default => q{},
);

has project => (
    is  => 'rw',
    isa => sub {
        my $project = shift;
        defined $project
            or return;
        return Str->($project);
    },
);

has filter => (
    is  => 'rw',
    isa => sub {
        my $arg = shift;
        # Undef
        defined $arg
            or return;
        # CodeRef
        ref $arg eq 'CODE'
            and return;
        confess "$arg is not Undef or CodeRef";
    },
);

sub _calculate_multiplural_index {
    my ($self, $count_ref, $plural_code, $lexicon, $lexicon_key) = @_;

    my $nplurals = $lexicon->{ q{} }->{multiplural_nplurals}
        or confess qq{X-Multiplural-Nplurals not found in lexicon "$lexicon_key"};
    my @counts = @{$count_ref}
        or confess 'Count array is empty';
    my $index = 0;
    while (@counts) {
        $index *= $nplurals;
        my $count = shift @counts;
        $index += $plural_code->($count);
    }

    return $index;
}

sub translate { ## no critic (ExcessComplexity ManyArgs)
    my ($self, $msgctxt, $msgid, $msgid_plural, $count, $is_n) = @_;

    my $key_util = Locale::TextDomain::OO::Util::JoinSplitLexiconKeys->instance;
    my $lexicon_key = $key_util->join_lexicon_key({(
        map {
            $_ => $self->$_;
        }
        qw( language category domain project )
    )});
    my $lexicon = Locale::TextDomain::OO::Singleton::Lexicon->instance->data;
    $lexicon = exists $lexicon->{$lexicon_key}
        ? $lexicon->{$lexicon_key}
        : ();

    my $msg_key = $key_util->join_message_key({
        msgctxt      => $msgctxt,
        msgid        => $msgid,
        msgid_plural => $msgid_plural,
    });
    if ( $is_n ) {
        my $plural_code = $lexicon->{ q{} }->{plural_code}
            or confess qq{Plural-Forms not found in lexicon "$lexicon_key"};
        my $multiplural_index = ref $count eq 'ARRAY'
            ? $self->_calculate_multiplural_index($count, $plural_code, $lexicon, $lexicon_key)
            : $plural_code->($count);
        my $msgstr_plural = exists $lexicon->{$msg_key}
            ? $lexicon->{$msg_key}->{msgstr_plural}->[$multiplural_index]
            : ();
        if ( ! defined $msgstr_plural ) { # fallback
            $msgstr_plural = $plural_code->($count)
                ? $msgid_plural
                : $msgid;
            my $text = $lexicon
                ? qq{Using lexicon "$lexicon_key".}
                : qq{Lexicon "$lexicon_key" not found.};
            $self->language ne 'i-default'
                and $self->logger
                and $self->logger->(
                    (
                        sprintf
                            '%s msgstr_plural not found for for msgctxt=%s, msgid=%s, msgid_plural=%s.',
                            $text,
                            ( defined $msgctxt      ? qq{"$msgctxt"}      : 'undef' ),
                            ( defined $msgid        ? qq{"$msgid"}        : 'undef' ),
                            ( defined $msgid_plural ? qq{"$msgid_plural"} : 'undef' ),
                    ),
                    {
                        object => $self,
                        type   => 'warn',
                        event  => 'translation,fallback',
                    },
                );
        }
        return $msgstr_plural;
    }
    my $msgstr = exists $lexicon->{$msg_key}
        ? $lexicon->{$msg_key}->{msgstr}
        : ();
    if ( ! defined $msgstr ) { # fallback
        $msgstr = $msgid;
        my $text = $lexicon
            ? qq{Using lexicon "$lexicon_key".}
            : qq{Lexicon "$lexicon_key" not found.};
        $self->language ne 'i-default'
            and $self->logger
            and $self->logger->(
                (
                    sprintf
                        '%s msgstr not found for msgctxt=%s, msgid=%s.',
                        $text,
                        ( defined $msgctxt ? qq{"$msgctxt"} : 'undef' ),
                        ( defined $msgid   ? qq{"$msgid"}   : 'undef' ),
                ),
                {
                    object => $self,
                    type  => 'warn',
                    event => 'translation,fallback',
                },
            );
    }

    return $msgstr;
}

sub run_filter {
    my ( $self, $translation_ref ) = @_;

    $self->filter
        or return $self;
    $self->filter->($self, $translation_ref);

    return $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Locale::TextDomain::OO::Translator - Translator class

$Id: Translator.pm 546 2014-10-31 09:35:19Z steffenw $

$HeadURL: svn+ssh://steffenw@svn.code.sf.net/p/perl-gettext-oo/code/module/trunk/lib/Locale/TextDomain/OO/Translator.pm $

=head1 VERSION

1.014

=head1 DESCRIPTION

This is the translator class. Extend that class with plugins (Roles).

=head1 SYNOPSIS

    require Locale::TextDomain::OO::Translator;
    Locale::TextDomain::OO::Translator->new(
        Locale::TextDomain::OO::Translator->load_plugins,
    );

=head1 SUBROUTINES/METHODS

=head2 class method load_plugins

Called before new to load the plugins.

    $hash_ref = Locale::TextDomain::OO::Translator->load_plugins;

=head2 method translate

Called from Plugins only.

    $translation = $self->translate(... lots of parameters ...);

=head2 method run_filter

Called from plugins only.

    $self->run_filter(\$translation);

=head1 EXAMPLE

Inside of this distribution is a directory named example.
Read the file README there.
Then run the *.pl files.

=head1 DIAGNOSTICS

confess

=head1 CONFIGURATION AND ENVIRONMENT

none

=head1 DEPENDENCIES

L<Moo|Moo>

L<MooX::StrictConstructor|MooX::StrictConstructor>

L<MooX::Types::MooseLike::Base|MooX::Types::MooseLike::Base>

L<Carp|Carp>

L<Locale::TextDomain::OO::Singleton::Lexicon|Locale::TextDomain::OO::Singleton::Lexicon>

L<Locale::TextDomain::OO::Util::JoinSplitLexiconKeys|Locale::TextDomain::OO::Util::JoinSplitLexiconKeys>

L<namespace::autoclean|namespace::autoclean>

=head1 INCOMPATIBILITIES

not known

=head1 BUGS AND LIMITATIONS

not known

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
