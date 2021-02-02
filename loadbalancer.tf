# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_load_balancer_load_balancer" "dotnet_lb" {
  compartment_id = var.compartment_ocid
  display_name   = "DotNet-${random_string.deploy_id.result}"
  shape          = var.lb_shape
  subnet_ids     = [oci_core_subnet.dotnet_lb_subnet.id]
  is_private     = "false"
  freeform_tags  = local.common_tags
}

resource "oci_load_balancer_backend_set" "dotnet_bes" {
  name             = "dotnet-${random_string.deploy_id.result}"
  load_balancer_id = oci_load_balancer_load_balancer.dotnet_lb.id
  policy           = "IP_HASH"

  health_checker {
    port                = local.app_port_number
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    return_code         = 200
    interval_ms         = 5000
    timeout_in_millis   = 2000
    retries             = 10
  }
}

resource "oci_load_balancer_backend" "dotnet-be" {
  load_balancer_id = oci_load_balancer_load_balancer.dotnet_lb.id
  backendset_name  = oci_load_balancer_backend_set.dotnet_bes.name
  ip_address       = element(oci_core_instance.app_instance.*.private_ip, count.index)
  port             = local.app_port_number
  backup           = false
  drain            = false
  offline          = false
  weight           = 1

  count = var.num_instances
}

resource "oci_load_balancer_listener" "dotnet_listener_80" {
  load_balancer_id         = oci_load_balancer_load_balancer.dotnet_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.dotnet_bes.name
  name                     = "dotnet-${random_string.deploy_id.result}-80"
  port                     = local.http_port_number
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}

resource "oci_load_balancer_listener" "dotnet_listener_443" {
  load_balancer_id         = oci_load_balancer_load_balancer.dotnet_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.dotnet_bes.name
  name                     = "dotnet-${random_string.deploy_id.result}-443"
  port                     = local.https_port_number
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}