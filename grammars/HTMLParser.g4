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

def _endOfDjangoForLoop(self):
    pass

def _startOfDjangoWithBlock(self):
    pass

def _flushState(self):
    pass

def _hasAtLeastOneWithVariableDefined(self) -> bool:
    return False

def _hasAtLeastOneContextStringVariableDefined(self) -> bool:
    return False

def _hasAtLeastOneForLoopVariable(self) -> bool:
    return False

def _hasAtLeastOneContextListVariableDefined(self) -> bool:
    return False

def _hasAtLeastOneCycleVariableDefined(self) -> bool:
    return False

def _hasAtLeastOneDefinedVariable(self) -> bool:
    return (self._hasAtLeastOneContextStringVariableDefined() or 
        self._hasAtLeastOneWithVariableDefined() or 
        self._hasAtLeastOneForLoopVariable() or
        self._hasAtLeastOneCycleVariableDefined())

is_in_comment_section: bool = False
}

htmlDocument
    : {self._flushState()} djangoContext NEWLINE htmlElements+
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
    | djangoNowTag
    | {self._hasAtLeastOneContextListVariableDefined()}? djangoForLoop
    | {self._hasAtLeastOneForLoopVariable()}? djangoCycle
    | {self._hasAtLeastOneDefinedVariable()}? djangoVariable
    | djangoBlock
    | {not self.is_in_comment_section}? djangoOverriddenBlock {self.is_in_comment_section = True} djangoCommentedOverridingBlock {self.is_in_comment_section = False}
    ;

djangoDebug
    : DJ_DEBUG
    ;

djangoWith
    : {self._startOfDjangoWithBlock()} DJ_OPEN DJ_WITH_KEYWORD djangoWithVariables+ DJ_CLOSE htmlContent DJ_END_WITH {self._endOfDjangoWithBlock()}
    ;

djangoCommentedOverridingBlock
    : DJ_START_COMMENT djangoCommentedOverridingBlockInfo htmlElement+ DJ_END_COMMENT
    ;

djangoCommentedOverridingBlockInfo
    : DJ_COMMENT_OPEN JSON_BRACE_OPEN 
      JSON_FIELD_NAMED_TYPE JSON_COLON JSON_FIELD_VALUE_BLOCK JSON_COMMA 
      JSON_FIELD_NAMED_NAME JSON_COLON JSON_QUOTES jsonOverridingBlockName JSON_QUOTES 
      JSON_BRACE_CLOSE DJ_COMMENT_CLOSE
    ;

jsonOverridingBlockName
    : DJ_BLOCK_NAME
    ;

djangoOverriddenBlock
    : DJ_OPEN DJ_BLOCK_KEYWORD djangoOverriddenBlockName DJ_CLOSE htmlContent DJ_END_BLOCK
    ;

djangoBlock
    : DJ_OPEN DJ_BLOCK_KEYWORD djangoBlockName DJ_CLOSE htmlContent DJ_END_BLOCK
    ;

djangoSpaceless
    : DJ_START_SPACELESS htmlContent DJ_END_SPACELESS
    ;

djangoNowTag
    : DJ_OPEN DJ_NOW DJ_NOW_FORMAT DJ_CLOSE
    ;

djangoTemplateTag
    : DJ_TEMPLATE_TAG
    ;

djangoForLoop
    : DJ_OPEN DJ_FOR_KEYWORD djangoForLoopVariableName DJ_FOR_IN_KEYWORD djangoDefinedContextListVariable DJ_CLOSE NEWLINE htmlContent NEWLINE DJ_END_FOR_LOOP {self._endOfDjangoForLoop()}
    ;

djangoCycle
    : DJ_OPEN DJ_CYCLE_KEYWORD djangoCycleValue DJ_SPACE (djangoCycleValue DJ_SPACE)+ (DJ_AS_KEYWORD djangoCycleVariableName)? DJ_CLOSE
    ;

djangoCycleValue
    : {self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable
    | {self._hasAtLeastOneWithVariableDefined()}? djangoDefinedWithVariable
    | djangoCycleStringValue
    ;

djangoWithVariables
    : djangoWithVariable DJ_WITH_EQUALS djangoWithVariableValue DJ_SPACE
    ;

djangoVariable
    : DJ_VARIABLE_OPEN djangoDefinedVariable DJ_FORCE_ESCAPE_FILTER DJ_VARIABLE_CLOSE
    ;

djangoDefinedVariable
    : {self._hasAtLeastOneWithVariableDefined()}? djangoDefinedWithVariable
    | {self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable
    | {self._hasAtLeastOneForLoopVariable()}? djangoDefinedLoopVariable
    | {self._hasAtLeastOneCycleVariableDefined()}? djangoDefinedCycleVariable
    ;

djangoDefinedLoopVariable
    : DJ_VARIABLE
    ;

djangoForLoopVariableName
    : DJ_VARIABLE
    ;

djangoDefinedContextListVariable
    : DJ_VARIABLE
    ;

djangoDefinedWithVariable
    : DJ_VARIABLE
    ;

djangoDefinedContextVariable
    : DJ_VARIABLE
    ;

djangoDefinedCycleVariable
    : DJ_VARIABLE
    ;

djangoCycleVariableName
    : DJ_VARIABLE
    ;

djangoWithVariable
    : DJ_VARIABLE
    ;

djangoCycleStringValue
    : DJ_VALUE
    ;

djangoWithVariableValue
    : {self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable
    | DJ_VALUE
    ;

htmlContent
    : htmlChardata? (htmlElement htmlChardata?)*
    ;

htmlAttribute
    : htmlAttributeName TAG_EQUALS htmlAttributeValue
    ;

djangoContext
    : DJ_COMMENT_OPEN JSON_BRACE_OPEN djangoContextVariableDefinition (JSON_COMMA djangoContextVariableDefinition)* JSON_BRACE_CLOSE DJ_COMMENT_CLOSE
    ;

djangoContextVariableDefinition
    : JSON_QUOTES jsonFieldName JSON_QUOTES JSON_COLON jsonFieldValue
    ;

jsonFieldName
    : JSON_FIELD_NAME
    ;

jsonFieldValue
    : JSON_QUOTES jsonStringValue JSON_QUOTES
    | jsonListValue
    ;

jsonStringValue
    : JSON_FIELD_STRING_VALUE
    ;

jsonListValue
    : JSON_FIELD_LIST_VALUE
    ;

htmlAttributeName
    : TAG_NAME
    ;

htmlAttributeValue
    : ATTVALUE_VALUE
    ;

djangoOverriddenBlockName
    : DJ_BLOCK_NAME
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
