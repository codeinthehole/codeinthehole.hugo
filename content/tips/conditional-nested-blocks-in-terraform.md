+++
title = "Conditional nested blocks in Terraform"
date = 2020-07-14T22:05:23+01:00
description = "Using dynamic blocks to implement a maintenance mode."
tags = ["terraform"]
+++

<!-- INTRODUCTION -->

Here's a useful technique for using Terraform's
[`dynamic` blocks](https://www.terraform.io/docs/configuration/expressions.html#dynamic-blocks)
to create conditional nested blocks.

<!-- CONTENT -->

## Maintenance mode

As an example, let's create a "maintenance mode" for a service which allows a
"under maintenance" holding page to be served when a Terraform variable is set.

This is useful if you need to stop all traffic to a RDS database server so it
can be upgraded.

Define a boolean `maintenance_mode` variable:

```terraform
# variables.tf

variable "maintenance_mode" {
  type    = bool
  default = false
}
```

and use it to create conditional `default_action` blocks in an `aws_lb_listener`
resource.

```terraform
# main.tf

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  dynamic "default_action" {
    for_each = var.maintenance_mode ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this.arn
    }
  }

  dynamic "default_action" {
    for_each = var.maintenance_mode ? [1] : []
    content {
      type = "fixed-response"
      fixed_response {
        content_type = "text/html"
        message_body = file("${path.module}/pages/scheduled-maintenance.html")
        status_code  = "503"
      }
    }
  }
}
```

If `maintenance_mode` is `false`, the load balancer will forward traffic to the
target group as normal. But if `true`, a HTTP 503 response will be returned with
a simple HTML payload.

This allows you to easily adjust a load balancer to serve a temporary holding
page, which gives you time to perform whatever maintenance you need to do.

Only downside is the `message_body` attribute must be 1024 bytes or fewer, so
you need quite a minimal "under maintenance" page.

Idea from
[this comment](https://github.com/hashicorp/terraform/issues/19853#issuecomment-589988711)
from the Terraform Github repository.

Further reading:

- [Terraform docs on `dynamic` blocks](https://www.terraform.io/docs/configuration/expressions.html#dynamic-blocks)

- [AWS docs on fixed-response actions](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#fixed-response-actions)
