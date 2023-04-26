import logging
from selenium import webdriver as wd
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import UnexpectedAlertPresentException
from webdriver_manager.chrome import ChromeDriverManager
from selenium.common.exceptions import NoAlertPresentException
import os
from djangocontext import ContextLoader

logger = logging.getLogger(__name__)

class Driver:
    def __init__(self):
        self.driver = wd.Chrome(ChromeDriverManager().install())
        self.wait = WebDriverWait(self.driver, 15)

    def is_alert_present(self, relative_path):
        full_path = os.path.abspath(relative_path)
        logger.debug("Testing rendered html at path %s.", full_path)
        try:
            self.driver.get(f"file://{full_path}")
            try:
                alert = self.driver.switch_to.alert
                if alert is None:
                    return False
                logger.warning("Found alert at: %s", relative_path)
                return True
            except NoAlertPresentException:
                return False
        except UnexpectedAlertPresentException:
            logger.warning("UnexpectedAlertPresentException at: %s", relative_path)
            return True

    def is_template_matched(self, template_filepath, ctx: ContextLoader) -> bool:
        """Возвращает True если файл шаблона соответствует искомому.

        Полезно, если надо проверить что грамматика может генерировать шаблоны
        определённой структуры.
        
        :param ctx: Контекст рендера шаблона.
        :type ctx: ContextLoader
        :param template_filepath: Путь до файла шаблона.
        :type template_filepath: str
        :rtype: bool
        """
        strings: list = []
        with open(template_filepath, "r") as text_file:
            strings = text_file.readlines()

        if ctx.base_file_relative_path is not None and os.path.exists(ctx.base_file_relative_path):
            with open(ctx.base_file_relative_path, "r") as text_file:
                strings += text_file.readlines()
        if ctx.created_included_files is not None:
            for included_file in filter(lambda x: os.path.exists(x), ctx.created_included_files):
                with open(included_file, "r") as text_file:
                    strings += text_file.readlines()

        searching_keyword = "debug"
        result: bool = any(map(lambda s: s.count(searching_keyword), strings))
        if result:
            logger.warning("Found searching template file at: %s", template_filepath)
        return result