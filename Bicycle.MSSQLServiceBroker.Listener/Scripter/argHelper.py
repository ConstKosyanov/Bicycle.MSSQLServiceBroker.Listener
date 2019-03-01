import os
import argparse


def getActionChoises():
    for file in os.listdir('templates'):
        yield file


def getArgs():
    parser = argparse.ArgumentParser(description=main)
    parser.add_argument('action', choices=actionChoises, help=action)
    parser.add_argument('-i', action='store_true', help='generate insert trigger')
    parser.add_argument('-u', action='store_true', help='generate update trigger')
    parser.add_argument('-d', action='store_true', help='generate delete trigger')
    srciptVariables = parser.add_argument_group('Script variables')
    srciptVariables.add_argument('database', type=str, help='Sets database name')
    srciptVariables.add_argument('table', type=str, help='Sets table name')
    return parser.parse_args()


main = 'Generates SQL-script for service broker set up'
action = 'What the script should do'
actionChoises = list(getActionChoises())
triggerTypes = ['insert']
