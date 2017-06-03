# pylint: skip-file
from flask import Flask
from flask_mongoengine import MongoEngine

db = MongoEngine()

from app.controllers import main


def create_app(object_name):
    """
    An flask application factory, as explained here:
    http://flask.pocoo.org/docs/patterns/appfactories/

    Arguments:
        object_name: the python path of the config object,
                     e.g. appname.settings.ProdConfig
    """
    app = Flask(__name__)
    app.config.from_object(object_name)

    # Initialize the database
    db.init_app(app)

    # register our blueprints
    app.register_blueprint(main)

    return app
