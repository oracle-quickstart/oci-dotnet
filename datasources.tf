# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Randoms
resource "random_string" "deploy_id" {
  length  = 4
  special = false
}

# Check for resource limits
## Check available compute shape
data "oci_limits_services" "compute_services" {
  compartment_id = var.tenancy_ocid

  filter {
    name   = "name"
    values = ["compute"]
  }
}
data "oci_limits_limit_definitions" "compute_limit_definitions" {
  compartment_id = var.tenancy_ocid
  service_name   = data.oci_limits_services.compute_services.services.0.name

  filter {
    name   = "description"
    values = [var.instance_shape]
  }
}
data "oci_limits_resource_availability" "compute_resource_availability" {
  compartment_id      = var.tenancy_ocid
  limit_name          = data.oci_limits_limit_definitions.compute_limit_definitions.limit_definitions[0].name
  service_name        = data.oci_limits_services.compute_services.services.0.name
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[count.index].name

  count = length(data.oci_identity_availability_domains.ADs.availability_domains)
}
resource "random_shuffle" "compute_ad" {
  input        = local.compute_available_limit_ad_list
  result_count = length(local.compute_available_limit_ad_list)
}
locals {
  compute_available_limit_ad_list = [for limit in data.oci_limits_resource_availability.compute_resource_availability : limit.availability_domain if(limit.available - var.num_instances) >= 0]
  compute_available_limit_error = length(local.compute_available_limit_ad_list) == 0 ? (
  file("ERROR: No limits available for the chosen compute shape and number of nodes")) : 0
}

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "compute_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid

  provider = oci.current_region
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }

  provider = oci.current_region
}

# Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  common_tags = {
    Reference = "Created by OCI QuickStart for DotNet sample"
  }
}

# Cloud Init
data "template_cloudinit_config" "instances" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }
}
data "template_file" "cloud_init" {
  template = file("${path.module}/scripts/cloud-config.template.yaml")

  vars = {
    setup_preflight_sh_content = base64gzip(data.template_file.setup_preflight.rendered)
    setup_template_sh_content  = base64gzip(data.template_file.setup_template.rendered)
    deploy_template_content    = base64gzip(data.template_file.deploy_template.rendered)
  }
}
data "template_file" "setup_preflight" {
  template = file("${path.module}/scripts/setup.preflight.sh")
}
data "template_file" "setup_template" {
  template = file("${path.module}/scripts/setup.template.sh")
}
data "template_file" "deploy_template" {
  template = file("${path.module}/scripts/deploy.template.sh")
}