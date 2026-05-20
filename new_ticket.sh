#!/bin/bash

PRODUCT="$1"
COMPONENT="$2"
SUMMARY="$3"
DESCRIPTION="$4"

BUGZILLA_URL="http://localhost/rest/bug"
API_KEY="YOUR_KEY"

curl -X POST "$BUGZILLA_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"api_key\": \"$API_KEY\",
    \"product\": \"$PRODUCT\",
    \"component\": \"$COMPONENT\",
    \"summary\": \"$SUMMARY\",
    \"version\": \"unspecified\",
    \"description\": \"$DESCRIPTION\",
    \"op_sys\": \"All\",
    \"rep_platform\": \"All\"
  }"
