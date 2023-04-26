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

def _startOfCommentedBlock(self):
    pass

def _endOfCommentedBlock(self):
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

def _hasAtLeastOneDefinedVariable(self, check_for_with_variables: bool = True) -> bool:
    return (self._hasAtLeastOneContextStringVariableDefined() or 
        (check_for_with_variables and self._hasAtLeastOneWithVariableDefined()) or 
        self._hasAtLeastOneForLoopVariable() or
        self._hasAtLeastOneCycleVariableDefined() or
        self._hasAtLeastOneContextListVariableDefined())

is_in_comment_section: bool = False
is_force_escaped: int = 0
allow_with_variable_using: bool = True
autoescape = [ True ]
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
    //| djangoDebug
    | djangoTemplateTag
    | djangoNowTag
    | djangoBlock
    | djangoAutoescape
    | djangoAutoEscapeOff
    | djangoFilter
    | djangoFirstOf
    | djangoForEmptyLoop
    | {self._hasAtLeastOneCycleVariableDefined()}? djangoResetCycle
    | {self._hasAtLeastOneContextListVariableDefined()}? djangoForLoop
    | {self._hasAtLeastOneForLoopVariable()}? djangoCycle
    | {self._hasAtLeastOneDefinedVariable()}? djangoVariable
    | {not self.is_in_comment_section}? djangoIncludeTag {self._startOfCommentedBlock()} djangoCommentedIncludingTemplate {self._endOfCommentedBlock()}
    | {not self.is_in_comment_section}? djangoOverriddenBlock {self._startOfCommentedBlock()} djangoCommentedOverridingBlock {self._endOfCommentedBlock()}
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

djangoCommentedIncludingTemplate
    : DJ_START_COMMENT djangoCommentedIncludingTemplateInfo htmlElement+ DJ_END_COMMENT
    ;

djangoCommentedOverridingBlockInfo
    : DJ_COMMENT_OPEN JSON_BRACE_OPEN 
      JSON_FIELD_NAMED_TYPE JSON_COLON JSON_FIELD_VALUE_BLOCK JSON_COMMA 
      JSON_FIELD_NAMED_NAME JSON_COLON JSON_QUOTES jsonOverridingBlockName JSON_QUOTES 
      JSON_BRACE_CLOSE DJ_COMMENT_CLOSE
    ;

djangoCommentedIncludingTemplateInfo
    : DJ_COMMENT_OPEN JSON_BRACE_OPEN 
      JSON_FIELD_NAMED_TYPE JSON_COLON JSON_FIELD_VALUE_INCLUDE JSON_COMMA 
      JSON_FIELD_NAMED_NAME JSON_COLON JSON_QUOTES jsonIncludingTemplateName JSON_QUOTES 
      JSON_BRACE_CLOSE DJ_COMMENT_CLOSE
    ;

jsonOverridingBlockName
    : DJ_BLOCK_NAME
    ;

jsonIncludingTemplateName
    : JSON_FIELD_STRING_VALUE
    ;

djangoOverriddenBlock
    : DJ_OPEN DJ_BLOCK_KEYWORD djangoOverriddenBlockName DJ_CLOSE htmlContent DJ_END_BLOCK
    ;

djangoIncludeTag
    : DJ_OPEN DJ_INCLUDE_KEYWORD djangoIncludeFileNameWithQuotes DJ_CLOSE
    ;

djangoBlock
    : DJ_OPEN DJ_BLOCK_KEYWORD djangoBlockName DJ_CLOSE htmlContent DJ_END_BLOCK
    ;

djangoAutoescape
    : {self.autoescape.append(True)} DJ_OPEN DJ_AUTOESCAPE_ON DJ_CLOSE htmlContent DJ_OPEN DJ_END_AUTOESCAPE DJ_CLOSE {self.autoescape.pop()}
    ;

djangoAutoEscapeOff
    : {self.autoescape.append(False)} DJ_OPEN DJ_AUTOESCAPE_OFF DJ_CLOSE htmlContent DJ_OPEN DJ_END_AUTOESCAPE DJ_CLOSE {self.autoescape.pop()}
    ;

djangoFilter
    : {self.is_force_escaped += 1} DJ_OPEN DJ_FILTER_KEYWORD escapingFilter (DJ_FILTER_SIGN filter)* DJ_CLOSE htmlContent DJ_OPEN DJ_END_FILTER DJ_CLOSE {self.is_force_escaped -= 1}
    | DJ_OPEN DJ_FILTER_KEYWORD filter (DJ_FILTER_SIGN filter)* DJ_CLOSE htmlContent DJ_OPEN DJ_END_FILTER DJ_CLOSE
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

djangoForEmptyLoop
    : {self._hasAtLeastOneContextListVariableDefined()}? DJ_OPEN DJ_FOR_KEYWORD djangoForLoopVariableName DJ_FOR_IN_KEYWORD djangoDefinedContextListVariable DJ_CLOSE htmlContent DJ_EMPTY_FOR_LOOP {self._endOfDjangoForLoop()} htmlContent DJ_END_FOR_LOOP
    | DJ_OPEN DJ_FOR_KEYWORD DJ_VARIABLE DJ_FOR_IN_KEYWORD undefinedListVariable DJ_CLOSE htmlContent DJ_EMPTY_FOR_LOOP htmlContent DJ_END_FOR_LOOP
    ;

djangoResetCycle
    : DJ_OPEN DJ_RESETCYCLE_KEYWORD djangoDefinedCycleVariable DJ_CLOSE
    ;

djangoCycle
    : DJ_OPEN DJ_CYCLE_KEYWORD djangoEscapedVariable (DJ_FILTER_SIGN filter)* DJ_SPACE (djangoEscapedVariable (DJ_FILTER_SIGN filter)* DJ_SPACE)+ (DJ_AS_KEYWORD djangoCycleVariableName)? DJ_CLOSE
    ;

djangoWithVariables
    : djangoWithVariable DJ_WITH_EQUALS djangoWithVariableValue DJ_SPACE
    ;

djangoFirstOf
    : DJ_OPEN DJ_FIRSTOF_KEYWORD (djangoFirstOfVariable (DJ_FILTER_SIGN filter)* DJ_SPACE)+ DJ_CLOSE
    ;

djangoFirstOfVariable
    : djangoEscapedVariable
    | DJ_VARIABLE
    ;

djangoEscapedVariable
    : {self.is_force_escaped > 0}? DJ_VALUE
    | DJ_VALUE DJ_FILTER_SIGN escapingFilter
    | {self._hasAtLeastOneDefinedVariable(check_for_with_variables=self.is_force_escaped > 0) and self.autoescape[-1]}? {self.allow_with_variable_using = self.is_force_escaped > 0} djangoDefinedVariable {self.allow_with_variable_using = True}
    | {self._hasAtLeastOneDefinedVariable(check_for_with_variables=self.is_force_escaped > 0)}? {self.allow_with_variable_using = self.is_force_escaped > 0} djangoDefinedVariable DJ_FILTER_SIGN DJ_ESCAPE_FILTER {self.allow_with_variable_using = True}
    | {self._hasAtLeastOneWithVariableDefined()}? djangoDefinedWithVariable DJ_FILTER_SIGN escapingFilter
    ;

djangoVariable
    : {self.is_force_escaped == 0}? DJ_VARIABLE_OPEN djangoDefinedVariable DJ_FILTER_SIGN escapingFilter (DJ_FILTER_SIGN filter)* DJ_VARIABLE_CLOSE
    | {self.is_force_escaped > 0}? DJ_VARIABLE_OPEN djangoDefinedVariable (DJ_FILTER_SIGN (filter|escapingFilter))* DJ_VARIABLE_CLOSE
    | {self.autoescape[-1] and self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable
    | {self.autoescape[-1] and self._hasAtLeastOneForLoopVariable()}? djangoDefinedLoopVariable
    | {self.autoescape[-1] and self._hasAtLeastOneContextListVariableDefined()}? djangoDefinedContextListVariable DJ_FILTER_SIGN listToSingleFilter
    | {not self.autoescape[-1] and self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable DJ_FILTER_SIGN DJ_ESCAPE_FILTER
    | {not self.autoescape[-1] and self._hasAtLeastOneForLoopVariable()}? djangoDefinedLoopVariable DJ_FILTER_SIGN DJ_ESCAPE_FILTER
    | {not self.autoescape[-1] and self._hasAtLeastOneContextListVariableDefined()}? djangoDefinedContextListVariable DJ_FILTER_SIGN listToSingleFilter DJ_FILTER_SIGN DJ_ESCAPE_FILTER
    ;

djangoDefinedVariable
    : {self._hasAtLeastOneWithVariableDefined() and self.allow_with_variable_using}? djangoDefinedWithVariable
    | {self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable
    | {self._hasAtLeastOneForLoopVariable()}? djangoDefinedLoopVariable
    | {self._hasAtLeastOneCycleVariableDefined()}? djangoDefinedCycleVariable
    | {self._hasAtLeastOneContextListVariableDefined()}? djangoDefinedContextListVariable DJ_FILTER_SIGN listToSingleFilter
    ;

djangoIncludeFileNameWithQuotes
    : DJ_INCLUDE_FILENAME
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

djangoWithVariableValue
    : {self._hasAtLeastOneContextStringVariableDefined()}? djangoDefinedContextVariable
    | {self._hasAtLeastOneContextListVariableDefined()}? djangoDefinedContextListVariable DJ_FILTER_SIGN listToSingleFilter
    | DJ_VALUE
    ;

undefinedListVariable
    : DJ_UNDEFINED_LIST_VARIABLE
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

filter
    : DJ_LOWER_FILTER
    | DJ_UPPER_FILTER
    | DJ_ADDSLASHES_FILTER
    | DJ_CAPFIRST_FILTER
    | DJ_CENTER_FILTER
    | DJ_CUT_FILTER
    | DJ_LINEBREAKS_FILTER
    | DJ_LINEBREAKSSBR_FILTER
    | DJ_LINENUMBERS_FILTER
    | DJ_SLUGIFY_FILTER
    | DJ_TITLE_FILTER
    | DJ_WORDCOUNT_FILTER DJ_FILTER_SIGN DJ_STRINGFORMAT_INT_TO_STRING_FILTER // добавляем конвретацию из числа в строку.
    | DJ_WORDWRAP_FILTER
    | DJ_TRUNCATE_FILTER
    | DJ_SCRIPTAGS_FILTER
    | DJ_LJUST_FILTER
    | DJ_RJUST_FILTER
    | DJ_MAKE_LIST_FILTER DJ_FILTER_SIGN listToSingleFilter
    | DJ_LENGTH_FILTER DJ_FILTER_SIGN DJ_STRINGFORMAT_INT_TO_STRING_FILTER
    | DJ_ESCAPEJS_FILTER
    ;

listToSingleFilter
    : DJ_FIRST_FILTER_FROM_LIST
    | DJ_LAST_FILTER_FROM_LIST
    | DJ_RANDOM_FILTER_FROM_LIST
    | DJ_JOIN_FILTER_FROM_LIST
    | DJ_LENGTH_FILTER DJ_FILTER_SIGN DJ_STRINGFORMAT_INT_TO_STRING_FILTER
    | DJ_SLICE_FILTER_FROM_LIST_TO_LIST DJ_FILTER_SIGN listToSingleFilter
    ;

escapingFilter
    : DJ_FORCE_ESCAPE_FILTER
    | DJ_SCRIPTAGS_FILTER
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
