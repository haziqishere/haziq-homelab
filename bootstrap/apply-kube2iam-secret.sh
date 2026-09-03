#!/usr/bin/env bash

## This scrip intends to run local. Add aws credentials in the placeholder (which sits in secrets/ dir )
set -euo pipefail

CREDS="$(dirname "$0")/../secrets/kube2iam-aws-credentials.json"

kubectl create secret generic kube2iam-aws-credentials \
  -n kube-system \
  --from-literal=AWS_ACCESS_KEY_ID="$(jq -r .AWS_ACCESS_KEY_ID "$CREDS")" \
  --from-literal=AWS_SECRET_ACCESS_KEY="$(jq -r .AWS_SECRET_ACCESS_KEY "$CREDS")" \
  --dry-run=client -o yaml | kubectl apply -f -
