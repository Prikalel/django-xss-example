lexer grammar HTMLLexer;

@lexer::member {
def style_sheet(self, parent=None):
    return UnlexerRule(src='', parent=parent)

}

SEA_WS
    :  (' '|'\t'? '\n')+
    ;

SCRIPT_OPEN
    : '<script' .*? '>' ->pushMode(SCRIPT)
    ;

STYLE_OPEN
    : '<style' .*? '>'  ->pushMode(STYLE)
    ;

TAG_OPEN
    : '<' -> pushMode(TAG)
    ;

HTML_TEXT
    : ~'<'+
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
    : [ \t\n] -> skip
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
    :   [:a-zA-Z]
    ;

//
// <scripts>
//
mode SCRIPT;

SCRIPT_BODY
    : .*? '</script>' -> popMode
    ;

SCRIPT_SHORT_BODY
    : .*? '</>' -> popMode
    ;

//
// <styles>
//
mode STYLE;

STYLE_BODY
    : {current += self.style_sheet()} '</style>' -> popMode
    ;

STYLE_SHORT_BODY
    : {current += self.style_sheet()} '</>' -> popMode
    ;

//
// attribute values
//
mode ATTVALUE;

// an attribute value may have spaces b/t the '=' and the value
ATTVALUE_VALUE
    : [ ]* ATTRIBUTE -> popMode
    ;

ATTRIBUTE
    : DOUBLE_QUOTE_STRING
    | SINGLE_QUOTE_STRING
    | ATTCHARS
    | HEXCHARS
    | DECCHARS
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

fragment HEXCHARS
    : '#' [0-9a-fA-F]+
    ;

fragment DECCHARS
    : [0-9]+ '%'?
    ;

fragment DOUBLE_QUOTE_STRING
    : '"' ~[<"]* '"'
    ;

fragment SINGLE_QUOTE_STRING
    : '\'' ~[<']* '\''
    ;

