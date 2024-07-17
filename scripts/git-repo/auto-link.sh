#!/bin/bash

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $2" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/NHSDigital/$1/autolinks \
  -d '{"key_prefix":"CCM-","url_template":" https://nhsd-jira.digital.nhs.uk/browse/CCM-<num>","is_alphanumeric":true}'
