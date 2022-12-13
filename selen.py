from selenium import webdriver as wd
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import UnexpectedAlertPresentException
from webdriver_manager.chrome import ChromeDriverManager
from selenium.common.exceptions import NoAlertPresentException
import os

class Driver:
    def __init__(self):
        self.driver = wd.Chrome(ChromeDriverManager().install())
        self.wait = WebDriverWait(self.driver, 15)

    def is_alert_present(self, relative_path):
        full_path = os.path.abspath(relative_path)
        #print("Testing: " + full_path)
        try:
            self.driver.get(f"file://{full_path}")
            try:
                alert = self.driver.switch_to.alert
                if alert is None:
                    return False
                return True
            except NoAlertPresentException:
                return False
        except UnexpectedAlertPresentException:
            return True
