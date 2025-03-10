#!/bin/bash

# Install dependencies
apt update
apt install -y git curl jq file unzip make gcc g++ libtool

# Make server files directory (/mnt/server)
mkdir -p /mnt/server
cd /mnt/server || exit

# Skip cloning/pulling if disabled
if [ "${CLONE_INSTALL}" == "0" ]; then
  echo -e "Assuming user knows what they are doing, have a good day"
  exit 0
fi

# Add git ending if it's not on the address
if [[ ${GIT_ADDRESS} != *.git ]]; then
  GIT_ADDRESS=${GIT_ADDRESS}.git
fi

# Check for username and password (PAT)
if [[ -z "${GIT_USERNAME}" && -z "${GIT_TOKEN}" ]]; then
  echo "Using anonymous API call (no username/password)"
else
  GIT_ADDRESS="https://${GIT_USERNAME}:${GIT_TOKEN}@$(echo -e "${GIT_ADDRESS}" | cut -d/ -f3-)"
fi

if [ "$(ls -A /mnt/server)" ]; then
  echo "/mnt/server directory is NOT empty; checking for git files"

  # Check .git config
  if [ -d .git ]; then
    echo ".git directory exists"
    if [ -f .git/config ]; then
      echo "Loading info from git config"
      ORIGIN=$(git config --get remote.origin.url)
    else
      echo "Files found with no git config; closing out without touching things to not break anything"
      exit 10
    fi
  fi

  # Pull from git
  if [ "${ORIGIN}" == "${GIT_ADDRESS}" ]; then
    echo "Pulling latest from git"
    git pull
  fi
else
  echo "/mnt/server IS empty; cloning files from repository"

  # Clone from git
  if [ -z "${GIT_BRANCH}" ]; then
    echo "Cloning default branch"
    git clone "${GIT_ADDRESS}" .
  else
    echo "Cloning ${GIT_BRANCH}"
    git clone --single-branch --branch "${GIT_BRANCH}" "${GIT_ADDRESS}" .
  fi
fi

echo "Installation complete"
exit 0
