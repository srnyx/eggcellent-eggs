#!/bin/bash
# Script to copy text to clipboard across different operating systems

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "$1" | pbcopy  # macOS
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v xclip &> /dev/null; then
        echo "$1" | xclip -selection clipboard  # Linux with xclip
    elif command -v xsel &> /dev/null; then
        echo "$1" | xsel --clipboard --input  # Linux with xsel
    fi
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    echo "$1" | clip  # Windows (Git Bash or WSL)
fi
