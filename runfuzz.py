import django
import os
import logging
import subprocess
import sys
from django.conf import settings
import django
from django.template import Template, Context, loader
from django.template.loader import get_template
from selen import Driver
from progress.bar import IncrementalBar

def django_setup():
    settings.configure(TEMPLATES=[
        {
            'BACKEND': 'django.template.backends.django.DjangoTemplates',
            'DIRS': ['./polls/templates/polls'],
        }
    ])
    django.setup()

def generate_tests(num: int) -> bool: # true if all is good
    bashCommand = f"grammarinator-generate HTMLCustomGenerator.HTMLCustomGenerator -r htmlDocument -d 60 -o ./polls/templates/polls/test_%d.html -n {num} --sys-path ./grammars/fuzzer/"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    return process.wait() == 0

def check_test(num: int, d: Driver) -> bool: # true if found
    found: bool = False
    bar = IncrementalBar('Countdown', max=num)
    for i in range(num):
        output_rendered_name = f"./polls/templates/polls/rendered_test_{i}.html"
        if not found:
            t = get_template(f'test_{i}.html')
            with open(output_rendered_name, "w") as text_file:
                text_file.write(t.render(dict()))
            if d.is_alert_present(output_rendered_name):
                print(output_rendered_name)
                print("Found!!!")
                found = True
                bar.finish()
                continue
            bar.next()
        if os.path.exists(output_rendered_name):
            os.remove(output_rendered_name)
        os.remove(f"./polls/templates/polls/test_{i}.html")

    if not found:
        bar.finish()
    return found

def run():
    d = Driver()
    django_setup()
    num_of_tests = 100
    found: bool = False

    while not found:
        print("Creating new pool...")
        if not generate_tests(num_of_tests):
            print("Error running grammarinator")
            return
        found = check_test(num_of_tests, d)
        if not found:
            print(f"Not found. Have run {num_of_tests} tests...")


if __name__ == "__main__":
    run()
