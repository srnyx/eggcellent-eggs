#!/bin/bash
# Script to turn an egg's multi-line startup script into a one-line startup script for usage in Pterodactyl

# Colors
RED='\033[0;31m';
GREEN='\033[0;32m';
BOLD='\033[1m';
RESET='\033[0m';

cd ..;

# If egg name not provided in arguments, present options and ask for input
EGG_NAME="$1";
if [[ -z "$1" ]]; then
  EGGS=$(find Eggs -mindepth 1 -maxdepth 1 -type d | sed 's/Eggs\///');

  # Get available eggs, separated by newlines, without slash at the end, assigning numbers to each
  AVAILABLE_EGGS=$(echo "$EGGS" | awk '{print NR, $0}');
  echo -e "${GREEN}${BOLD}Available eggs:${GREEN}\n${AVAILABLE_EGGS}\n\n${BOLD}Enter the number of the egg you want to use:${GREEN}";
  read -r EGG_NUMBER;

  # Get egg name from number
  EGG_NAME=$(echo "$EGGS" | sed "${EGG_NUMBER}q;d");
fi;

# Navigate to egg directory
cd "Eggs/$EGG_NAME" || echo -e "${RED}Egg not found${RESET}";


STARTUP_CONTENT=$(<startup.sh); # Get startup.sh content
# shellcheck disable=SC2001
STARTUP_CONTENT=$(echo "$STARTUP_CONTENT" | sed 's/#.*//'); # Remove comments
STARTUP_CONTENT=$(echo "$STARTUP_CONTENT" | tr '\n' ' ' | tr -s ' '); # Replace newlines with spaces and remove double spaces

# Return one-line startup script
echo -e "\n${BOLD}One-line startup script:${GREEN}\n$STARTUP_CONTENT";

# Copy/exit once key is pressed
echo -e "${RED}"
read -n 1 -s -r -p "Press any key to copy and exit...";
../../Scripts/Copy\ Text\ to\ Clipboard.sh "$STARTUP_CONTENT";
