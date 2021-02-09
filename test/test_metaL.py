from metaL import *

def test_true():
    assert True

def test_hello():
    hello = Object('Hello')
    assert hello.test() == '\n<object:Hello>'
    world = Object('World')
    assert world.test() == '\n<object:World>'
    hello // world
    assert hello.test() ==\
        '\n<object:Hello>\n\t0: <object:World>'
