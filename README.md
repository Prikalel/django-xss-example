# Run tests on django

```
python runfuzz.py
```

### To run django server:

```
python manage.py runserver
```

### Check the python modules are installed:

```
python3 -m django --version
grammarinator-generate --version
pip install selenium # should be installed
pip install webdriver-manager # also
pip install progress
```

### Prepare fuzzer and check that all is ok

In grammars folder:

```
touch fuzzer/HTMLGenerator.py  # Otherwise it will not find the file
grammarinator-process HTMLLexer.g4 HTMLParser.g4 -o fuzzer  # Fill the file
```

Try fuzzer:

```
grammarinator-generate HTMLCustomGenerator.HTMLCustomGenerator -r htmlDocument -d 20 -o examples/test_%d.html -n 10 --sys-path ./fuzzer/
cd examples 
python -m http.server # start the server
```

