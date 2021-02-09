from .object import Object

class IO(Object):
    pass

# slashed file path on disk
class Path(IO):
    pass

# directory
class Dir(IO):
    pass

# generic file
class File(IO):
    pass
