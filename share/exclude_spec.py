#!/usr/bin/python
# Copyright (c) TurnKey GNU/Linux - http://www.turnkeylinux.org
#
# This file is part of Fab
#
# Fab is free software; you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by the
# Free Software Foundation; either version 3 of the License, or (at your
# option) any later version.

import os
import re
import sys
import getopt

def usage(s=None):
    if s: print >> sys.stderr, s
    print >> sys.stderr, "Syntax: %s <spec> <exclude>" % os.path.basename(sys.argv[0])
    print >> sys.stderr
    print >> sys.stderr, "spec       Path to read spec from (- for stdin)"
    print >> sys.stderr, "exclude    Path to read entries to exclude from spec"
    sys.exit(1)

def read_spec(input):
    spec = set()
    if os.path.isfile(input):
        contents = open(input, "r").readlines()
    else:
        contents = input.split("\n")

    for line in contents:
        line = re.sub(r'#.*', '', line)
        line = line.strip()
        if line:
            spec.add(line)

    return spec


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "")
    except getopt.GetoptError, e:
        usage(e)

    if not len(args) == 2:
        usage("not enough arguments")

    if args[0] == '-':
        fh = sys.stdin
    else:
        fh = file(args[0], "r")

    spec = read_spec(fh.read())
    exclude = read_spec(file(args[1], "r").read())
    
    newspec = spec - exclude
    for s in newspec:
        print s


if __name__=="__main__":
    main()
