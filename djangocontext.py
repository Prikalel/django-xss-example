import json

class ContextLoader:
    json_data: str

    def __init__(self, template_filename: str, logger_frmt: str = ""):
        with open(template_filename, "r") as text_file:
            self.json_data = text_file.readline().strip().removeprefix("{#").removesuffix("#}")

    def get_context(self) -> dict:
        return json.loads(self.json_data)
