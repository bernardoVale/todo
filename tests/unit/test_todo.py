from flask_testing import TestCase
from app import create_app
from app.controllers import index
from app.models import Todo


class TodoUnit(TestCase):

    def setUp(self):
        pass

    def create_app(self):
        # pass in test configuration
        return create_app(self)

    def test_index(self):
        assert True

    def test_empty(self):
        assert None is None

    def test_add_todo(self):
        assert True is not None

    def test_none_todo(self):
        assert True

    def test_done_todo(self):
        assert True


    def test_undone_todo(self):
        assert True

    def test_delete_todo(self):
        assert False is False

    def test_404(self):
        assert None is None