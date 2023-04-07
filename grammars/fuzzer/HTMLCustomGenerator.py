import json
import random

from os.path import dirname, join
import string
from typing import List

from grammarinator.runtime import *

from grammars.fuzzer.HTMLGenerator import HTMLGenerator
from itertools import chain

with open(join(dirname(__file__), 'html.json')) as f:
    tags = json.load(f)

tag_names = list(tags.keys())


class HTMLCustomGenerator(HTMLGenerator):

    django_context = dict()  # Контекст шаблона.
    last_json_field_name = []  # Буфер для создания новой переменной.
    attr_stack = []  # Валидные значения html-атрибутов.
    tag_stack = []  # Валидные html-тэги и их атрибуты.
    for_variables_stack = []  # Имена переменных, которые используются в for-циклах.
    cycle_variables_stack = []  # Имена, которые используются для сохранения значения cycle внутри for-циклов.
    django_block_names: List[str] = []  # Уникальные имена блоков.
    django_variables_block_stack: List[List[str]] = []  # Введённые через with-блоки переменные django.
    overridden_block_names = []  # Имена блоков для переопределения.
    include_filename: str = ""  # Имя включаемого файла.

    # Очищение всего перед следующим тестом.
    def _flushState(self):
        self.django_context = dict()
        self.last_json_field_name = []
        self.attr_stack = []
        self.tag_stack = [] 
        self.for_variables_stack = [] 
        self.cycle_variables_stack = []  
        self.django_block_names = []
        self.django_variables_block_stack = []
        self.overridden_block_names = []
        self.include_filename = ""

    # Получение случайного значения для контекстной переменной django.
    def __getRandomStringValue(self):
        return random.choice(["123", "<script>alert(\'XSS\');</script>", "<h1>HELLO!</h1>"])

    # Получение случайно сгенерированного списка.
    def __getRandomListValue(self):
        i: int = random.randint(1, 10)
        return [self.__getRandomStringValue() for k in range(i)]

    # Получение контекстных переменных, значение которых является указанным типом.
    def __getContextVariablesOfCertainType(self, type):
        return list(item[0] for item in self.django_context.items() if isinstance(item[1], type))

    @staticmethod
    def __toSingleList(list_of_lists):
        return list(chain.from_iterable(list_of_lists))

    # Получение всех переменных определенных в with-блоках.
    def __getAllDefinedWithVariables(self):
        return self.__toSingleList(self.django_variables_block_stack)

    # Получение всех переменных определённых в cycle-тэгах.
    def __getAllDefinedCycleVariables(self):
        return self.__toSingleList(self.cycle_variables_stack)

    # Генерация уникального имени переменной django-контекста.
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

    # Переменная django-контекста как строка: генерация + сохранение в контекст для дальнейшего использования.
    def jsonStringValue(self, parent=None):
        current = UnparserRule(name='jsonStringValue', parent=parent)
        value = self.__getRandomStringValue()
        UnlexerRule(src=value, parent=current)
        new_field_name = self.last_json_field_name.pop()
        self.django_context[new_field_name] = value
        return current

    # Переменная django-контекста как список строк: генерация + сохранение в контекст для дальнейшего использования.
    def jsonListValue(self, parent=None):
        current = UnparserRule(name='jsonListValue', parent=parent)
        value = self.__getRandomListValue()
        UnlexerRule(src=json.dumps(value), parent=current)
        new_field_name = self.last_json_field_name.pop()
        self.django_context[new_field_name] = value
        return current

    # Валидные имена тэгов.
    def htmlTagName(self, parent=None):
        current = UnparserRule(name='htmlTagName', parent=parent)
        name = random.choice(tags[self.tag_stack[-1]]['children'] or tag_names if self.tag_stack else tag_names)
        self.tag_stack.append(name)
        UnlexerRule(src=name, parent=current)
        return current
    
    # Уникальные имена блоков.
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

    # Уникальные имена блоков + сохранение в стэк имени, так как блок будет переопределён.
    def djangoOverriddenBlockName(self, parent=None):
        current = UnparserRule(name='djangoOverriddenBlockName', parent=parent)
        name_length = 1
        name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
        while name in self.django_block_names:
            name_length += 1
            name = ''.join(random.choice(string.ascii_uppercase) for _ in range(name_length))
        self.django_block_names.append(name)
        self.overridden_block_names.append(name) # абсолютно такой же как djangoBlockName за исключением вот этой вот строчки.
        UnlexerRule(src=name, parent=current)
        return current

    # Сохранение имён переменных django + проверка, чтобы они были уникальными.
    def djangoWithVariable(self, parent=None):
        current = UnparserRule(name='djangoWithVariable', parent=parent)
        name = 'var' + str(sum(map(len, self.django_variables_block_stack)))
        self.django_variables_block_stack[-1].append(name)
        UnlexerRule(src=name, parent=current)
        return current

    # Существующее имя django-переменной из with-блока.
    def djangoDefinedWithVariable(self, parent=None):
        current = UnparserRule(name='djangoDefinedWithVariable', parent=parent)
        django_defined_variable_name = random.choice(self.__getAllDefinedWithVariables())
        UnlexerRule(src=django_defined_variable_name, parent=current)
        return current

    # Существующее имя django-переменной из контекста.
    def djangoDefinedContextVariable(self, parent=None):
        current = UnparserRule(name='djangoDefinedContextVariable', parent=parent)
        django_defined_variable_name = random.choice(self.__getContextVariablesOfCertainType(str))
        UnlexerRule(src=django_defined_variable_name, parent=current)
        return current
    
    # Существующее имя django-переменной из контекста, которая является списком.
    def djangoDefinedContextListVariable(self, parent=None):
        current = UnparserRule(name='djangoDefinedContextListVariable', parent=parent)
        django_defined_variable_name = random.choice(self.__getContextVariablesOfCertainType(list))
        UnlexerRule(src=django_defined_variable_name, parent=current)
        return current

    # Генерируем + сохраняем имя переменной for-loop.
    def djangoForLoopVariableName(self, parent=None):
        current = UnparserRule(name='djangoForLoopVariableName', parent=parent)
        name = 'loop_var' + str(len(self.for_variables_stack))
        UnlexerRule(src=name, parent=current)
        self.for_variables_stack.append(name)
        self.cycle_variables_stack.append([])
        return current

    # Генерируем + сохраняем имя переменной cycle. Это может возникнуть только внутри цикла, поэтому len(cycle_variables_stack) >0.
    def djangoCycleVariableName(self, parent=None):
        current = UnparserRule(name='djangoCycleVariableName', parent=parent)
        name = 'cycle_var' + str(sum(map(len, self.cycle_variables_stack)))
        UnlexerRule(src=name, parent=current)
        self.cycle_variables_stack[-1].append(name)
        return current

    # Существующее имя cycle переменной.
    def djangoDefinedCycleVariable(self, parent=None):
        current = UnparserRule(name='djangoDefinedCycleVariable', parent=parent)
        django_defined_variable_name = random.choice(self.__getAllDefinedCycleVariables())
        UnlexerRule(src=django_defined_variable_name, parent=current)
        return current

    # Имя for-loop переменной.
    def djangoDefinedLoopVariable(self, parent=None):
        current = UnparserRule(name='djangoDefinedLoopVariable', parent=parent)
        django_defined_variable_name = random.choice(self.for_variables_stack)
        UnlexerRule(src=django_defined_variable_name, parent=current)
        return current

    # Имя переопределяемого блока.
    def jsonOverridingBlockName(self, parent=None):
        current = UnparserRule(name='jsonOverridingBlockName', parent=parent)
        django_defined_name = self.overridden_block_names.pop()
        UnlexerRule(src=django_defined_name, parent=current)
        return current
    
    # Имя включаемого файла.
    def jsonIncludingTemplateName(self, parent=None):
        current = UnparserRule(name='jsonIncludingTemplateName', parent=parent)
        UnlexerRule(src=self.include_filename, parent=current)
        self.include_filename = ""
        return current

    # Имя включаемого файла: генерация + сохранение.
    def djangoIncludeFileNameWithQuotes(self, parent=None):
        current = UnparserRule(name='djangoIncludeFileNameWithQuotes', parent=parent)
        name_length = 10
        self.include_filename = "./t_" + ''.join(random.choice(string.ascii_lowercase + string.digits) for _ in range(name_length)) + ".html"
        UnlexerRule(src='"' + self.include_filename + '"', parent=current)
        return current

    # Валидное имя атрибута.
    def htmlAttributeName(self, parent=None):
        current = UnparserRule(name='htmlAttributeName', parent=parent)
        name = random.choice(list(tags[self.tag_stack[-1]]['attributes'].keys()) or ['""'])
        self.attr_stack.append(name)
        UnlexerRule(src=name, parent=current)
        return current

    # Валидные значения атрибутов для текущего тэга и атрибутов.
    def htmlAttributeValue(self, parent=None):
        current = UnparserRule(name='htmlAttributeValue', parent=parent)
        UnlexerRule(src=random.choice(tags[self.tag_stack[-1]]['attributes'].get(self.attr_stack.pop(), ['""']) or ['""']), parent=current)
        return current

    # Конец определения html-тэга.
    def _endOfHtmlElement(self):
        self.tag_stack.pop()

    # Начало django блока with.
    def _startOfDjangoWithBlock(self):
        self.django_variables_block_stack.append([])

    # Конец django блока with.
    def _endOfDjangoWithBlock(self):
        self.django_variables_block_stack.pop()

    # Конец django for-цикла.
    def _endOfDjangoForLoop(self):
        self.for_variables_stack.pop()
        self.cycle_variables_stack.pop()

    # Есть ли хотя бы 1 определенная django-переменная из with-блока, которую можно использовать для вставки.
    def _hasAtLeastOneWithVariableDefined(self) -> bool:
        return len(self.django_variables_block_stack) > 0

    # Есть ли хотя бы 1 определённая строковая django-переменная из контекста.
    def _hasAtLeastOneContextStringVariableDefined(self) -> bool:
        return len(self.__getContextVariablesOfCertainType(str)) > 0
    
    # Есть ли хотя бы 1 определённая django-переменная из контекста, которая является списком.
    def _hasAtLeastOneContextListVariableDefined(self) -> bool:
        return len(self.__getContextVariablesOfCertainType(list)) > 0
    
    # Есть ли хотя бы 1 переменная из цикла.
    def _hasAtLeastOneForLoopVariable(self) -> bool:
        return len(self.for_variables_stack) > 0
    
    # Есть хотя бы 1 cycle-переменная.
    def _hasAtLeastOneCycleVariableDefined(self) -> bool:
        return len(self.__getAllDefinedCycleVariables()) > 0
