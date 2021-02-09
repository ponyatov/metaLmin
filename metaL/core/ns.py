from .object import Object

# namespace
class Ns(Object):
    pass


# global namespace
glob = Ns('global')
glob << glob
glob >> glob
