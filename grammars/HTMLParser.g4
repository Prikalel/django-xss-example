// TEST-PROCESS: {grammar}Parser.g4 {grammar}Lexer.g4 -o {tmpdir}
// TEST-GENERATE: {grammar}Generator.{grammar}Generator -r htmlDocument -s {grammar}Generator.html_space_serializer -n 5 -o {tmpdir}/{grammar}G%d.html
// TEST-GENERATE: {grammar}CustomGenerator.{grammar}CustomGenerator -r htmlDocument -s {grammar}Generator.html_space_serializer -n 5 -o {tmpdir}/{grammar}C%d.html --sys-path ../fuzzer/

parser grammar HTMLParser;

options { tokenVocab=HTMLLexer; language='Python3'; }

@header {
from copy import deepcopy
}

@parser::member {
def _endOfHtmlElement(self):
    pass

def _endOfDjangoWithBlock(self):
    pass

def _startOfDjangoWithBlock(self):
    pass

def _hasAtLeastOneVariableDefined(self) -> bool:
    return False

last_was_django_comment: bool = False
last_was_django_block: bool = False
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
    | {2 * self._hasAtLeastOneVariableDefined()}? djangoVariable
    | {0.2 * (not self.last_was_django_block)}? {self.last_was_django_block = True} djangoBlock {self.last_was_django_block = False}
    | {0.1 * (not self.last_was_django_comment)}? {self.last_was_django_comment = True} djangoComment {self.last_was_django_comment = False}
    ;

djangoDebug
    : DJ_DEBUG
    ;

djangoWith
    : {self._startOfDjangoWithBlock()} DJ_OPEN DJ_WITH_KEYWORD djangoWithVariables+ DJ_CLOSE htmlContent DJ_END_WITH {self._endOfDjangoWithBlock()}
    ;

djangoComment
    : DJ_START_COMMENT htmlContent DJ_END_COMMENT
    ;

djangoBlock
    : DJ_OPEN DJ_BLOCK_KEYWORD djangoBlockName DJ_CLOSE htmlContent DJ_END_BLOCK
    ;

djangoSpaceless
    : DJ_START_SPACELESS htmlContent DJ_END_SPACELESS
    ;

djangoTemplateTag
    : DJ_TEMPLATE_TAG
    ;

djangoWithVariables
    : djangoWithVariable DJ_WITH_EQUALS djangoWithVariableValue DJ_WITH_SPACE
    ;

djangoVariable
    : DJ_VARIABLE_OPEN djangoDefinedVariable DJ_FORCE_ESCAPE_FILTER DJ_VARIABLE_CLOSE
    ;

djangoDefinedVariable
    : DJ_VARIABLE
    ;

djangoWithVariable
    : DJ_VARIABLE
    ;

djangoWithVariableValue
    : DJ_VALUE
    ;

htmlContent
    : htmlChardata? (htmlElement htmlChardata?)*
    ;

htmlAttribute
    : htmlAttributeName TAG_EQUALS htmlAttributeValue
    ;

htmlAttributeName
    : TAG_NAME
    ;

htmlAttributeValue
    : ATTVALUE_VALUE
    ;

djangoBlockName
    : DJ_BLOCK_NAME
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
