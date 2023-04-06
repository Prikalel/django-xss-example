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

    django_context = dict()  # Контекст шаблона.
    last_json_field_name = []  # Буфер для создания новой переменной.
    attr_stack = []  # Валидные значения html-атрибутов
    tag_stack = []  # Валидные html-тэги и их атрибуты
    django_block_names: List[str] = []  # Уникальные имена блоков
    django_variables_block_stack: List[List[str]] = []  # Введённые через with-блоки переменные django.

    # Получение случайного значения для контекстной переменной django.
    def __getRandomStringValue(self):
        return random.choice(["123", "<script>alert(\'XSS\');</script>", "<h1>HELLO!</h1>"])

    # Получение случайно сгенерированного списка.
    def __getRandomListValue(self):
        i: int = random.randint(1, 10)
        return [self.__getRandomStringValue() for k in range(i)]

    # Customize the function generated from the jsonFieldName parser rule to produce valid json field names and store them.
    def jsonFieldName(self, parent=None):
        current = UnparserRule(name='jsonFieldName', parent=parent)
        name_length = 1
        name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
        while name in self.django_context.keys():
            name_length += 1
            name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
        UnlexerRule(src=name, parent=current)
        self.last_json_field_name.append(name)
        return current

    # Customize the function generated from the jsonStringValue parser rule to store json field value.
    def jsonStringValue(self, parent=None):
        current = UnparserRule(name='jsonStringValue', parent=parent)
        value = self.__getRandomStringValue()
        UnlexerRule(src=value, parent=current)
        new_field_name = self.last_json_field_name.pop()
        self.django_context[new_field_name] = value
        return current

    # Customize the function generated from the jsonListValue parser rule to generate and store json field value as list.
    def jsonListValue(self, parent=None):
        current = UnparserRule(name='jsonListValue', parent=parent)
        value = self.__getRandomListValue()
        UnlexerRule(src=json.dumps(value), parent=current)
        new_field_name = self.last_json_field_name.pop()
        self.django_context[new_field_name] = value
        return current

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
            name_length += 1
            name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
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