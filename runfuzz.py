import django
import os
import logging
import subprocess
from django.conf import settings
import django
from django.template import Template, Context, loader
from django.template.loader import get_template
from selen import Driver
from djangocontext import ContextLoader
from progress.bar import IncrementalBar
from grammarinator.generate import *
from multiprocessing import Pool

logger = logging.getLogger("Fuzzer")

def django_setup():
    settings.configure(TEMPLATES=[
        {
            'BACKEND': 'django.template.backends.django.DjangoTemplates',
            'DIRS': ['./polls/templates/polls'],
        }
    ])
    django.setup()


def generate_tests(num: int, g: Generator):
    jobs = os.cpu_count() # Number of threads to use.
    generator = g
    if jobs > 1:
        with Pool(jobs) as pool:
            for _ in pool.imap_unordered(generator, range(num)):
                pass
            pool.close()
            pool.join()
    else:
        for i in range(num):
            generator(i)
    return True


def check_test(num: int, d: Driver) -> bool:  # true if found
    found: bool = False
    bar = IncrementalBar('Countdown', max=num)
    for i in range(num):
        template_filepath: str = f"./polls/templates/polls/test_{i}.html"
        output_rendered_name = f"./polls/templates/polls/rendered_test_{i}.html"
        if not found:
            t = get_template(f'test_{i}.html')
            ctx = ContextLoader(template_filepath)
            with open(output_rendered_name, "w") as text_file:
                text_file.write(t.render(ctx.get_context()))
            if d.is_alert_present(output_rendered_name):
                bar.finish()
                found = True
                logger.warning("XSS vulnerable example available at: %s", output_rendered_name)
                logger.info("Found!!!")
                continue
            bar.next()
        if os.path.exists(output_rendered_name):
            os.remove(output_rendered_name)
        os.remove(template_filepath)

    if not found:
        bar.finish()
    return found


def run():
    d = Driver()
    g = Generator(generator='grammars.fuzzer.HTMLCustomGenerator.HTMLCustomGenerator', rule='htmlDocument', out_format='/home/alex/Документы/django-example/polls/templates/polls/test_%d.html',
                  model='grammarinator.runtime.DefaultModel', max_depth=60, cleanup=False)
    django_setup()
    num_of_tests = 100
    found: bool = False

    while not found:
        logger.info("Creating new pool...")
        generate_tests(num_of_tests, g)
        found = check_test(num_of_tests, d)
        if not found:
            logger.info(f"Not found. Have run {num_of_tests} tests...")

def prepare_fuzzer():
    logger.info("Preparing fuzzer for generating tests...")
    result = subprocess.run(["grammarinator-process", "grammars/HTMLLexer.g4", "grammars/HTMLParser.g4", "-o", "grammars/fuzzer"], capture_output=True, text=True, check=True, timeout=10)
    logger.info("Fuzzer prepared and grammar is ready!")
    logger.debug('output: %s', result.stdout)
    logger.debug('error: %s', result.stderr)

def setup_logger():
    console_handler = logging.StreamHandler()
    FORMAT = "%(asctime)s — %(name)s — %(levelname)s — %(message)s"
    format = logging.Formatter(FORMAT, validate=True)
    console_handler.setFormatter(format)
    logger.addHandler(console_handler)
    logger.setLevel(logging.DEBUG)


if __name__ == "__main__":
    setup_logger()
    prepare_fuzzer()
    run()
