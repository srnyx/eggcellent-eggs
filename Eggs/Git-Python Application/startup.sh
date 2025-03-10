# Pull from git if enabled
if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
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
