from .object import Object

import datetime as dt

class Time(Object):
    def __init__(self):
        self.now = dt.datetime.now()
        self.date = self.now.strftime('%d.%m.%Y')
        self.time = self.now.strftime('%H:%M:%S')
        super().__init__(f'{self.date} {self.time}')

    def json(self):
        return {'date': self.date, 'time': self.time}
