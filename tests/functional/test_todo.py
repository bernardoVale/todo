import os
from app import create_app
from flask_testing import TestCase
from app.models import Todo
from werkzeug.exceptions import HTTPException


class TodoTestCase(TestCase):
    TESTING = True
    CSRF_ENABLED = False
    CSRF_SESSION_KEY = 'secret'
    WTF_CSRF_ENABLED = False
    APP_VERSION = 'dev'
    HOSTNAME = 'foo'
    _mongodb_host = os.environ.get('MONGODB_HOST', 'localhost')
    MONGODB_SETTINGS = {'DB': 'todo_db', 'host': _mongodb_host, 'port': 27017}

    def create_app(self):
        # pass in test configuration
        return create_app(self)

    def tearDown(self):
        # clear data for each test
        todos = Todo.objects.all()
        for todo in todos:
            todo.delete()

    def test_index(self):
        rv = self.client.get('/')
        assert "ACOB Todo App" in rv.data

    def test_empty(self):
        rv = self.client.get('/')
        assert "No todos, please add" in rv.data

    def test_add_todo(self):
        self.client.post("/add", data=dict(content="test add todo"))
        todo = Todo.objects.get_or_404(content="test add todo")
        assert todo is not None

    def test_none_todo(self):
        try:
            Todo.objects.get_or_404(content='test todo none')
        except HTTPException as e:
            assert e.code == 404

    def test_done_todo(self):
        todo = Todo(content='test done todo')
        todo.save()
        url = '/done/'+str(todo.id)
        rv = self.client.get(url)
        assert '/undone/'+str(todo.id) in rv.data

    def test_undone_todo(self):
        todo = Todo(content='test undone todo')
        todo.save()
        url = '/undone/'+str(todo.id)
        rv = self.client.get(url)
        assert '/done/'+str(todo.id) in rv.data

    def test_delete_todo(self):
        todo = Todo(content='test delete done')
        todo.save()
        url = '/delete/'+str(todo.id)
        rv = self.client.get(url)
        assert "No todos, please add" in rv.data

    def test_404(self):
        rv = self.client.get('/404test')
        assert "Not Found" in rv.data


