#!/bin/bash

cd /root/.acme.sh ||exit 1

export CF_Token=""
export CF_Account_ID=""
export CF_Zone_ID=""

sh acme.sh --issue --dns dns_cf -d ""


