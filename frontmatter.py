#!/usr/bin/env python
"""
Convert a markdown file into Hugo format
"""
import fileinput
import json

fm = {}
for line in fileinput.input():
    index = fileinput.lineno()
    if index == 1:
        fm['title'] = line.strip()
        continue
    elif index == 4:
        subheading = line.strip()
        if "::" in subheading:
            subtitle, tags = subheading.split(" :: ")
            fm['description'] = subtitle
            fm['tags'] = tags.split(", ")
        continue
    elif index == 6:
        # Print front-matter
        fm['date'] = "2014-01-01"
        print(json.dumps(fm, indent="    "))
        print()
    elif index > 6:
        print(line, end="")
