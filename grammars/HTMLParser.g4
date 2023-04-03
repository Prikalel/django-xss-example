// TEST-PROCESS: {grammar}Parser.g4 {grammar}Lexer.g4 -o {tmpdir}
// TEST-GENERATE: {grammar}Generator.{grammar}Generator -r htmlDocument -s {grammar}Generator.html_space_serializer -n 5 -o {tmpdir}/{grammar}G%d.html
// TEST-GENERATE: {grammar}CustomGenerator.{grammar}CustomGenerator -r htmlDocument -s {grammar}Generator.html_space_serializer -n 5 -o {tmpdir}/{grammar}C%d.html --sys-path ../fuzzer/

parser grammar HTMLParser;

options { tokenVocab=HTMLLexer;}

@header {
from copy import deepcopy
}

@parser::member {
def _endOfHtmlElement(self):
    pass

last_was_django_comment: bool = False
}

htmlDocument
    : htmlElements+
    ;

htmlElements
    : htmlElement htmlMisc
    ;

htmlElement
    : TAG_OPEN open_tag=htmlTagName TAG_WHITESPACE htmlAttribute? TAG_CLOSE htmlContent TAG_OPEN TAG_SLASH htmlTagName {current.last_child = deepcopy($open_tag)} TAG_CLOSE {self._endOfHtmlElement()}
    | django
    ;

django
    : djangoSpaceless
    | djangoWith
    | djangoDebug
    | djangoTemplateTag
    | {0.1 * (not self.last_was_django_comment)}? {self.last_was_django_comment = True} djangoComment {self.last_was_django_comment = False}
    ;

djangoDebug
    : DJ_DEBUG
    ;

djangoWith
    : DJ_START_WITH htmlContent DJ_END_WITH
    ;

djangoComment
    : DJ_START_COMMENT htmlContent DJ_END_COMMENT
    ;

djangoSpaceless
    : DJ_START_SPACELESS htmlContent DJ_END_SPACELESS
    ;

djangoTemplateTag
    : DJ_TEMPLATE_TAG
    ;

htmlContent
    : htmlChardata? (htmlElement htmlChardata?)*
    ;

htmlAttribute
    : attr_name=htmlAttributeName TAG_EQUALS htmlAttributeValue
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
    : HTML_TEXT NEWLINE
    ;

htmlMisc
    : NEWLINE
    ;
