#!/usr/bin/env python
"""
Convert a markdown file into Hugo format
"""
import fileinput
import json
import csv

def meta():
    lookup = {}
    with open("data/archive.csv") as f:
        reader = csv.reader(f)
        for row in reader:
            lookup[row[1]] = {
                'slug': row[2],
                'created_at': row[3][:10],
            }
    return lookup

lookup = meta()


def filter_body_line(line):
    replacements = (
        # FTs to strip as no lexer
        ('``` ssh', '```'),
        ('``` markdown', '```'),
        ('``` conf', '```'),
        ('``` csv', '```'),
        # Aliases
        ('``` viml', '``` vim'),
        ('``` vimscript', '``` vim'),
        # New paths
        ('/static/images/', '/images/'),
    )
    for find, replace in replacements:
        line = line.replace(find, replace)
    return line


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
        # Look-up metadata from dump
        key = fm['title'].replace('`', '').replace("\\", "")
        metadata = lookup[key]

        # Print front-matter
        fm['date'] = metadata['created_at']
        fm['slug'] = metadata['slug']
        print(json.dumps(fm, indent="    "))
        print()
    elif index > 6:
        # Just pass-through lines after headers
        print(filter_body_line(line), end="")
