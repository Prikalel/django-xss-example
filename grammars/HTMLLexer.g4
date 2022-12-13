lexer grammar HTMLLexer;

DJ_OPEN
    : '{% '
    ;

DJ_CLOSE
    : ' %}'
    ;

DJ_DEBUG
    : DJ_OPEN 'debug' DJ_CLOSE
    ;

DJ_START_WITH
    : DJ_OPEN 'with ' DJ_WITH_RULES+ DJ_CLOSE
    ;

DJ_WITH_RULES
    : DJ_VARIABLE '=' DJ_VALUE ' '
    ;

DJ_VARIABLE
    : 'var1' | 'var2' | 'var3'
    ;

DJ_VALUE
    : '123' | '"<script>alert(\'XSS\');</script>"'
    ;

DJ_END_WITH
    : DJ_OPEN 'endwith' DJ_CLOSE
    ;

DJ_START_SPACELESS
    : DJ_OPEN 'spaceless' DJ_CLOSE
    ;

DJ_END_SPACELESS
    : DJ_OPEN 'endspaceless' DJ_CLOSE
    ;

NEWLINE
    : '\n'
    ;

TAG_OPEN
    : '<' -> pushMode(TAG)
    ;

HTML_TEXT
    : TAG_NameStartChar+
    ;

//
// tag declarations
//
mode TAG;

TAG_CLOSE
    : '>' -> popMode
    ;

TAG_SLASH_CLOSE
    : '/>' -> popMode
    ;

TAG_SLASH
    : '/'
    ;

//
// lexing mode for attribute values
//
TAG_EQUALS
    : '=' -> pushMode(ATTVALUE)
    ;

TAG_NAME
    : TAG_NameStartChar TAG_NameChar*
    ;

TAG_WHITESPACE
    : [ ] -> skip
    ;

fragment
HEXDIGIT
    : [a-fA-F0-9]
    ;

fragment
DIGIT
    : [0-9]
    ;

fragment
TAG_NameChar
    : TAG_NameStartChar
    | '-'
    | '_'
    | '.'
    | DIGIT
    ;

fragment
TAG_NameStartChar
    :   [a-zA-Z]
    ;

//
// attribute values
//
mode ATTVALUE;

// an attribute value may have spaces b/t the '=' and the value
ATTVALUE_VALUE
    : ATTRIBUTE -> popMode
    ;

ATTRIBUTE
    : ATTCHARS
    ;

fragment ATTCHAR
    : '-'
    | '_'
    | '.'
    | '/'
    | '+'
    | ','
    | '?'
    | '='
    | ':'
    | ';'
    | '#'
    | [0-9a-zA-Z]
    ;

fragment ATTCHARS
    : ATTCHAR+ ' '?
    ;
