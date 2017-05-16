#!/usr/bin/env python
import sys
import time

for line in iter(sys.stdin.readline, ''):
  line = line.rstrip('\n')
  if line == "{\"test\":\"sleep3s\"}":
    time.sleep(3)
    sys.stdout.write('{"response": '+ line + '}'),
  elif line == "{\"test\":\"error\"}":
    sys.stdout.write('{"error": '+ line + '}'),
  elif line == "{\"test\":\"crash\"}":
    raise Exception('some exception')
  elif line == "{\"test\":\"not_json\"}":
    sys.stdout.write('plaintext'),
  else:
    sys.stdout.write('{"response": '+ line + '}'),
