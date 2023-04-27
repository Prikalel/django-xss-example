import django
import os
import logging
import subprocess
from django.conf import settings
import django
from django.template import Template, TemplateSyntaxError
from django.template.loader import get_template
from prepareactions import PrepareActions
from selen import Driver
from djangocontext import ContextLoader
from progress.bar import IncrementalBar
from grammarinator.generate import *
from mylogger import LoggersSetup

logger = logging.getLogger("runfuzz")

class Fuzzer:
    d: Driver
    g: Generator
    num: int
    total_tests: int
    found: bool = False
    weights = {}

    def __init__(self, tests_per_round=20):
        self.d = Driver()
        self.g = Generator(generator='grammars.fuzzer.HTMLCustomGenerator.HTMLCustomGenerator', rule='htmlDocument', out_format='/home/alex/Документы/django-example/polls/templates/polls/test_%d.html',
                    model='grammarinator.runtime.DefaultModel', max_depth=60, cleanup=False, cooldown=0.5) # TODO: , weights=read_weights("grammars/fuzzer/weights-no-debug.json") <- to use constant weights.
        self.django_setup()
        self.num = tests_per_round
        self.total_tests = 0
        self.found = False
        self.weights = {}

    def django_setup(self):
        settings.configure(TEMPLATES=[
            {
                'BACKEND': 'django.template.backends.django.DjangoTemplates',
                'DIRS': ['./polls/templates/polls'],
            }
        ])
        django.setup()

    def generate_tests(self):
        bar = IncrementalBar('Generate', max=self.num)
        for i in range(self.total_tests, self.total_tests + self.num):
            self.g(i, weights=self.weights)
            bar.next()
        bar.finish()
        return True

    def check_tests(self) -> bool:
        bar = IncrementalBar('Check', max=self.num)
        for i in range(self.total_tests, self.total_tests + self.num):
            template_filepath: str = f"./polls/templates/polls/test_{i}.html"
            output_rendered_name = f"./polls/templates/polls/rendered_test_{i}.html"
            if not self.found:
                ctx = ContextLoader(template_filepath)
                ctx.create_and_modify_files_if_need()
                t: Template = get_template(f'test_{i}.html')
                try:
                    rendered = t.render(ctx.get_context())
                except:
                    bar.finish()
                    logger.error(f"Error rendering template {i}")
                    self.found = True
                    logger.error("Error while trying to found!!!")
                    continue
                with open(output_rendered_name, "w") as text_file:
                    text_file.write(rendered)
                if self.d.is_alert_present(output_rendered_name):
                    bar.finish()
                    self.found = True
                    logger.info("Found!!!")
                    continue
                bar.next()
                ctx.remove_created_files()
            if os.path.exists(output_rendered_name):
                os.remove(output_rendered_name)
            os.remove(template_filepath)

        if not self.found:
            bar.finish()
        return self.found

    def run(self):
        while not self.found:
            logger.info("Creating new pool...")
            self.generate_tests()
            self.check_tests()
            self.total_tests += self.num
            if not self.found:
                logger.info(f"Not found. Have run {self.total_tests} tests...")
        
        logger.info(f"Found in less than {self.total_tests} tests!")


if __name__ == "__main__":
    LoggersSetup.setup_all()
    PrepareActions.do_all()
    Fuzzer().run()
