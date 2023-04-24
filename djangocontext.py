import json
from logging import Logger
import logging
import os
from typing import List
from mylogger import setup_logger

class CommentSection:
    inner: str
    type: str
    name: str

    def __init__(self, section_data: str, info_json_payload: str):
        self.inner = section_data
        info = json.loads(info_json_payload)
        self.type = info['type']
        self.name = info['name']

    def isBlock(self) -> bool:
        return self.type == "block"
    
    def isInclude(self) -> bool:
        return self.type == "include"

class ContextLoader:
    logger: Logger = logging.getLogger("ContextLoader")
    ctx_json_data: str
    text: str
    template_relative_path: str
    base_file_relative_path: str
    created_included_files: List[str]

    COMMENT = "{% comment %}"
    ENDCOMMENT = "{% endcomment %}"
    END_INFO = "#}"

    def __init__(self, template_filename: str):
        self.base_file_relative_path = None
        self.created_included_files = []
        if template_filename is not None:
            self.template_relative_path = template_filename
            with open(template_filename, "r") as text_file:
                self.ctx_json_data = text_file.readline().strip().removeprefix("{#").removesuffix("#}")
                self.text = text_file.read()
        else:
            self.logger.error("No file passed!")

    def get_context(self) -> dict:
        return json.loads(self.ctx_json_data)

    def get_sections(self) -> List[CommentSection]:
        res = []
        found_pos = self.text.find(self.COMMENT)
        while found_pos != -1:
            info_start_pos = found_pos + len(self.COMMENT)
            info_end_pos = self.text.find(self.END_INFO, info_start_pos)
            section_start_index = info_end_pos + len(self.END_INFO)
            info_json = self.text[info_start_pos:section_start_index].strip().removeprefix("{#").removesuffix("#}")
            section_end_index = self.text.find(self.ENDCOMMENT, section_start_index)
            section_data = self.text[section_start_index:section_end_index]
            cmt = CommentSection(section_data, info_json)
            res.append(cmt)
            found_pos = self.text.find(self.COMMENT, section_end_index + len(self.ENDCOMMENT))
        return res

    def create_and_modify_files_if_need(self):
        sections = self.get_sections()
        if any(map(lambda x: x.isBlock(), sections)):
            self.logger.info("Modifying file %s as it contains blocks overriding.", self.template_relative_path)
            filename_without_extension = self.template_relative_path.removesuffix(".html")
            self.base_file_relative_path = filename_without_extension + "_base.html"
            os.rename(self.template_relative_path, self.base_file_relative_path)
            with open(self.template_relative_path, "w") as text_file:
                base_filename = os.path.basename(self.base_file_relative_path)
                text_file.write("{% extends \"./" + base_filename + "\" %}\n\n")
                for section in filter(lambda x: x.isBlock(), sections):
                    self.logger.debug("Writing block '%s'.", section.name)
                    text_file.write("{% block " + section.name + " %}\n")
                    text_file.write(os.linesep.join([s for s in section.inner.splitlines() if s]) + "\n")
                    text_file.write("{% endblock %}\n\n\n")
        if any(map(lambda x: x.isInclude(), sections)):
            self.logger.info("Creating files for %s as it contains include keywords.", self.template_relative_path)
            dirpath_to_create_files = os.path.dirname(os.path.abspath(self.template_relative_path))
            self.logger.info("Will create files in %s directory.", dirpath_to_create_files)
            for section in filter(lambda x: x.isInclude(), sections):
                new_filepath = os.path.join(dirpath_to_create_files, section.name)
                with open(new_filepath, "w") as text_file:
                    self.logger.debug("Writing file '%s'.", section.name)
                    text_file.write(os.linesep.join([s for s in section.inner.splitlines() if s]) + "\n")
                self.created_included_files.append(new_filepath)
                self.logger.info("Saved for future deletion %s.", new_filepath)

    def remove_created_files(self):
        if self.base_file_relative_path is not None and os.path.exists(self.base_file_relative_path):
            self.logger.info("Deleting base file %s...", self.base_file_relative_path)
            os.remove(self.base_file_relative_path)
        for filename in self.created_included_files:
            if os.path.exists(filename):
                self.logger.info("Deleting included file %s...", filename)
                os.remove(filename)

    def have_any_created_files(self) -> bool:
        return (self.base_file_relative_path is not None and os.path.exists(self.base_file_relative_path)) or len(self.created_included_files) > 0