#!/bin/bash

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$APIGEE_PROJECT" ]; then
  echo "No APIGEE_PROJECT variable set"
  exit
fi

if [ -z "$APIGEE_ENV" ]; then
  echo "No APIGEE_ENV variable set"
  exit
fi

if [ -z "$APIGEE_HOST" ]; then
  echo "No APIGEE_HOST variable set"
  exit
fi

if [ -z "$APIGEE_REGION" ]; then
  echo "No APIGEE_REGION variable set"
  exit
fi

if [ -z "$OPENAI_API_KEY" ]; then
  echo "No OPENAI_API_KEY variable set"
  exit
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo "No GEMINI_API_KEY variable set"
  exit
fi

if [ -z "$TOKEN" ]; then
  TOKEN=$(gcloud auth print-access-token)
fi

echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

gcloud config set project "$APIGEE_PROJECT"

echo "Deploying Apigee artifacts..."

echo "Updating KVM configurations"
cp config/env__envname__llm-circuit-breaking-config__kvmfile__0.json config/env__"${APIGEE_ENV}"__llm-circuit-breaking-config__kvmfile__0.json
sed -i "s/OPENAI_API_KEY/$OPENAI_API_KEY/g" config/env__"${APIGEE_ENV}"__llm-circuit-breaking-config__kvmfile__0.json
sed -i "s/GEMINI_API_KEY/$GEMINI_API_KEY/g" config/env__"${APIGEE_ENV}"__llm-circuit-breaking-config__kvmfile__0.json

echo "Importing KVMs to Apigee environment"
apigeecli kvms import -f config/env__"${APIGEE_ENV}"__llm-circuit-breaking-config__kvmfile__0.json --org "$PROJECT_ID" --token "$TOKEN"
rm config/env__"${APIGEE_ENV}"__llm-circuit-breaking-config__kvmfile__0.json


echo "Creating Data collectors..."

apigeecli datacollectors create -d "Target pool" -n dc_target_pool -p STRING --org "$APIGEE_PROJECT" --token "$TOKEN"
apigeecli datacollectors create -d "Model Provider" -n dc_provider -p STRING --org "$APIGEE_PROJECT" --token "$TOKEN"
apigeecli datacollectors create -d "Model" -n dc_provider_model -p STRING --org "$APIGEE_PROJECT" --token "$TOKEN"

echo "Creating LLM Target Report...."

curl --request POST \
  "https://apigee.googleapis.com/v1/organizations/$APIGEE_PROJECT/reports" \
  --header "Authorization: Bearer $TOKEN" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data "{\"name\":\"llm-target-report\",\"displayName\":\"LLM Target Report\",\"metrics\":[{\"name\":\"message_count\",\"function\":\"sum\"}],\"dimensions\":[\"apiproxy\",\"dc_target_pool\",\"dc_provider\",\"dc_provider_model\"],\"filter\":\"(apiproxy like 'llm-circuit-breaking-demo-v1')\",\"properties\":[{\"value\":[{}]}],\"chartType\":\"line\"}" \
  --compressed

echo "Importing and Deploying Apigee llm-circuit-breaking-demo-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./apiproxy -n llm-circuit-breaking-demo-v1 --org "$APIGEE_PROJECT" --token "$TOKEN" --disable-check | jq ."revision" -r)
apigeecli apis deploy --wait --name llm-circuit-breaking-demo-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT" --env "$APIGEE_ENV" --token "$TOKEN"

echo " "
echo "All the Apigee artifacts are successfully deployed!"
echo "You can now go back to the Colab notebook to test the sample."
echo " "
echo "Your API_ENDPOINT is: https://$APIGEE_HOST/v1/chat/completions"