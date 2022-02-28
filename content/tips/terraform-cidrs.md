+++
title = "Maintainable Terraform CIDR lists"
date = 2020-07-08
description = "HCL allows comments, which is useful."
tags = ["terraform"]
+++

## Problem

Your Terraform config requires managing many CIDRs that control firewall ingress
rules. You've been storing these in a CSV string:

```terraform
variable "client_cidrs" {
    default="50.1.1.1/32,44.2.1.0/32",
}
```

which is fed to a `aws_security_group` somewhere in your configuration.

The CIDRs change frequently and maintaining this variable is difficult as it's
hard to track where each individual CIDR came from.

## Solution

Use a HCL list variable which allows each entry to have an associated comment
explaining what the CIDR corresponds to:

```hcl
variable "client_cidrs" {
    type="list",
    default=[
        "1.1.1.1/32", # London office
        "2.2.2.2/32", # Sydney office
    ]
}
```

If you need to pass these values around as a CSV string, use `locals` to join
the list entries:

```hcl
locals {
    ingress_cidrs = "${join(",", var.client_cidrs)}"
}
```

but prefer to pass `list`-type variables around instead.
