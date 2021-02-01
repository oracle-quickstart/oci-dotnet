#!/bin/bash -x
# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Basic Asp.Net App.
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# Stop script on NZEC
set -e
# Stop script if unbound variable found
set -u
# This is causing it to fail
set -o pipefail

# Set Variables for DotNet CLI
export HOME=/root
export DOTNET_CLI_HOME=/root
export DOTNET_CLI_TELEMETRY_OPTOUT=true

# Prepare App folder
mkdir /app && cd /app
dotnet nuget list client-cert

# Create base webApp
dotnet new webApp -o myOracleQuickstartWebApp --no-https --no-restore

# Publish app to be ready to run as a service
cd myOracleQuickstartWebApp
dotnet restore
dotnet publish --configuration Release