# Pull from git if enabled
if [[ -d .git && "{{PULL_START}}" == "1" ]]; then
  # Extract authentication from origin URL
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