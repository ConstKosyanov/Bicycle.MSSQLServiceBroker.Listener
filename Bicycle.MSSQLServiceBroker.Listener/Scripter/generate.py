import sys
import argHelper as h
import generator as g

args = h.getArgs()
if args.action == 'add':
    gen = g.initGenerator(args)
elif args.action == 'remove':
    gen = g.removeGenerator(args)
else:
    sys.exit()

print(gen.getScript())
