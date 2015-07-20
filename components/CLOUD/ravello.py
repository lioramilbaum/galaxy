#!/usr/bin/env python3

from ravello_sdk import *
client = RavelloClient()
client.login('liora@lmb.co.il', 'Lmb1234!')
for app in client.get_applications():
    print('Found Application: {0}'.format(app['name']))
client.start_vm()
client.logout()