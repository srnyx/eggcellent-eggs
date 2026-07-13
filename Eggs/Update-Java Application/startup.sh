# Replace JAR if update exists
if [[ -d "{{JAR_UPDATE_DIR}}" ]]; then
  NEW=$(find "{{JAR_UPDATE_DIR}}" -name "*.jar" -print -quit);

  if [[ -f "$NEW" ]]; then
    echo "Updating JAR from $NEW";
    mkdir -p "$(dirname "{{JAR_FILE}}")";
    mv -f "$NEW" "{{JAR_FILE}}";
    rm -f "$NEW";
  fi;
fi;

# Get JAR file
if [[ ! -f "{{JAR_FILE}}" ]]; then
  echo -e "\e[31mJAR file {{JAR_FILE}} not found!";
  exit 1;
fi;

# Start application
echo "Running JAR {{JAR_FILE}}";
exec java -Xms128M -Xmx{{SERVER_MEMORY}}M -Dterminal.jline=false -Dterminal.ansi=true -jar "{{JAR_FILE}}";