+++
date = "2017-03-27T15:25:05+01:00"
title = "Reorganising a Consul key-value store"
tags = ["consul", "bash", "jq"]
description = "This is really just a reference on how to combine JQ's select filters."

+++

If your Consul key-value store is structured as:

```sh
/
    A/
        X = 1
        Z = 2
        Y = 3
    C
    D
```

but you now realise you should have namespaced everything within `WEBSERVER/`
(or something like that):

```bash
/
    WEBSERVER/
        A/
            X = 1
            Z = 2
            Y = 3
        C
        D
```

then this Bash script will help you migrate:

```bash
#!/bin/bash

set -e  # Exit on error

# Emit "key value" lines for all keys in Consul's KV store
keys_and_values() {
    # Recursively fetch all values from Consul but exclude:
    # (a) those that end in / (as these are folders)
    # (b) those that start with WEBSERVER/ (as that's where we are migrating
    #     to).
    curl -s "localhost/v1/kv/?recurse" | jq -r '
        .[] |
        select(
            (.Key | endswith("/") | not) and
            (.Key | startswith("WEBSERVER") | not)
        ) |
        [.Key, " ", .Value] |
        add' | while read key b64value
    do
        # Consul's REST API returns values base64-encoded so we decode here.
        echo $key `echo "$b64value" | base64 -d`
    done
}

# Set a new value in Consul's KV store
set_key() {
    key=$1
    value=$2
    curl -s -X PUT -d "$value" "localhost/v1/kv/$key" > /dev/null
}

migrate_to_webserver_namespace() {
    keys_and_values | while read key value
    do
        set_key "WEBSERVER/$key" "$value"
    done
}

migrate_to_webserver_namespace
```

This script uses
[Consul's REST API](https://www.consul.io/docs/agent/http/kv.html) and filters
the results using [`jq`](https://stedolan.github.io/jq/)[^1]. It's easily
adapted to migrate key-value pairs between different namespaces.

[^1]:
    I can never remember jq's `select` syntax so this post is intended largely
    as a personal reference on how to do this.
