/*
requires:
http://jquery.com/
*/

jQuery.map(
    Object.keys(localeTextDomainOOLexicon),
    function (language, index) {
        var header = localeTextDomainOOLexicon[language][''];
        var plural = XRegExp.replace(
            header['plural'],
            XRegExp('\\s or \\s', 'xmsg'),
            ' || '
        );
        var code = 'return parseInt( +(' + plural + ') );';
        header['plural_code'] = new Function('n', code);

        return;
    }
);

// constructor
function localeTextDomainOO(argMap) {
    this.plugins  = argMap['plugins'];
    this.language = argMap['language'];
    this.domian   = argMap['domain']   === undefined ? '' : argMap['domain'];
    this.category = argMap['category'] === undefined ? '' : argMap['category'];
    this.filter   = argMap['filter'];
    this.logger   = argMap['logger'];

    this.lexiconKeySeparator = ':';
    this.pluralSeparator     = '{PLURAL_SEPARATOR}';
    this.msgKeySeparator     = '{MSG_KEY_SEPARATOR}';

    if (this.plugins) {
        jQuery.each(
            this.plugins,
            function (index, plugin) {
                if (plugin === 'localeTextDomainOOExpandGettext') {
                    this.localeUtilsPlaceholderNamed = new localeUtilsPlaceholderNamed();
                    localeTextDomainOOExpandGettext(this);
                }
                if (plugin === 'localeTextDomainOOExpandGettextDomainAndCategory') {
                    this.localeUtilsPlaceholderNamed = new localeUtilsPlaceholderNamed();
                    localeTextDomainOOExpandGettext(this);
                    localeTextDomainOOExpandGettextDomainAndCategory(this);
                }
            }
        )
    }

    var sprintf = function (template, args) {
        var placeholderRegex = XRegExp(
            '[%] (?<format> [s] )',
            'xmsg'
        );

        return XRegExp.replace(
            template,
            placeholderRegex,
            function (match) {
                var format = match.format;
                if (format === 's') {
                    return args.shift();
                }
                return '';
            }
        );
    }

    // method
    this.translate = function (msgctxt, msgid, msgid_plural, count, is_n) {
        var lexiconKey = [
            this.language,
            this.category,
            this.domain
        ].join(this.lexiconKeySeparator);
        var lexicon = localeTextDomainOOLexicon[lexiconKey]
            ? localeTextDomainOOLexicon[lexiconKey]
            : {};

        var lengthOrEmptyList = function (item) {
            if (item === undefined) {
                return;
            }
            if (! item.lenght) {
                return;
            }
            return item;
        };
        var msgKey = [
            lengthOrEmptyList(msgctxt),
            [
                lengthOrEmptyList(msgid),
                lengthOrEmptyList(msgid_plural)
            ].join( this.pluralSeparator )
        ].join(this.msgKeySeparator);
        if (is_n) {
            var plural_code = lexicon['']
                ? lexicon['']['plural_code']
                : undefined;
            if (! plural_code) {
                throw 'Plural-Forms not found in lexicon "' + lexiconKey + '"';
            }
            var index = plural_code(count);
            var msgstr_plural = lexicon[msgKey] && lexicon[msgKey]['msgstr_plural']
                ? lexicon[msgKey]['msgstr_plural'][index]
                : undefined;
            if (msgstr_plural === undefined) { // fallback
                msgstr_plural = index
                    ? msgid_plural
                    : msgid;
                var text = lexicon
                    ? 'Using lexicon "' + lexiconKey + '".'
                    : 'Lexicon "' + lexiconKey + '" not found.';
                this.language !== 'i-default'
                    && this.logger
                    && this.logger(
                        sprintf(
                            '%s msgstr_plural not found for for msgctxt=%s, msgid=%s, msgid_plural=%s.',
                            [
                                text,
                                ( msgctxt      === undefined ? 'undefined' : '"' + msgctxt + '"' ),
                                ( msgid        === undefined ? 'undefined' : '"' + msgid + '"' ),
                                ( msgid_plural === undefined ? 'undefined' : '"' + msgid_plural + '"' )
                            ]
                        ),
                        {
                            object: this,
                            type  : 'warn',
                            event : 'translation,fallback'
                        }
                    );
            }
            return msgstr_plural;
        }
        var msgstr = lexicon[msgKey]
            ? lexicon[msgKey]['msgstr']
            : undefined;
        if ( msgstr === undefined ) { // fallback
            msgstr = msgid;
            var text = lexicon
                ? 'Using lexicon "' + lexiconKey + '".'
                : 'Lexicon "' + lexiconKey + '" not found.';
            this.language !== 'i-default'
                && this.logger
                && this.logger(
                    sprintf(
                        '%s msgstr not found for msgctxt=%s, msgid=%s.',
                        [
                            text,
                            ( msgctxt === undefined ? 'undefinded' : '"' + msgctxt + '"' ),
                            ( msgid   === undefined ? 'undefinded' : '"' + msgid + '"' )
                        ]
                    ),
                    {
                        object : this,
                        type   : 'warn',
                        event  : 'translation,fallback',
                    }
                );
        }

        return msgstr;
    };

    return;
}
