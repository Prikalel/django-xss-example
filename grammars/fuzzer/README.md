# Weights explaining

Each django rule have its own weight:

```antlr
django
   0 : djangoSpaceless
   5 | djangoWith
   1 | djangoDebug // TODO: remove
   0 | djangoTemplateTag
   0 | djangoNowTag
   1 | djangoBlock
   1 | djangoAutoescape
   1 | djangoAutoEscapeOff
   2 | djangoFilter
   3 | djangoFirstOf
   1 | djangoForEmptyLoop
   1 | {self._hasAtLeastOneCycleVariableDefined()}? djangoResetCycle
   3 | {self._hasAtLeastOneContextListVariableDefined()}? djangoForLoop
   3 | {self._hasAtLeastOneForLoopVariable()}? djangoCycle
   5 | {self._hasAtLeastOneDefinedVariable()}? djangoVariable
   1 | {not self.is_in_comment_section}? djangoIncludeTag {self._startOfCommentedBlock()} djangoCommentedIncludingTemplate {self._endOfCommentedBlock()}
   1 | {not self.is_in_comment_section}? djangoOverriddenBlock {self._startOfCommentedBlock()} djangoCommentedOverridingBlock {self._endOfCommentedBlock()}
    ;
```

As here we have 17 items each weight is translated into probability by dividing by 17.

See file `weights.json`.

## Without debug

To disable `debug` tag there is another file called `weights-no-debug.json`, where (as you can see at item #2) the option debug probability is set to zero.

```diff
--- grammars/fuzzer/weights-no-debug.json       2023-04-27 06:40:34.131928974 +0300
+++ grammars/fuzzer/weights.json        2023-04-27 06:29:58.145430100 +0300
@@ -3,7 +3,7 @@
         "0": {
             "0": 0,
             "1": 0.29,
-            "2": 0,
+            "2": 0.05,
             "3": 0,
             "4": 0,
             "5": 0.05,
```