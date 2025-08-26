# Pull from git if enabled
if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
  # Extract authentication from origin URL
  ORIGIN_URL=$(git config --get remote.origin.url);
  if [[ "$ORIGIN_URL" =~ ^https?://([^/@]+:[^/@]+)@ ]]; then
    ORIGIN_CREDENTIALS="${BASH_REMATCH[1]}";
    ORIGIN_USERNAME="${ORIGIN_CREDENTIALS%%:*}";
    ORIGIN_PASSWORD="${ORIGIN_CREDENTIALS#*:}";
  else
    ORIGIN_CREDENTIALS="";
    ORIGIN_USERNAME="";
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

# Get the start file
FILE="{{START_FILE}}";
if [[ -d "{{START_FILE}}" ]]; then
  # Search given directory
  FILE=$(find "{{START_FILE}}" -name "*.py" | head -n 1);
  if [[ -n "$FILE" ]]; then
    echo "Found start file in {{START_FILE}}: $FILE";
  fi;
fi;

# Check if start file exists
if [[ ! -e "$FILE" ]]; then
  echo -e "\e[31mNo start file found!";
  exit 1;
fi;

# Install requirements
if [[ -e "requirements.txt" ]]; then
  pip install -r requirements.txt;
fi;

# Start application
python "$FILE";
