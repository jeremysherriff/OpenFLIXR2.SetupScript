#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

update_self() {
    local BRANCH
    BRANCH=${1:-origin/master}
    if run_script 'question_prompt' Y "Would you like to update OpenFLIXR2 Setup Script to ${BRANCH} now?"; then
        info "Updating OpenFLIXR2 Setup Script to ${BRANCH}."
    else
        info "OpenFLIXR2 Setup Script will not be updated to ${BRANCH}."
        return 1
    fi
    cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."
    git fetch > /dev/null 2>&1 || fatal "Failed to fetch recent changes from git."
    git reset --hard "${BRANCH}" > /dev/null 2>&1 || fatal "Failed to reset to ${BRANCH}."
    git pull > /dev/null 2>&1 || fatal "Failed to pull recent changes from git."
    git for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D > /dev/null 2>&1 || true
    chmod +x "${SCRIPTNAME}" > /dev/null 2>&1 || fatal "OpenFLIXR2 Setup Script must be executable."
}
