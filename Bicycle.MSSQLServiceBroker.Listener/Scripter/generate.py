import argparse
import sys
import os


class generator:
    def __init__(self, args):
        self.database = args.database
        self.table = args.table
        self.scheme = args.scheme
        self.path = f'templates/{args.action}'
        self.actions = self.getActions(args)

    def getActions(self, args):
        if args.i:
            yield 'Insert'
        if args.u:
            yield 'Update'
        if args.d:
            yield 'Delete'

    def getFromFile(self, path):
        return open(f'{self.path}/{path}').read() \
            .replace('%DataBase%', self.database) \
            .replace('%Scheme%', self.scheme) \
            .replace('%Table%', self.table)

    def getScript(self):
        return '\n'.join(self.getParts())

    def getParts(self):
        yield self.getDBScript()
        for action in self.actions:
            yield self.getActionScript(action)

    def getDBScript(self):
        raise NotImplementedError

    def getActionScript(self, action):
        raise NotImplementedError


class initGenerator(generator):
    def __init__(self, args):
        super().__init__(args)
        self.ActionBody = self.getFromFile('queue.sql')

    def getDBScript(self):
        return self.getFromFile('db.sql')

    def getActionScript(self, action):
        return f"{self.ActionBody.replace('%Operation%', action)}\n{self.getFromFile(f'{action}.sql')}"


class removeGenerator(generator):
    def __init__(self, args):
        super().__init__(args)

    def getDBScript(self):
        return self.getFromFile('db.sql')

    def getActionScript(self, action):
        return self.getFromFile(f'queue.sql').replace('%Operation%', action)


def getActionChoises():
    for file in os.listdir('templates'):
        yield file


def getArgs():
    parser = argparse.ArgumentParser(description=main)
    parser.add_argument('action', choices=actionChoises, help=action)
    parser.add_argument('-i', action='store_true',
                        help='generate insert trigger')
    parser.add_argument('-u', action='store_true',
                        help='generate update trigger')
    parser.add_argument('-d', action='store_true',
                        help='generate delete trigger')
    srciptVariables = parser.add_argument_group('Script variables')
    srciptVariables.add_argument(
        'database', type=str, help='Sets database name')
    srciptVariables.add_argument(
        'scheme', type=str, help='Sets table scheme')
    srciptVariables.add_argument('table', type=str, help='Sets table name')
    return parser.parse_args()


main = 'Generates SQL-script for service broker set up'
action = 'What the script should do'
actionChoises = list(getActionChoises())
triggerTypes = ['insert']

args = getArgs()
if args.action == 'add':
    gen = initGenerator(args)
elif args.action == 'remove':
    gen = removeGenerator(args)
else:
    sys.exit()

print(gen.getScript())
