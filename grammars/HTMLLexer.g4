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

DJ_FILTER_KEYWORD
    : 'filter '
    ;

DJ_END_FILTER
    : 'endfilter'
    ;

DJ_FILTER_SIGN
    : '|'
    ;

DJ_FORCE_ESCAPE_FILTER
    : 'force_escape'
    ;

DJ_ESCAPE_FILTER
    : 'escape'
    ;

DJ_LOWER_FILTER
    : 'lower'
    ;

DJ_UPPER_FILTER
    : 'upper'
    ;

DJ_ESCAPEJS_FILTER
    : 'escapejs'
    ;

DJ_ADDSLASHES_FILTER
    : 'addslashes'
    ;

DJ_CAPFIRST_FILTER
    : 'capfirst'
    ;

DJ_CENTER_FILTER
    : 'center:"1"'
    | 'center:"2"'
    | 'center:"3"'
    ;

DJ_CUT_FILTER
    : 'cut:" "'
    | 'cut:"a"'
    | 'cut:":"'
    ;

DJ_LINEBREAKS_FILTER
    : 'linebreaks'
    ;

DJ_LINEBREAKSSBR_FILTER
    : 'linebreaksbr'
    ;

DJ_LINENUMBERS_FILTER
    : 'linenumbers'
    ;

DJ_SLUGIFY_FILTER
    : 'slugify'
    ;

DJ_TITLE_FILTER
    : 'title'
    ;

DJ_WORDCOUNT_FILTER
    : 'wordcount'
    ;

DJ_WORDWRAP_FILTER
    : 'wordwrap:5'
    | 'wordwrap:10'
    | 'wordwrap:1'
    ;

DJ_TRUNCATE_FILTER
    : 'truncatechars:7'
    | 'truncatechars:1'
    | 'truncatechars:20'
    | 'truncatechars_html:7'
    | 'truncatechars_html:1'
    | 'truncatechars_html:20'
    | 'truncatewords:2'
    | 'truncatewords:1'
    | 'truncatewords:5'
    | 'truncatewords_html:2'
    | 'truncatewords_html:1'
    | 'truncatewords_html:5'
    ;

DJ_SCRIPTAGS_FILTER
    : 'striptags'
    ;

DJ_LJUST_FILTER
    : 'ljust:"10"'
    | 'ljust:"20"'
    | 'ljust:"1"'
    ;

DJ_RJUST_FILTER
    : 'rjust:"10"'
    | 'rjust:"20"'
    | 'rjust:"1"'
    ;

DJ_MAKE_LIST_FILTER
    : 'make_list'
    ;

DJ_LENGTH_FILTER
    : 'length'
    ;

DJ_FIRST_FILTER_FROM_LIST
    : 'first'
    ;

DJ_LAST_FILTER_FROM_LIST
    : 'last'
    ;

DJ_RANDOM_FILTER_FROM_LIST
    : 'random'
    ;

DJ_JOIN_FILTER_FROM_LIST
    : 'join:" "'
    | 'join:","'
    | 'join:"  //  "'
    ;

DJ_SLICE_FILTER_FROM_LIST_TO_LIST
    : 'slice:":2"'
    | 'slice:"-2:"'
    | 'slice:"1:3"'
    | 'slice:"1:-1"'
    | 'slice:"0:3"'
    | 'slice:"3:"'
    | 'slice:":"'
    ;

DJ_STRINGFORMAT_INT_TO_STRING_FILTER
    : 'stringformat:"i"'
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

DJ_EMPTY_KEYWORD
    : 'empty'
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

DJ_AUTOESCAPE_OFF
    : 'autoescape off'
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

DJ_EMPTY_FOR_LOOP
    : DJ_OPEN DJ_EMPTY_KEYWORD DJ_CLOSE
    ;

DJ_SPACE
    : ' '
    ;

DJ_VARIABLE
    : 'var_a' | 'var_b' | 'var_c' | 'somename'
    ;

DJ_UNDEFINED_LIST_VARIABLE
    : 'list_var_a' | 'list_var_b' | 'list_var_c'
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

// tag declarations
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

// lexing mode for attribute values
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

// attribute values
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
