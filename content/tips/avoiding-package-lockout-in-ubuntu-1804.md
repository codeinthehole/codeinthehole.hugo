+++
title = "Avoiding package lock-out when provisioning Ubuntu 18.04 machines"
date = 2019-03-06T15:49:53Z
description = "A common, frustrating problem."
tags = ["ubuntu", "puppet", "packer"]
+++

When provisioning a virtual machine running Ubuntu 16.04 or later, a common
problem if being unable to install packages since another process is holding a
lock (eg on `/var/lib/dpkg/lock-frontend`).

## This happens as Ubuntu VMs typically start several package-management programs

[unattended-upgrades](https://help.ubuntu.com/lts/serverguide/automatic-updates.html.en)
and its associated `apt.daily` service --- on boot, and these will block your
provisioning scripts.

You'll see an error like this:

```text
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```

There's lots of internet advice on possible remedies, but it's still a deep well
of frustration. In my case, I was using [Packer](https://www.packer.io/) and
[Puppet 5.4](https://puppet.com/docs/puppet/5.4/index.html) to provision an AWS
AMI, building from a clean Ubuntu 18.04 image but spent several hours trying to
script a way past the lock-out problem. I was this close, 👉👈, to using a
`sleep` statement.

To help others suffering in this situation, here's a solution.

## Solution

Before you start provisioning, you need to stop and disable all services that
use package management. You can do that with a shell script like this:

```bash
#!/usr/bin/env bash

set -e

function killService() {
    service=$1
    sudo systemctl stop $service
    sudo systemctl kill --kill-who=all $service

    # Wait until the status of the service is either exited or killed.
    while ! (sudo systemctl status "$service" | grep -q "Main.*code=\(exited\|killed\)")
    do
        sleep 10
    done
}

function disableTimers() {
    sudo systemctl disable apt-daily.timer
    sudo systemctl disable apt-daily-upgrade.timer
}

function killServices() {
    killService unattended-upgrades.service
    killService apt-daily.service
    killService apt-daily-upgrade.service
}

function main() {
    disableTimers
    killServices
}

main
```

Here we first disable the `systemd` timers, then stop the services themselves.

Once this has run, you can run your provisioning software without fear of
locking problems. But once your provisioning is complete, the `apt-daily` timers
should be re-enabled.

Here's a snippet from a Packer JSON configuration template:

```json
{
    ...
    "provisioners": [
        {
            "type": "shell",
            "script": "shutdown-apt-services.sh"
        },
        ...
        {
            "type": "shell",
            "inline": [
                "sudo systemctl enable apt-daily.timer",
                "sudo systemctl enable apt-daily-upgrade.timer"
            ]
        }
    ]
}
```

Hope that's useful.
