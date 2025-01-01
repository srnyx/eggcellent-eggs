# Pull from git if enabled
if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
  GIT_OUTPUT=$(git pull);
  echo "$GIT_OUTPUT";
fi;

# Gets the JAR file
get_jar_file() {
  FILE="{{JAR_FILE}}";
  if [[ -d "{{JAR_FILE}}" ]]; then
    # Search given directory
    FILE=$(find "{{JAR_FILE}}" -name "*.jar" | head -n 1);
    if [[ -n "$FILE" ]]; then
      echo "Found JAR file in {{JAR_FILE}}: $FILE";
    fi;
  fi;
};

# Get JAR file
get_jar_file;

# Build application
if [[ "{{BUILD_TRIGGER}}" == "Always" || ! -e "$FILE" || ( "{{BUILD_TRIGGER}}" == "Git changes detected" && "$GIT_OUTPUT" != "Already up to date." ) ]]; then
  TOOL={{BUILD_TOOL}};

  # Automatic (detect)
  if [[ "$TOOL" == "Automatic" ]]; then
    if [[ -f gradlew ]]; then
      TOOL="Gradle";
    elif [[ -f mvnw ]]; then
      TOOL="Maven";
    else
      echo -e "\e[31mNo build tool detected (make sure your wrapper is set-up correctly)!";
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

# Re-get JAR file
get_jar_file;
if [[ ! -e "$FILE" ]]; then
  echo -e "\e[31mNo JAR file found!";
  exit 1;
fi;

# Start application
java -Xms128M -Xmx{{SERVER_MEMORY}}M -Dterminal.jline=false -Dterminal.ansi=true -jar "$FILE";
