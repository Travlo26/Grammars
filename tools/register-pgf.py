#! /usr/bin/env python

# Register grammars from the given URL with the given server.

# Author: Kaarel Kaljurand
# Version: 2013-11-09
#
import argparse
import json
import os
import re
import subprocess
import sys
import time

curl='curl'
EXT='.pgf'

default_server='http://bark.phon.ioc.ee/test/speech-api/v1'
default_grammars='http://kaljurand.github.com/Grammars/grammars/pgf/'

def get_result(cmd):
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	return p.communicate()

def get_result_json(cmd):
	out,err = get_result(cmd)
	try:
		result = json.loads(out)
		if args.verbosity > 1:
			print json.dumps(result, indent=4)
		if args.verbosity > 0:
			show_result(result)
	except:
		print 'ERROR'
		print 'stdout: {0}'.format(out)
		print 'stderr: {0}'.format(err)
		#print >> sys.stderr, sys.exc_info()[0]


def show_result(result):
	if result["errorcode"] == "OK":
		print "OK"
	else:
		print result["output"]


# Commandline arguments parsing
parser = argparse.ArgumentParser(description='Registers a set of PGFs with the speech recognition server')

parser.add_argument('names', metavar=('NAMES'), type=str, nargs='+',
	help='name of the grammar (i.e. abstract syntax)')

parser.add_argument('-s', '--server', type=str, action='store', dest='server',
	default=default_server,
	help='name of the speech recognition server, default=' + default_server)

parser.add_argument('-g', '--grammars', type=str, action='store', dest='grammars',
	default=default_grammars,
	help='name of the grammars repository, default=' + default_grammars)

parser.add_argument('-l', '--langs', type=str, action='store', dest='langs',
	required=True,
	help='comma-separated list of 3-letter language codes, e.g. Est,Eng (OBLIGATORY)')

parser.add_argument('--verbosity', type=int, action='store', dest='verbosity',
	default='1',
	help='amount of output to produce')

parser.add_argument('-v', '--version', action='version', version='%(prog)s v0.1')

args = parser.parse_args()


for name in args.names:
	url = args.grammars + name + EXT
	cmd = [curl, '--get', '-d', 'url=' + url, '-d', 'lang=' + args.langs]
	cmd.append(args.server + "/fetch-pgf")

	if args.verbosity > 1:
		print >> sys.stderr, 'Registering {:} ({:}) ...'.format(name, args.langs)
		if args.verbosity > 2:
			print >> sys.stderr, ' '.join(cmd)

	time_start = time.time()
	out,err = get_result(cmd)
	time_end = time.time()

	if args.verbosity > 0:
		print >> sys.stdout, '{:}: {:.2f} sec: {:}'.format(name, time_end - time_start, out)
