import json
import random

from os.path import dirname, join
import string
from typing import List

from grammarinator.runtime import *

from grammars.fuzzer.HTMLGenerator import HTMLGenerator


with open(join(dirname(__file__), 'html.json')) as f:
    tags = json.load(f)

tag_names = list(tags.keys())


class HTMLCustomGenerator(HTMLGenerator):

    attr_stack = []
    tag_stack = []
    last_was_django_comment: bool
    django_block_names: List[str] = []
    django_variables_block_stack: List[List[str]] = []

    # Customize the function generated from the htmlTagName parser rule to produce valid tag names.
    def htmlTagName(self, parent=None):
        current = UnparserRule(name='htmlTagName', parent=parent)
        name = random.choice(tags[self.tag_stack[-1]]['children'] or tag_names if self.tag_stack else tag_names)
        self.tag_stack.append(name)
        UnlexerRule(src=name, parent=current)
        return current
    
    # Customize the function generated from the djangoBlockName parser rule to produce unique block names.
    def djangoBlockName(self, parent=None):
        current = UnparserRule(name='djangoBlockName', parent=parent)
        name_length = 1
        name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
        while name in self.django_block_names:
            name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
            name_length += 1
        self.django_block_names.append(name)
        UnlexerRule(src=name, parent=current)
        return current

    # Customize the function generated from the djangoWithVariable parser rule to produce variable names and save them to stack.
    def djangoWithVariable(self, parent=None):
        current = UnparserRule(name='djangoWithVariable', parent=parent)
        name = 'var' + str(sum(map(len, self.django_variables_block_stack)))
        self.django_variables_block_stack[-1].append(name)
        UnlexerRule(src=name, parent=current)
        return current

    def djangoDefinedVariable(self, parent=None):
        current = UnparserRule(name='djangoDefinedVariable', parent=parent)
        django_variable_stack = random.choice(self.django_variables_block_stack)
        django_defined_variable_name = random.choice(django_variable_stack)
        UnlexerRule(src=django_defined_variable_name, parent=current)
        return current

    # Customize the function generated from the htmlAttributeName parser rule to produce valid attribute names.
    def htmlAttributeName(self, parent=None):
        current = UnparserRule(name='htmlAttributeName', parent=parent)
        name = random.choice(list(tags[self.tag_stack[-1]]['attributes'].keys()) or ['""'])
        self.attr_stack.append(name)
        UnlexerRule(src=name, parent=current)
        return current

    # Customize the function generated from the htmlAttributeValue parser rule to produce valid attribute values
    # to the current tag and attribute name.
    def htmlAttributeValue(self, parent=None):
        current = UnparserRule(name='htmlAttributeValue', parent=parent)
        UnlexerRule(src=random.choice(tags[self.tag_stack[-1]]['attributes'].get(self.attr_stack.pop(), ['""']) or ['""']), parent=current)
        return current

    def _endOfHtmlElement(self):
        self.tag_stack.pop()

    def _startOfDjangoWithBlock(self):
        self.django_variables_block_stack.append([])

    def _endOfDjangoWithBlock(self):
        self.django_variables_block_stack.pop()
        
    def _hasAtLeastOneVariableDefined(self) -> bool:
        return len(self.django_variables_block_stack) > 0