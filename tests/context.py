import sys
sys.path.append('.')
import unittest
from djangocontext import ContextLoader, CommentSection


class TestContextLoader(unittest.TestCase):
    def setUp(self):
        self.loader = ContextLoader(None)

    def test_get_context(self):
        self.loader.ctx_json_data = "{ \"hello\": 123 }"
        self.assertEqual(self.loader.get_context(), {"hello": 123})

    def test_get_sections(self):
        self.loader.text = """
        {% block Z %}{% endblock %}{% comment %}{# { "type":"block","name":"Z" } #}<html ><head contenteditable=false></head>GKNUM
        </html>{% with var0=X  %}{% block R %}xR
        {% debug %}{% endblock %}D
        {% endwith %}{% endcomment %}
        """
        sections = self.loader.get_sections()
        self.assertEqual(len(sections), 1)
        section: CommentSection = (sections[0])
        self.assertEqual(section.name, "Z")
        self.assertEqual(section.type, "block")
        self.assertEqual(section.inner, """<html ><head contenteditable=false></head>GKNUM
        </html>{% with var0=X  %}{% block R %}xR
        {% debug %}{% endblock %}D
        {% endwith %}""")

if __name__ == "__main__":
    unittest.main()
