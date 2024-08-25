if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
  # Pull from git
  GIT_OUTPUT=$(git pull);
  echo "$GIT_OUTPUT";
fi;

# Build application
if [[ "{{BUILD_TRIGGER}}" == "Always" || ! -e "{{JAR_FILE}}" || ( "{{BUILD_TRIGGER}}" == "Git changes detected" && "$GIT_OUTPUT" != "Already up to date." ) ]]; then
  chmod +x gradlew;
  ./gradlew build;
else
  echo "Skipping build";
fi;

# Get JAR file
FILE="{{JAR_FILE}}";
if [[ -d "{{JAR_FILE}}" ]]; then
  # Search given directory
  FILE=$(find "{{JAR_FILE}}" -name "*.jar" | head -n 1);
  echo "Found JAR file in {{JAR_FILE}}: $FILE";
fi;

# Start application
java -Xms128M -Xmx{{SERVER_MEMORY}}M -Dterminal.jline=false -Dterminal.ansi=true -jar "$FILE";
