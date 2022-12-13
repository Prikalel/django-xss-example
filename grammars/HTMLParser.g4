// TEST-PROCESS: {grammar}Parser.g4 {grammar}Lexer.g4 -o {tmpdir}
// TEST-GENERATE: {grammar}Generator.{grammar}Generator -r htmlDocument -s {grammar}Generator.html_space_serializer -n 5 -o {tmpdir}/{grammar}G%d.html
// TEST-GENERATE: {grammar}CustomGenerator.{grammar}CustomGenerator -r htmlDocument -s {grammar}Generator.html_space_serializer -n 5 -o {tmpdir}/{grammar}C%d.html --sys-path ../fuzzer/

parser grammar HTMLParser;

options { tokenVocab=HTMLLexer;
          dot=any_unicode_char;}

@header {
from copy import deepcopy
}

@parser::member {
def _endOfHtmlElement(self):
    pass

}

htmlDocument
    : SEA_WS* htmlElements*
    ;

htmlElements
    : htmlMisc* htmlElement htmlMisc*
    ;

htmlElement
    : TAG_OPEN open_tag=htmlTagName htmlAttribute* TAG_CLOSE htmlContent TAG_OPEN TAG_SLASH htmlTagName {current.last_child = deepcopy($open_tag)} TAG_CLOSE {self._endOfHtmlElement()}
    | TAG_OPEN open_tag=htmlTagName htmlAttribute* TAG_SLASH_CLOSE {self._endOfHtmlElement()}
    | TAG_OPEN open_tag=htmlTagName htmlAttribute* TAG_CLOSE {self._endOfHtmlElement()}
    | script
    | style
    ;

htmlContent
    : htmlChardata? (htmlElement htmlChardata?)*
    ;

htmlAttribute
    : attr_name=htmlAttributeName TAG_EQUALS htmlAttributeValue
    | attr_name=htmlAttributeName
    ;

htmlAttributeName
    : TAG_NAME
    ;

htmlAttributeValue
    : ATTVALUE_VALUE
    ;

htmlTagName
    : TAG_NAME
    ;

htmlChardata
    : HTML_TEXT
    | SEA_WS
    ;

htmlMisc
    : SEA_WS
    ;

script
    : SCRIPT_OPEN ( SCRIPT_BODY | SCRIPT_SHORT_BODY)
    ;

style
    : STYLE_OPEN ( STYLE_BODY | STYLE_SHORT_BODY)
    ;
