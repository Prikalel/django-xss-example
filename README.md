# Run tests on django

```bash
python runfuzz.py
```

### To run django server:

```bash
python manage.py runserver
```

### Check the python modules are installed:

```bash
python3 -m django --version  # pip install django==4.0.1
grammarinator-generate --version  # pip install grammarinator
pip install selenium  # should be installed
pip install webdriver-manager  # also
pip install progress
```

### Prepare fuzzer and check that all is ok

```bash
touch grammars/fuzzer/HTMLGenerator.py  # Otherwise it will not find the file
grammarinator-process grammars/HTMLLexer.g4 grammars/HTMLParser.g4 -o grammars/fuzzer  # Fill the file
```

Try fuzzer:

```bash
grammarinator-generate grammars.fuzzer.HTMLCustomGenerator.HTMLCustomGenerator -r htmlDocument -d 20 -o grammars/examples/test_%d.html -n 10 --sys-path ./
cd grammars/examples/
ls # Here is your files.
python -m http.server # start the server
```

### Patch

To work on you need a django 4.0.1 with patched `random` tag:

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

# Benchmark

### Required tests count to find a bug

| Bug                | Default mode | Fixed weights mode |
|--------------------|--------------|--------------------|
| debug              | 20           | 20                 |
| join-escape-filter | 2340         | 560                |
