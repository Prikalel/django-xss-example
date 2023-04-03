# Copyright (c) 2017-2021 Renata Hodovan, Akos Kiss.
#
# Licensed under the BSD 3-Clause License
# <LICENSE.rst or https://opensource.org/licenses/BSD-3-Clause>.
# This file may not be copied, modified, or distributed except
# according to those terms.

import json
import random

from os.path import dirname, join
import string

from grammarinator.runtime import *

from grammars.fuzzer.HTMLGenerator import HTMLGenerator


with open(join(dirname(__file__), 'html.json')) as f:
    tags = json.load(f)

tag_names = list(tags.keys())


class HTMLCustomGenerator(HTMLGenerator):

    attr_stack = []
    tag_stack = []
    last_was_django_comment: bool
    django_block_names = []

    # Customize the function generated from the htmlTagName parser rule to produce valid tag names.
    def htmlTagName(self, parent=None):
        current = UnparserRule(name='htmlTagName', parent=parent)
        name = random.choice(tags[self.tag_stack[-1]]['children'] or tag_names if self.tag_stack else tag_names)
        self.tag_stack.append(name)
        UnlexerRule(src=name, parent=current)
        return current
    
    def djangoBlockName(self, parent=None):
        current = UnparserRule(name='djangoBlockName', parent=parent)
        name_length = 1
        name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(name_length))
        while name in self.django_block_names:
            name = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(name_length))
            name_length += 1
        self.django_block_names.append(name)
        UnlexerRule(src=name, parent=current)
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
