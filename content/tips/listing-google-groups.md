+++
title = "Listing groups in G-Suite"
date = 2018-10-27T12:53:24+01:00
description = "Using the API to pull simple reports."
tags = ["gsuite"]
+++

Oddly, you can't pull a report of all groups from G-Suite like you can for
users. The only option is to use the API. Here's how.

Follow steps 1 and 2 from
[the quickstart guide](https://developers.google.com/admin-sdk/directory/v1/quickstart/python)
but instead of the sample Python script, use this:

```python
from httplib2 import Http

from googleapiclient.discovery import build
from oauth2client import file, client, tools


def main():
    _print_all_groups()


def _print_all_groups():
    for group in _all_groups():
        print(group['email'])


def _all_groups():
    """
    Return a list of all group dicts.
    """
    # Build a client with appropriate scope privileges
    service = _service(
        service_name="admin",
        service_version="directory_v1",
        # See https://developers.google.com/admin-sdk/directory/v1/guides/authorizing
        # for a complete list of scopes.
        scope="https://www.googleapis.com/auth/admin.directory.group.readonly")

    # Call the Admin SDK Directory API
    return service.groups().list(
        # "my_customer" is a special alias that admins can use.
        customer='my_customer'
    ).execute()


def _service(service_name, service_version, scope):
    """
    Return a configured service client for the API.
    """
    # Look for a local token.json file. Remove this if changing the scope.
    store = file.Storage('token.json')
    creds = store.get()
    if not creds or creds.invalid:
        # If no valid creds, open a browser window to complete OAuth flow and save token.
        flow = client.flow_from_clientsecrets('credentials.json', scope)
        creds = tools.run_flow(flow, store)

    return build(
        serviceName=service_name,
        version=service_version,
        http=creds.authorize(Http()))


if __name__ == '__main__':
    main()
```

Execute this script to print out a complete list of group email addresses.
