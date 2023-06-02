# Проверка у себя

Работает только на linux. На windows одна из зависимостей может вызвать ошибку.

Перед запуском необходимо установить следующие пакеты:

```bash
pip install -r requirements.txt
```

### Следует убедиться, что установились пакеты

```bash
python -m django --version  # pip install django==4.0.1
grammarinator-generate --version  # pip install git+https://github.com/renatahodovan/grammarinator.git#egg=grammarinator
```

### Подготовить фаззер

```bash
touch grammars/fuzzer/HTMLGenerator.py  # Создаём пустой файл, который будет наполнен генератом
grammarinator-process grammars/HTMLLexer.g4 grammars/HTMLParser.g4 -o grammars/fuzzer  # Заполнение файла
```

### Запуск фаззера

```bash
python runfuzz.py
```

# Ошибка

Нужно будет пропатчить один файл из django, поскольку он может вызвать ошибку шаблонизатора, что остановит процесс фаззинга:

```diff
--- /home/alex/.local/lib/python3.9/site-packages/django/template/defaultfilters.py     2023-04-26 12:47:44.387239988 +0300
+++ /home/alex/.local/lib/python3.9/site-packages/django/template/defaultfilters-fixed.py       2023-04-26 12:47:33.931039539 +0300
@@ -613,7 +613,10 @@
 @register.filter(is_safe=True)
 def random(value):
     """Return a random item from the list."""
-    return random_module.choice(value)
+    try:
+        return random_module.choice(value)
+    except IndexError:
+        return ''
 
 
 @register.filter("slice", is_safe=True)
```

Если используете venv, то путь может быть таким: `venv/lib/python3.9/site-packages/django/template/defaultfilters.py`

Если устанавливали пакеты в систему, то путь: `$HOME/.local/lib/python3.9/site-packages/django/template/defaultfilters.py`

Надо зайти во внутрь файла и найти определение тэга `random` и окружить его в try-catch блок. 

Если это не сделать, фаззер завершит свою работу при обнаружении [этого бага](https://code.djangoproject.com/ticket/34518).

# Benchmark

### Required tests count to find a bug

| Bug                | Plain fuzzer  | Fixed weights mode                       | Cooldown 0.5            |
|--------------------|---------------|------------------------------------------|-------------------------|
| debug              | 20            | 20                                       |                         |
| join-escape-filter | 1000+         | 560/3520(88s)/40/740(28s)/1800(51s)      | 20/900/220/760(530s)    |
