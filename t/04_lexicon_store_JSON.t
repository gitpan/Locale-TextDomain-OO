#!perl -T

use strict;
use warnings;

use Test::More tests => 29;
use Test::NoWarnings;
use Test::Differences;
use JSON qw(decode_json);

BEGIN {
    require_ok('Locale::TextDomain::OO::Lexicon::Hash');
    require_ok('Locale::TextDomain::OO::Lexicon::StoreJSON');
}

Locale::TextDomain::OO::Lexicon::Hash
    ->new(
        logger => sub { note shift },
    )
    ->lexicon_ref({
        '::'           => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        ':cat1:'       => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        '::dom1'       => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        ':cat1:dom1'   => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        'en::'         => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        'en:cat1:'     => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        'en::dom1'     => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        'en:cat1:dom1' => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
        'de:cat1:dom1' => [{ msgid  => "", msgstr => "Content-Type: text/plain; charset=UTF-8\nPlural-Forms: nplurals=1; plural=0" }],
    });

eq_or_diff
    [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON->new->to_json,
            )
        },
    ],
    [ qw(
        ::
        ::dom1
        :cat1:
        :cat1:dom1
        de:cat1:dom1
        en::
        en::dom1
        en:cat1:
        en:cat1:dom1
        i-default::
    ) ],
    'all languages, all categories and all domains';

sub _wrap_filter {
    return [
        sort keys %{
            decode_json(
                Locale::TextDomain::OO::Lexicon::StoreJSON
                    ->new(@_)
                    ->to_json,
            )
        },
    ];
}

note 'filter 1 thing';
{
    eq_or_diff
        _wrap_filter(
            filter_language => [ qw( en ) ],
        ),
        [ qw(
            en::
            en::dom1
            en:cat1:
            en:cat1:dom1
        ) ],
        'all languages en';
    eq_or_diff
        _wrap_filter(
            filter_category => [ qw( cat1 ) ],
        ),
        [ qw(
            :cat1:
            :cat1:dom1
            de:cat1:dom1
            en:cat1:
            en:cat1:dom1
        ) ],
        'all categories cat1';
    eq_or_diff
        _wrap_filter(
            filter_domain => [ qw( dom1 ) ],
        ),
        [ qw(
            ::dom1
            :cat1:dom1
            de:cat1:dom1
            en::dom1
            en:cat1:dom1
        ) ],
        'all domains dom1';
}

note 'filter_language_category';
{
    eq_or_diff
        _wrap_filter(
            filter_language_category => [ {} ],
        ),
        [ qw(
            ::
            ::dom1
        ) ],
        'empty language and category';
     eq_or_diff
        _wrap_filter(
            filter_language_category => [ {
                language => 'i-default',
            } ],
        ),
        [ qw(
            i-default::
        ) ],
        'language i-default, empty category';
     eq_or_diff
        _wrap_filter(
            filter_language_category => [ {
                category => 'cat1',
            } ],
        ),
        [ qw(
            :cat1:
            :cat1:dom1
        ) ],
        'empty language, category cat1';
    eq_or_diff
        _wrap_filter(
            filter_language_category => [ {
                language => 'en',
                category => 'cat1',
            } ],
        ),
        [ qw(
            en:cat1:
            en:cat1:dom1
        ) ],
        'language en, category cat1';
}

note 'filter_language_domain';
{
    eq_or_diff
        _wrap_filter(
            filter_language_domain => [ {} ],
        ),
        [ qw(
            ::
            :cat1:
        ) ],
        'empty language and domain';
     eq_or_diff
        _wrap_filter(
            filter_language_domain => [ {
                language => 'en',
            } ],
        ),
        [ qw(
            en::
            en:cat1:
        ) ],
        'language en, empty domain';
     eq_or_diff
        _wrap_filter(
            filter_language_domain => [ {
                domain => 'dom1',
            } ],
        ),
        [ qw(
            ::dom1
            :cat1:dom1
        ) ],
        'empty language, domain dom1';
    eq_or_diff
        _wrap_filter(
            filter_language_domain => [ {
                language => 'en',
                domain   => 'dom1',
            } ],
        ),
        [ qw(
            en::dom1
            en:cat1:dom1
        ) ],
        'language en, domain dom1';
}

note 'filter_category_domain';
{
    eq_or_diff
        _wrap_filter(
            filter_category_domain => [ {} ],
        ),
        [ qw(
            ::
            en::
            i-default::
        ) ],
        'empty category and domain';
    eq_or_diff
        _wrap_filter(
            filter_category_domain => [ {
                category => 'cat1',
            } ],
        ),
        [ qw(
            :cat1:
            en:cat1:
        ) ],
        'category cat1, empty domain';
    eq_or_diff
        _wrap_filter(
            filter_category_domain => [ {
                domain => 'dom1',
            } ],
        ),
        [ qw(
            ::dom1
            en::dom1
        ) ],
        'empty category, domain dom1';
    eq_or_diff
        _wrap_filter(
            filter_category_domain => [ {
                category => 'cat1',
                domain   => 'dom1',
            } ],
        ),
        [ qw(
            :cat1:dom1
            de:cat1:dom1
            en:cat1:dom1
        ) ],
        'category cat1, domain dom1';
}

note 'filter_language_category_domain';
{
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {} ],
        ),
        [ qw(
            ::
        ) ],
        'empty language, category and domain';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                language => 'en',
            } ],
        ),
        [ qw(
            en::
        ) ],
        'language en, empty category and domain';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                category => 'cat1',
            } ],
        ),
        [ qw(
            :cat1:
        ) ],
        'empty language, category cat1, empty domain';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                domain => 'dom1',
            } ],
        ),
        [ qw(
            ::dom1
        ) ],
        'empty language and category, domain dom1';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                language => 'en',
                category => 'cat1',
            } ],
        ),
        [ qw(
            en:cat1:
        ) ],
        'language en, category cat1, empty domain';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                language => 'en',
                domain   => 'dom1',
            } ],
        ),
        [ qw(
            en::dom1
        ) ],
        'language en, empty category, domain dom1';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                category => 'cat1',
                domain   => 'dom1',
            } ],
        ),
        [ qw(
            :cat1:dom1
        ) ],
        'empty language, category cat1, domain dom1';
    eq_or_diff
        _wrap_filter(
            filter_language_category_domain => [ {
                language => 'en',
                category => 'cat1',
                domain   => 'dom1',
            } ],
        ),
        [ qw(
            en:cat1:dom1
        ) ],
        'language en, category cat1, domain dom1';
}

like
    +Locale::TextDomain::OO::Lexicon::StoreJSON
        ->new( filter_language_category_domain => [ {} ] )
        ->to_javascript,
    qr{\A \Qvar localeTextDomainOOLexicon = {\E .*? \Q};\E \n \z}xms,
    'to_javascript';
like
    +Locale::TextDomain::OO::Lexicon::StoreJSON
        ->new( filter_language_category_domain => [ {} ] )
        ->to_html,
    qr{
        \A
        \Q<script type="text/javascript"><!--\E \n
        \Qvar localeTextDomainOOLexicon = {\E .*? \Q};\E \n
        \Q--></script>\E \n
        \z
    }xms,
    'to_html';
