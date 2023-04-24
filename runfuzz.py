import django
import os
import logging
import subprocess
from django.conf import settings
import django
from django.template import Template, Context, TemplateSyntaxError, loader
from django.template.loader import get_template
from selen import Driver
from djangocontext import ContextLoader
from progress.bar import IncrementalBar
from grammarinator.generate import *
from multiprocessing import Pool
from mylogger import setup_logger

logger = logging.getLogger("Fuzzer")

def django_setup():
    settings.configure(TEMPLATES=[
        {
            'BACKEND': 'django.template.backends.django.DjangoTemplates',
            'DIRS': ['./polls/templates/polls'],
        }
    ])
    django.setup()


def generate_tests(total_tests: int, num: int, g: Generator):
    bar = IncrementalBar('Generate', max=num)
    for i in range(total_tests, total_tests + num):
        g(i)
        bar.next()
    bar.finish()
    return True


def check_test(total_tests: int, num: int, d: Driver) -> bool:
    """Проверяет тесты.

    :param total_tests: Суммарное число тестов не включая новые num тестов.
    :type total_tests: int
    :param num: Кол-во тестов.
    :type num: int
    :param d: Драйвер проверки.
    :type d: Driver
    :return: True если нашёл.
    :rtype: bool
    """
    found: bool = False
    bar = IncrementalBar('Check', max=num)
    for i in range(total_tests, total_tests + num):
        template_filepath: str = f"./polls/templates/polls/test_{i}.html"
        output_rendered_name = f"./polls/templates/polls/rendered_test_{i}.html"
        if not found:
            ctx = ContextLoader(template_filepath)
            ctx.create_and_modify_files_if_need()
            t = get_template(f'test_{i}.html')
            try:
                rendered = t.render(ctx.get_context())
            except TemplateSyntaxError as e:
                logger.error(f"Error rendering template {i}, exception: %s", e)
                bar.finish()
                found = True
                logger.error("Error while trying to found!!!")
                continue
            with open(output_rendered_name, "w") as text_file:
                text_file.write(rendered)
            if not d.is_template_matched(template_filepath, ctx) and d.is_alert_present(output_rendered_name):
                bar.finish()
                found = True
                logger.info("Found!!!")
                continue
            bar.next()
            ctx.remove_created_files()
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
    num_of_tests: int = 20
    total_tests: int = 0
    found: bool = False

    while not found:
        logger.info("Creating new pool...")
        generate_tests(total_tests, num_of_tests, g)
        found = check_test(total_tests, num_of_tests, d)
        if not found:
            logger.info(f"Not found. Have run {num_of_tests} tests...")
            total_tests += num_of_tests
    
    logger.info(f"Found in less than {total_tests + num_of_tests} tests!")

def prepare_fuzzer():
    logger.info("Preparing fuzzer for generating tests...")
    HTMLGenerator_modify_time = os.path.getmtime("grammars/fuzzer/HTMLGenerator.py")
    HTMLLexer_modify_time = os.path.getmtime("grammars/HTMLLexer.g4")
    HTMLParser_modify_time = os.path.getmtime("grammars/HTMLParser.g4")
    if HTMLGenerator_modify_time > HTMLLexer_modify_time and HTMLGenerator_modify_time > HTMLParser_modify_time:
        logger.info("Will not run grammarinator-process as grammar is already ready...")
        return
    result = subprocess.run(["grammarinator-process", "grammars/HTMLLexer.g4", "grammars/HTMLParser.g4", "-o", "grammars/fuzzer"], capture_output=True, text=True, check=True, timeout=10)
    logger.info("Fuzzer prepared and grammar is ready!")
    logger.debug('output: %s', result.stdout)
    logger.debug('error: %s', result.stderr)


def clear_directory():
    templates_directory = "./polls/templates/polls"
    only_files = [f for f in os.listdir(templates_directory) if os.path.isfile(os.path.join(templates_directory, f))]
    for file in filter(lambda x: (x.startswith("test_") or x.startswith("rendered_test_") or x.startswith("t_")) and x.endswith(".html"), only_files):
        logger.info("Found file from previous run: '%s'. Will be deleted!", file)
        os.remove(os.path.join(templates_directory, file))

if __name__ == "__main__":
    setup_logger(logger)
    setup_logger(logging.getLogger("ContextLoader"), logging.WARNING)
    prepare_fuzzer()
    clear_directory()
    run()
