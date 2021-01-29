# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_core_virtual_network" "dotnet_main_vcn" {
  cidr_block     = lookup(var.network_cidrs, "MAIN-VCN-CIDR")
  compartment_id = var.compartment_ocid
  display_name   = "dotnet-main-${random_string.deploy_id.result}"
  dns_label      = "dotnetmain${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags
}

resource "oci_core_subnet" "dotnet_main_subnet" {
  cidr_block                 = lookup(var.network_cidrs, "MAIN-SUBNET-REGIONAL-CIDR")
  display_name               = "dotnet-main-${random_string.deploy_id.result}"
  dns_label                  = "dotnetmain${random_string.deploy_id.result}"
  security_list_ids          = [oci_core_security_list.dotnet_security_list.id]
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.dotnet_main_vcn.id
  route_table_id             = oci_core_route_table.dotnet_main_route_table.id
  dhcp_options_id            = oci_core_virtual_network.dotnet_main_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = (var.instance_visibility == "Private") ? true : false
  freeform_tags              = local.common_tags
}

resource "oci_core_subnet" "dotnet_lb_subnet" {
  cidr_block                 = lookup(var.network_cidrs, ("MAIN-LB-SUBNET-REGIONAL-CIDR"))
  display_name               = "dotnet-lb-${random_string.deploy_id.result}"
  dns_label                  = "dotnetlb${random_string.deploy_id.result}"
  security_list_ids          = [oci_core_security_list.dotnet_lb_security_list.id]
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.dotnet_main_vcn.id
  route_table_id             = oci_core_route_table.dotnet_lb_route_table.id
  dhcp_options_id            = oci_core_virtual_network.dotnet_main_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
  freeform_tags              = local.common_tags
}

resource "oci_core_route_table" "dotnet_main_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.dotnet_main_vcn.id
  display_name   = "dotnet-main-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  dynamic "route_rules" {
    for_each = (var.instance_visibility == "Private") ? [1] : []
    content {
      destination       = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.dotnet_service_gateway.id
    }
  }

  dynamic "route_rules" {
    for_each = (var.instance_visibility == "Private") ? [] : [1]
    content {
      destination       = lookup(var.network_cidrs, "ALL-CIDR")
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.dotnet_internet_gateway.id
    }
  }

}

resource "oci_core_route_table" "dotnet_lb_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.dotnet_main_vcn.id
  display_name   = "dotnet-lb-${random_string.deploy_id.result}"
  freeform_tags  = local.common_tags

  route_rules {
    destination       = lookup(var.network_cidrs, "ALL-CIDR")
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.dotnet_internet_gateway.id
  }
}

resource "oci_core_nat_gateway" "dotnet_nat_gateway" {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  display_name   = "dotnet-nat-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.dotnet_main_vcn.id
  freeform_tags  = local.common_tags

  count = var.use_only_always_free_elegible_resources ? 0 : ((var.instance_visibility == "Private") ? 0 : 0)
}

resource "oci_core_internet_gateway" "dotnet_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "dotnet-internet-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.dotnet_main_vcn.id
  freeform_tags  = local.common_tags
}

resource "oci_core_service_gateway" "dotnet_service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "dotnet-service-gateway-${random_string.deploy_id.result}"
  vcn_id         = oci_core_virtual_network.dotnet_main_vcn.id
  services {
    service_id = lookup(data.oci_core_services.all_services.services[0], "id")
  }

  count = var.use_only_always_free_elegible_resources ? 0 : 1
}







