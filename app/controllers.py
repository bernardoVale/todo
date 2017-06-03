from flask import render_template, request, Blueprint
from models import Todo, TodoForm

main = Blueprint('main', __name__)
main.config = {}

@main.record
def record_params(setup_state):
  app = setup_state.app
  main.config = dict([(key,value) for (key,value) in app.config.iteritems()])


def app_version():
    return main.config['APP_VERSION']


@main.route('/')
def index():
    form = TodoForm()
    todos = Todo.objects.order_by('-time')
    return render_template("index.html", todos=todos, form=form, version=app_version())


@main.route('/add', methods=['POST', ])
def add():
    form = TodoForm(request.form)
    if form.validate():
        content = form.content.data
        todo = Todo(content=content)
        todo.save()
    todos = Todo.objects.order_by('-time')
    return render_template("index.html", todos=todos, form=form, version=app_version())


@main.route('/done/<string:todo_id>')
def done(todo_id):
    form = TodoForm()
    todo = Todo.objects.get_or_404(id=todo_id)
    todo.status = 1
    todo.save()
    todos = Todo.objects.order_by('-time')
    return render_template("index.html", todos=todos, form=form, version=app_version())


@main.route('/undone/<string:todo_id>')
def undone(todo_id):
    form = TodoForm()
    todo = Todo.objects.get_or_404(id=todo_id)
    todo.status = 0
    todo.save()
    todos = Todo.objects.order_by('-time')
    return render_template("index.html", todos=todos, form=form, version=app_version())


@main.route('/delete/<string:todo_id>')
def delete(todo_id):
    form = TodoForm()
    todo = Todo.objects.get_or_404(id=todo_id)
    todo.delete()
    todos = Todo.objects.order_by('-time')
    return render_template("index.html", todos=todos, form=form, version=app_version())


@main.errorhandler(404)
def not_found(e):
    return render_template('404.html'), 404

