from .web import Web
# from ..meta.module import Module
from metaL import *

import os, sys
import datetime as dt

import flask
from flask_socketio import SocketIO

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class Flask(Module):
    pass

class App(Web):
    def __init__(self, V):
        super().__init__(V)
        self.init_app()
        self.init_routing()
        self.init_socketio()
        self.init_watchdog()

    # Flask application -> self.app
    def init_app(self):
        self.flask = flask
        glob['web'] = self
        basename = os.path.basename(sys.argv[0])[:-3]
        self['engine'] = Flask(basename)
        #
        self.app = self.flask.Flask(basename)
        self.app.config['SECRET_KEY'] = os.urandom(64)

    # lookup object in global graph by URL-like path
    def lookup(self, path):
        ret = glob
        for i in path.split('/'):
            ret = ret[i]
        return ret

    # classic http routing
    def init_routing(self):
        @self.app.route('/')
        def index():
            return self.flask.render_template('index.html', env=glob)

        @self.app.route('/dump/<path:path>')
        def dump(path):
            return self.flask.render_template('dump.html', env=self.lookup(path))

    # SocketIO
    def init_socketio(self):
        self.sio = SocketIO(self.app)
        @self.sio.on('connect')
        def connect(): self.sio.emit('localtime', Time().json())

    # watch: reload page on file changes
    def init_watchdog(self):
        class Handler(FileSystemEventHandler):
            def __init__(self, sio):
                super().__init__()
                self.sio = sio

            def on_modified(self, event):
                self.sio.emit('reload',
                              [event.src_path, event.event_type])
        self.observer = Observer()
        self.observer.schedule(
            Handler(self.sio), path='static', recursive=True)
        self.observer.schedule(
            Handler(self.sio), path='templates', recursive=True)
        self.observer.start()

    def eval(self, env):
        #
        self.sio.run(self.app, debug=True,
                     host=self['host'].value,
                     port=self['port'].value)
