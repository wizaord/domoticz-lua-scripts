#!/bin/bash
#set -x

# Declare constants

ClientID=$1
ClientSecret=$2
DeviceId=$3
BaseUrl="https://openapi.tuyaeu.com"
tuyatime=`(date +%s)`
tuyatime=$tuyatime"000"

function signTuyaCall() {
  URL=$1
  accessToken=$2

  EmptyBodyEncoded="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  tuyaUri="${ClientID}${accessToken}${tuyatime}GET\n${EmptyBodyEncoded}\n\n${URL}"
  urlSign=$(printf "$tuyaUri" | openssl sha256 -hmac  "$ClientSecret" | tr '[:lower:]' '[:upper:]' |sed "s/.* //g")
  echo "$urlSign"
}

# Get Access Token
function getTuyaAccessToken() {
  URL="/v1.0/token?grant_type=1"
  AccessTokenSign=$(signTuyaCall "$URL" "")
  AccessTokenResponse=$(curl -sSLkX GET "$BaseUrl$URL" -H "sign_method: HMAC-SHA256" -H "client_id: $ClientID" -H "t: $tuyatime"  -H "mode: cors" -H "Content-Type: application/json" -H "sign: $AccessTokenSign")
  AccessToken=$(echo "$AccessTokenResponse" | sed "s/.*\"access_token\":\"//g"  |sed "s/\".*//g")
  echo "$AccessToken"
}

# Get the values for a specific device
function getTuyaDeviceJsonResponse() {
  access_token=$(getTuyaAccessToken)
  URL="/v2.0/cloud/thing/${DeviceId}/shadow/properties"
  RequestSign=$(signTuyaCall "$URL" "$access_token")
  RequestResponse=$(curl -sSLkX GET "$BaseUrl$URL" -H "sign_method: HMAC-SHA256" -H "client_id: $ClientID" -H "t: $tuyatime"  -H "mode: cors" -H "Content-Type: application/json" -H "sign: $RequestSign" -H "access_token: $access_token")
  echo "${RequestResponse}"
}

panneauxSolaireResponse=$(getTuyaDeviceJsonResponse)
echo "${panneauxSolaireResponse}"
#cur_power=$(echo "${panneauxSolaireResponse}" | jq -r '.result[0].status[] | select(.code == "cur_power") | .value')
#cur_voltage=$(echo "${panneauxSolaireResponse}" | jq -r '.result[0].status[] | select(.code == "cur_voltage") | .value')
#
#echo "Current power is $cur_power"
#echo "Current voltage is $cur_voltage"