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
dotnet new ${dotnet_standard_type} -o myOracleQuickstartWebApp --no-https --no-restore

## Customize standard WebApp
cd myOracleQuickstartWebApp
sed -i 's/Welcome/${dotnet_custom_text_for_standard_webapp}/g' Pages/Index.cshtml

# Optional git repo
# git clone ${dotnet_git_custom_webapp} myOracleQuickstartWebApp
# cd myOracleQuickstartWebApp

# Publish app to be ready to run as a service - Linux X86, Linux X64, Linux ARM32, Linux ARM64
dotnet restore
dotnet publish --configuration Release --runtime linux-x64 --self-contained true -p:PublishReadyToRun=true
