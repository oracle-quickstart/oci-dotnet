# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}

variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}

# Compute
variable "num_instances" {
  default = 2
}
variable "generate_public_ssh_key" {
  default = true
}
variable "public_ssh_key" {
  default = ""
}
variable "instance_shape" {
  default = "VM.Standard.E2.1.Micro"
}
variable "image_operating_system" {
  default = "Canonical Ubuntu"
}
variable "image_operating_system_version" {
  default = "20.04"
}
variable "instance_visibility" {
  default = "Public"
}

# Network Details
variable "lb_shape" {
  default = "10Mbps-Micro"
}

variable "network_cidrs" {
  type = map(string)

  default = {
    MAIN-VCN-CIDR                = "10.1.0.0/16"
    MAIN-SUBNET-REGIONAL-CIDR    = "10.1.21.0/24"
    MAIN-LB-SUBNET-REGIONAL-CIDR = "10.1.22.0/24"
    ALL-CIDR                     = "0.0.0.0/0"
  }
}

# Always Free only or support other shapes
variable "use_only_always_free_elegible_resources" {
  default = true
}

# ORM Schema visual control variables
variable "show_advanced" {
  default = false
}