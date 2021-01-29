#!/bin/bash -x
# Copyright (c) 2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Basic Asp.Net App.
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

mkdir /app
cd /app
export DOTNET_CLI_HOME=/root
dotnet new webApp -o myWebApp --no-https
cd myWebApp
# dotnet run --urls "http://*:5000"
dotnet publish --configuration Release