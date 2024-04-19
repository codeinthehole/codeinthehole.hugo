+++
title = "Auditing 1Password activity"
date = 2022-06-29T21:00:01Z
description = "A few how-to guides on auditing 1Password team accounts."
tags = ["1Password"]
+++

<!-- INTRODUCTION -->

As a 1Password admin, there are common audit questions you need to answer around
who created various resources. The web dashboard is excellent but some questions
are still fiddly to answer. Questions like:

- [Who created this group?](#who-created-this-group)
- [Who created this vault?](#who-created-this-vault)
- [Who created this item?](#who-created-this-item)
- [Who has access to this item?](#who-has-access-to-this-item)

This post is a note-to-self on how to find these answers[^revision].

[^revision]:
    Advice accurate as of version 7.9.5 of the macOS, version 2.5.1 of the `op`
    CLI app and the June 2022 version of the 1Password website (revision
    `3211ea83f663` according to the `data-gitrev` attribute in the page source).

<!-- CONTENT -->

## Who created this group?

If the group hasn't had much activity, you can see the creator in the activity
timeline section of the group detail page in the web dashboard.

Most of the time though, the creation event will have scrolled off the bottom
and won't be visible:

![image](/images/screenshots/1pw-group-activity-sidebar.png)

So you need to extract the creation date of the group using the [1Password CLI
tool][op_cli] combined with [`jq`][jq]:

```bash
$ op group list --format=json | \
    jq -r '.[] | select( .name == "$GROUP_NAME" ) | .created_at'
2019-06-25T11:50:31Z
```

Once you have the creation date, use the "Jump to Date" functionality within the
"Activity Log" page (plus a bit of scrolling) to find the creation event record
which indicates the group creator.

![image](/images/screenshots/1pw-group-activity-item.png)

Pretty fiddly.

## Who created this vault?

Like groups, it's sometimes possible to see the creation event in the timeline
section of the vault detail page.

But when that doesn't work, we can't use the `op` CLI tool as the results don't
include creation dates:

```sh
$ op vault list --format=json | jq '.[] | select( .name == "$GROUP_NAME")'
{
  "id": "xggkqd3fu2nqndcxsxensdpcxe",
  "name": "Some vault",
  "content_version": 244
}
```

Fortunately, the vault creation date is shown in the usage report (which is
accessed via a "Create Usage Report" link on the vault detail page):

![image](/images/screenshots/1pw-vault-report.png)

Again we have to use the "Jump to Date" feature of the activity log and scroll
around to find the vault creator.

![image](/images/screenshots/1pw-vault-creation.png)

Very labour intensive!

## Who created this item?

Open the item's vault in the web dashboard and select the item.

If the item has never been edited, the creator's name will be displayed next to
the last modified date.

![image](/images/screenshots/1pw-item-detail.png)

Otherwise use the "View Item History" button and assume the earliest event was
creation.

![image](/images/screenshots/1pw-item-history.png)

## Who has access to this item?

This is tricky. It requires using the `op` tool to:

1. Look up the vault an item belongs to;
2. Fetch the users who have _direct_ access to the vault, and those with _group_
   access.
3. Combined the two sets of users and deduping the two lists of users.

Here's a Bash script[^bash_script] that does this.

[^bash_script]:
    This version has been simplified a little to fit on the page. Refer to [this
    Gist][gist_1pw_item_users] for an up-to-date version.

```bash
#!/usr/bin/env bash
#
# Print the users who have access to a given 1Password item.
#
# Note, the `op` tool must be authenticated before this command is run.

set -e

function main {
    local item_name="$1"

    # Determine the vault ID for the passed item.
    local vault_id
    vault_id=$(vault_id "$item_name")

    # Print the unique emails from the combined lists of direct- and
    # group-linked users.
    (
        vault_direct_user_emails "$vault_id" ;
        vault_group_user_emails "$vault_id"
    ) | sort | uniq
}

# Print the vault ID for the given item name.
function vault_id {
    op item get --format=json "$1" | jq -r '.vault.id'
}

# Print a list of user emails who have DIRECT access to a vault.
function vault_direct_user_emails {
    op vault user list --format=json "$1" | jq -r '.[].email'
}

# Print a list of user emails who have GROUP access to a vault.
function vault_group_user_emails {
    op vault group list --format=json "$1" | jq -r '.[] | .id' | \
    while read -r group_id; do
        op group user list --format=json "$group_id" | jq -r '.[].email';
    done
}

main "$@"
```

## This is harder than it should be

To any 1Password employees, this is harder than it should be. Please consider
making these questions easier to answer.

One suggestion: these questions would be easier to answer with more advanced
filtering of the activity log in the web dashboard. If we could filter by object
UUID then several of the above audit questions could be answered with a single
query.

[op_cli]: https://developer.1password.com/docs/cli/v1/get-started/
[jq]: https://stedolan.github.io/jq/
[gist_1pw_item_users]: https://gist.github.com/codeinthehole/d6b35b56ad17d9f165f86d102caf0cd7

<!-- LITERATURE REVIEW

- Basic stuff: https://dev.to/merlier/1password-cli-script-24ol

- Bash wrapper script that caches session token:
  https://github.com/dcreemer/1pass

-->
