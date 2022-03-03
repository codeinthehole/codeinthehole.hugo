---
title: "Installing the latest RabbitMQ on Ubuntu 18.04"
date: 2019-02-21T12:51:47Z
description: "Write-up of a painful morning."
tags: ["puppet", "rabbitmq", "ubuntu"]
---

I wasted a morning trying to install RabbitMQ v3.7.12 (the latest version as of
Feb 2019) on an Ubuntu 18.04 machine using Puppet. This as tricky as:

1. Only RabbitMQ version 3.6.10 is available from the default repositories;
2. Getting Puppet to install packages from custom locations can be painful.

## Solution

Use these Puppet modules in your `Puppetfile`:

```puppet
mod 'computology-packagecloud', '0.3.2'
mod 'garethr-erlang', '0.3.0'
mod 'puppet-rabbitmq', "9.0.0"
```

and something like this in your manifest code:

```puppet
include "erlang"

packagecloud::repo { "rabbitmq/rabbitmq-server":
    type => "deb",
}

class { "rabbitmq":
    require => [
        Packagecloud::Repo["rabbitmq/rabbitmq-server"],
        Class["erlang"],
    ]
}
```
