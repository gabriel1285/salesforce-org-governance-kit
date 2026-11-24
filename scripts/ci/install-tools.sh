#!/usr/bin/env bash
# Installs the Salesforce CLI and the sfdx-git-delta plugin on a CI agent.
# Used by both GitHub Actions and Azure DevOps, so the two pipelines behave the same.
set -euo pipefail

npm install --global @salesforce/cli
echo y | sf plugins install sfdx-git-delta

sf --version
sf plugins
