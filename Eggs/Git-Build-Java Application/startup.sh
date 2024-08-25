# Pull from git if enabled
if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
  GIT_OUTPUT=$(git pull);
  echo "$GIT_OUTPUT";
fi;

# Build application
if [[ "{{BUILD_TRIGGER}}" == "Always" || ! -e "{{JAR_FILE}}" || ( "{{BUILD_TRIGGER}}" == "Git changes detected" && "$GIT_OUTPUT" != "Already up to date." ) ]]; then
  TOOL={{BUILD_TOOL}};

  # Automatic (detect)
  if [[ "$TOOL" == "Automatic" ]]; then
    if [[ -f gradlew ]]; then
      TOOL="Gradle";
    elif [[ -f mvnw ]]; then
      TOOL="Maven";
    else
      echo -e "No build tool detected (make sure your wrapper is set-up correctly)";
      exit 1;
    fi;
  fi;

  if [[ "$TOOL" == "Gradle" ]]; then
    # Gradle
    echo "Building with Gradle";
    chmod +x gradlew;
    ./gradlew build;
  elif [[ "$TOOL" == "Maven" ]]; then
    # Maven
    echo "Building with Maven";
    ./mvnw clean package;
  fi;
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
