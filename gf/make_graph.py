#! /usr/bin/env python

# Usage:
#
# find . -name "*.gf" | xargs cat | python make_graph.py | dot -Tsvg | display
#
# or
#
# find . -name "*.gf" | xargs cat | python make_graph.py > out.dot
# dot -Tsvg out.dot > out.svg
# eog out.svg

"""GF application grammar module hierarchy visualizer
"""

__author__ = 'kaljurand@gmail.com (Kaarel Kaljurand)'

import sys
import argparse
import os
import re
import time
import codecs
from os.path import join

header_dot = """/*
GF grammar structure
*/

digraph G {

node [shape = "rect"];
edge [arrowsize=1, color=black];

/*
subgraph cluster_0 {
	label = "Abstract grammars";
	color = "red";

	Currency;
	Digit;
}
*/
"""

footer_dot = "}"

re_abstract = re.compile('abstract (.*) =(.*){.*')
re_concrete = re.compile('concrete (.*) of (.*) =(.*){.*')

def match_abstract(m):
	dot_lines = []
	name = m.group(1).strip()
	supers = m.group(2)
	supers = re.sub('\*\*.*', '', supers)
	if re.match('^\s*$', supers):
		dot_lines.append('"{:}" -> "_abstract_" [shape = "diamond" color = "red" style = "bold"]'.format(name))
		return dot_lines
	for s in supers.split(','):
		s = s.strip()
		dot = '"{:}" -> "{:}" [shape = "diamond" color = "red" style = "bold"]'.format(name, s)
		dot_lines.append(dot)
	return dot_lines


def match_concrete(m):
	dot_lines = []
	name = m.group(1).strip()
	# concrete -> abstract (this makes the diagram very complicated to read)
	#dot = '"{:}" -> "{:}" [style = "dashed" color = "navy"]'.format(name, m.group(2).strip())
	#dot_lines.append(dot)
	supers = m.group(3)
	supers = re.sub('open .*', '', supers)
	# Remove restricted inheritance
	supers = re.sub('-?\[[^\]]*\]', '', supers)
	supers = re.sub('\*\*.*', '', supers)
	if re.match('^\s*$', supers):
		dot_lines.append('"{:}" -> "_concrete_" [color = "green" style = "bold"]'.format(name))
		return dot_lines
	for s in supers.split(','):
		s = s.strip()
		s = re.sub('\s*-.*', '', s)
		dot = '"{:}" -> "{:}" [color = "green" style = "bold"]'.format(name, s)
		dot_lines.append(dot)
	return dot_lines


def line_to_dot_lines(line):
	"""
	concrete UnitconvEst of Unitconv = FractionEst, UnitEst ** open Estonian in {
	abstract Unitconv = Fraction, Unit ** {
	"""
	dot_lines = []
	m1 = re_abstract.search(line)
	if m1:
		print '/* {:} */'.format(line)
		return match_abstract(m1)
	m2 = re_concrete.search(line)
	if m2:
		print '/* {:} */'.format(line)
		return match_concrete(m2)
	return []


print header_dot
for raw_line in sys.stdin.readlines():
	line = raw_line.strip()
	dot_lines = line_to_dot_lines(line)
	for l in dot_lines:
		print l
print footer_dot