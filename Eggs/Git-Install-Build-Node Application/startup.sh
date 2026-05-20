set -e;
export NODE_ENV=production;
export HOST=0.0.0.0;
export PORT={{SERVER_PORT}};
export CI=true;
corepack enable >/dev/null 2>&1 || true;

# Pull from git if enabled
if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
  # Extract authentication from origin URL
  ORIGIN_URL=$(git config --get remote.origin.url);
  ORIGIN_CREDENTIALS=$(echo "$ORIGIN_URL" | grep -oP '(?<=//)[^@]+' || echo "");
  ORIGIN_USERNAME=$(echo "$ORIGIN_CREDENTIALS" | cut -d':' -f1 || echo "");
  ORIGIN_PASSWORD=$(echo "$ORIGIN_CREDENTIALS" | cut -d':' -f2 || echo "");
  if [[ "$ORIGIN_USERNAME" == "$ORIGIN_CREDENTIALS" ]]; then
    ORIGIN_USERNAME="";
  fi;
  if [[ "$ORIGIN_PASSWORD" == "$ORIGIN_CREDENTIALS" ]]; then
    ORIGIN_PASSWORD="";
  fi;

  # If origin URL doesn't have username/password but new ones are provided, add them
  if [[ ( "$ORIGIN_USERNAME" == "$ORIGIN_CREDENTIALS" || "$ORIGIN_PASSWORD" == "$ORIGIN_CREDENTIALS" ) && ( -n "{{GIT_USERNAME}}" || -n "{{GIT_TOKEN}}" ) ]]; then
    echo "Detected credentials! Inserting them into origin URL...";
    git remote set-url origin "$(echo "$ORIGIN_URL" | sed -E "s|//|//{{GIT_USERNAME}}:{{GIT_TOKEN}}@|")";
  else
    # If usernames or passwords are different, update the origin URL
    if [[ "$ORIGIN_USERNAME" != "{{GIT_USERNAME}}" || "$ORIGIN_PASSWORD" != "{{GIT_TOKEN}}" ]]; then
      echo "Detected new credentials! Inserting them into origin URL...";
      git remote set-url origin "$(echo "$ORIGIN_URL" | sed -E "s|//[^@]+@|//{{GIT_USERNAME}}:{{GIT_TOKEN}}@|")";
    fi;
  fi;

  # Pull
  echo "Pulling latest from git...";
  GIT_OUTPUT=$(git pull);
  echo "$GIT_OUTPUT";
fi;

# Install dependencies if node_modules does not exist
if [[ ! -d node_modules ]]; then
  echo "Installing dependencies with {{PACKAGE_MANAGER}}...";
  {{PACKAGE_MANAGER}} install;
fi;

# Build application
if [[ -n "{{BUILD_SCRIPT}}" && ( "{{BUILD_TRIGGER}}" == "Always" || ( "{{BUILD_TRIGGER}}" == "Git changes detected" && "$GIT_OUTPUT" != "Already up to date." ) ) ]]; then
  echo "Building application...";
  {{PACKAGE_MANAGER}} run "{{BUILD_SCRIPT}}";
fi;

# Start application
echo "Starting application with '{{PACKAGE_MANAGER}} run {{START_SCRIPT}}'";
{{PACKAGE_MANAGER}} run "{{START_SCRIPT}}";
