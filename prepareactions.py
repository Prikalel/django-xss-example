import logging
import os
import subprocess

logger = logging.getLogger(__name__)

class PrepareActions:
    @staticmethod
    def __prepare_fuzzer():
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

    @staticmethod
    def __clear_directory():
        templates_directory = "./polls/templates/polls"
        only_files = [f for f in os.listdir(templates_directory) if os.path.isfile(os.path.join(templates_directory, f))]
        for file in filter(lambda x: (x.startswith("test_") or x.startswith("rendered_test_") or x.startswith("t_")) and x.endswith(".html"), only_files):
            logger.info("Found file from previous run: '%s'. Will be deleted!", file)
            os.remove(os.path.join(templates_directory, file))

    @staticmethod
    def do_all():
        PrepareActions.__prepare_fuzzer()
        PrepareActions.__clear_directory()