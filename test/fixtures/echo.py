#!/usr/bin/env python
import sys
for line in iter(sys.stdin.readline, ''):
  line = line.rstrip('\n')
  sys.stdout.write('{"response": '+ line + '}'),
