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

