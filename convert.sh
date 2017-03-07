#!/usr/bin/env bash

INPUT=$1

# Convert sourcecode blocks
cat $INPUT | \
    # Convert to recognised directive
    sed 's/.. sourcecode/.. code/' | \
    # Strip some image attributes which don't convert
    grep -v ":width:" | \
    grep -v ":class:" | \
    # RST -> MD
    pandoc --from=rst --to=markdown | \
    # Strip .sourceCode from codeblocks
    sed 's/{.sourceCode \.\([a-z+]\+\)}/\1/' | \
    # Inject front-matter
    ./frontmatter.py
