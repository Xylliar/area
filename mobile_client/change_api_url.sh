#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <new_api_url>"
  exit 1
fi

NEW_API_URL=$1
ENV_FILE=".env"

# Check if the .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "The .env file does not exist at path: $ENV_FILE"
  exit 1
fi

# Replace the API_URL value in the .env file
if grep -q "^API_URL=" "$ENV_FILE"; then
  sed -i '' "s|^API_URL=.*|API_URL=$NEW_API_URL|" "$ENV_FILE"
else
  echo "API_URL=$NEW_API_URL" >> "$ENV_FILE"
fi

echo "API_URL has been updated to $NEW_API_URL"