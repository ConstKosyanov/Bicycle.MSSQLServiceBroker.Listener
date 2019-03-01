class generator:
    def __init__(self, args):
        self.database = args.database
        self.table = args.table
        self.path = f'templates/{args.action}'
        self.actions = self.getActions(args)

    def getActions(self, args):
        if args.i:
            yield 'Insert'
        if args.u:
            yield 'Update'
        if args.d:
            yield 'Delete'

    def getFromFile(self, path, *placeholders):
        result = open(f'{self.path}/{path}').read()
        for placeholder in placeholders:
            result = result.replace(placeholder[0], placeholder[1])
        return result

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
        self.ActionBody = self.getFromFile('queue.sql', ('%Table%', self.table))

    def getDBScript(self):
        return self.getFromFile('db.sql', ('%DataBase%', self.database))

    def getActionScript(self, action):
        return f"{self.ActionBody.replace('%Operation%', action)}\n{self.getFromFile(f'{action}.sql', ('%Table%', self.table))}"


class removeGenerator(generator):
    def __init__(self, args):
        super().__init__(args)

    def getDBScript(self):
        return self.getFromFile('db.sql', ("%DataBase%", self.database))

    def getActionScript(self, action):
        return self.getFromFile(f'queue.sql', ('%Table%', self.table), ('%Operation%', action))
