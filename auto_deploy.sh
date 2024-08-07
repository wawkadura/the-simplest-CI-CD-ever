#!/bin/bash

# Determine the directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Redirect all output to the log file
exec > >(tee -a "$SCRIPT_DIR/auto_deploy.log") 2>&1

# Function to check for changes and deploy
auto_deploy() {
  local dir=$1
  local branch=$2
  local service_name=$3
  local detailed_logs=$4
  shift 4
  local commands=("$@")

  if [ ! -d "$dir" ]; then
    echo "Directory $dir does not exist. Skipping..."
    return
  fi

  cd $dir || exit

  # Ensure it's a git repository
  if [ ! -d ".git" ]; then
    echo "Directory $dir is not a git repository. Skipping..."
    return
  fi

  # Fetch the latest changes
  git fetch origin $branch > /dev/null 2>&1

  # Check if there are changes
  if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
    current_date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$current_date] Changes detected in $branch of $service_name"

    # Pull changes
    git pull > /dev/null 2>&1

    # Execute the list of commands
    for cmd in "${commands[@]}"; do
      if [ "$detailed_logs" = true ]; then
        eval "$cmd"
      else
        eval "$cmd > /dev/null 2>&1"
      fi
    done

    echo "[$current_date] $branch of $dir has been updated and $service_name restarted"
  fi
}

# Ensure required tools are installed
for tool in jq git tee; do
  if ! command -v $tool &> /dev/null; then
    echo "$tool could not be found. Please install $tool."
    exit 1
  fi
done

# Read services from the JSON file
services_file="$SCRIPT_DIR/services.json"

if [ ! -f "$services_file" ]; then
  echo "File $services_file does not exist."
  exit 1
fi

services=$(cat "$services_file")

# Loop over each service and deploy
echo "$services" | jq -c '.[]' | while IFS= read -r service; do
  dir=$(echo "${service}" | jq -r '.dir')
  branch=$(echo "${service}" | jq -r '.branch')
  service_name=$(echo "${service}" | jq -r '.service_name')
  detailed_logs=$(echo "${service}" | jq -r '.detailedLogs')
  commands=$(echo "${service}" | jq -r '.commands | join(":::")')

  IFS=':::' read -r -a commands_array <<< "$commands"
  auto_deploy "$dir" "$branch" "$service_name" "$detailed_logs" "${commands_array[@]}"
done

# crontab config:
# * * * * * /path/to/cicd/folder/auto_deploy.sh
