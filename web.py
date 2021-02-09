import config
from metaL import *

app = App('metaL')
app['host'] = Ip(config.HOST)
app['port'] = Port(config.PORT)
app.eval(glob)
