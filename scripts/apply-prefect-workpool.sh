#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="$(dirname "$0")/../platform/prefect/workpool/kubernetes-pool-base-job-template.json"

curl -s -X PATCH \
  "http://prefect.haziqhakimi.online/api/work_pools/kubernetes-pool" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "import json,sys; print(json.dumps({'base_job_template': json.load(open('$TEMPLATE'))}))")"
