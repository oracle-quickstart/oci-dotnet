#!/bin/bash -x
# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Basic Asp.Net App.
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# Configure firewall
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 5000 -j ACCEPT
netfilter-persistent save

# Install DotNet
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

# Install the DotNet SDK
apt-get update; \
  apt-get install -y apt-transport-https && \
  apt-get update && \
  apt-get install -y dotnet-sdk-5.0

# Install the DotNet runtime
pt-get update; \
  apt-get install -y apt-transport-https && \
  apt-get update && \
  apt-get install -y aspnetcore-runtime-5.0

######################################
echo "Finished running setup.sh"