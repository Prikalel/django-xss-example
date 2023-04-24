lexer grammar HTMLLexer;

DJ_OPEN
    : '{% '
    ;

DJ_CLOSE
    : ' %}'
    ;

DJ_VARIABLE_OPEN
    : '{{ '
    ;

DJ_VARIABLE_CLOSE
    : ' }}'
    ;

JSON_BRACE_OPEN
    : '{ '
    ;

JSON_BRACE_CLOSE
    : ' }'
    ;

JSON_COMMA
    : ','
    ;

JSON_QUOTES
    : '"'
    ;

JSON_COLON
    : ':'
    ;

DJ_COMMENT_OPEN
    : '{# '
    ;

DJ_COMMENT_CLOSE
    : ' #}'
    ;

DJ_FORCE_ESCAPE_FILTER
    : '|force_escape'
    ;

DJ_NOW
    : 'now '
    ;

DJ_NOW_FORMAT
    : '"SHORT_DATETIME_FORMAT"'
    | '"DATETIME_FORMAT"'
    | '"DATE_FORMAT"'
    | '"SHORT_DATE_FORMAT"'
    ;

DJ_DEBUG
    : DJ_OPEN 'debug' DJ_CLOSE
    ;

DJ_WITH_KEYWORD
    : 'with '
    ;

DJ_BLOCK_KEYWORD
    : 'block '
    ;

DJ_FOR_KEYWORD
    : 'for '
    ;

DJ_AS_KEYWORD
    : 'as '
    ;

DJ_INCLUDE_KEYWORD
    : 'include '
    ;

DJ_FOR_IN_KEYWORD
    : ' in '
    ;

DJ_CYCLE_KEYWORD
    : 'cycle '
    ;

DJ_RESETCYCLE_KEYWORD
    : 'resetcycle '
    ;

DJ_AUTOESCAPE_ON
    : 'autoescape on'
    ;

DJ_END_AUTOESCAPE
    : 'endautoescape'
    ;

DJ_FIRSTOF_KEYWORD
    : 'firstof '
    ;

DJ_WITH_EQUALS
    : '='
    ;

DJ_SPACE
    : ' '
    ;

DJ_VARIABLE
    : 'var1' | 'var2' | 'var3' | 'somename'
    ;

DJ_VALUE
    : '"123"' | '"<script>alert(\'XSS\');</script>"'
    ;

DJ_INCLUDE_FILENAME
    : '"./snippet.html"'
    ;

DJ_END_WITH
    : DJ_OPEN 'endwith' DJ_CLOSE
    ;

DJ_START_COMMENT
    : DJ_OPEN 'comment' DJ_CLOSE
    ;

DJ_END_COMMENT
    : DJ_OPEN 'endcomment' DJ_CLOSE
    ;

DJ_END_FOR_LOOP
    : DJ_OPEN 'endfor' DJ_CLOSE
    ;

DJ_START_SPACELESS
    : DJ_OPEN 'spaceless' DJ_CLOSE
    ;

DJ_END_SPACELESS
    : DJ_OPEN 'endspaceless' DJ_CLOSE
    ;

DJ_TEMPLATE_TAG
    : DJ_OPEN 'templatetag ' DJ_TEMPLATE_TAG_OPTION DJ_CLOSE
    ;

DJ_TEMPLATE_TAG_OPTION
    : 'openblock' | 'closeblock' | 'openvariable' | 'closevariable' | 'openbrace' | 'closebrace' | 'opencomment' | 'closecomment'
    ;

DJ_END_BLOCK
    : DJ_OPEN 'endblock' DJ_CLOSE
    ;

DJ_BLOCK_NAME
    : 'name1' | 'name2' | 'name3'
    ;

JSON_FIELD_NAME
    : 'name'
    ;

JSON_FIELD_NAMED_TYPE
    : JSON_QUOTES 'type' JSON_QUOTES
    ;

JSON_FIELD_NAMED_NAME
    : JSON_QUOTES 'name' JSON_QUOTES
    ;

JSON_FIELD_VALUE_BLOCK
    : JSON_QUOTES 'block' JSON_QUOTES
    ;

JSON_FIELD_VALUE_INCLUDE
    : JSON_QUOTES 'include' JSON_QUOTES
    ;

JSON_FIELD_STRING_VALUE
    : 'value'
    ;

JSON_FIELD_LIST_VALUE
    : '["value","value"]'
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
