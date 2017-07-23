import os
import subprocess

class Config(object):
    SECRET_KEY = 'YmVybmFyZG8gZSBmb2RhbyBlIHRyYW5zYWRvci4gTmFvIG1leGUgY29tIGVsZQ=='
    _mongodb_host = os.environ.get('MONGODB_HOST', 'localhost')

    MONGODB_SETTINGS = {'DB': 'todo_db', 'host': _mongodb_host, 'port':  27017}
    WTF_CSRF_ENABLED = False

    PORT = 5000
    DEBUG = False
    CSRF_ENABLED = True
    CSRF_SESSION_KEY = "secret"

    with open('version.txt') as stream:
        APP_VERSION = stream.read()

    HOSTNAME = subprocess.check_output("hostname").strip()


class ProductionConfig(Config):
    PORT = 8001


class StagingConfig(Config):
    pass


class DevConfig(Config):
    DEBUG = True
