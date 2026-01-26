#!/bin/bash
# Streamlit Deploy Script with Safety Checks

set -e

CONNECTION="${2:-your_connection}"

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-directory-name> [connection-name]"
    echo ""
    echo "Available apps:"
    ls -1 "$(dirname "$0")/../Streamlit" 2>/dev/null | grep -v '.md' || echo "  No apps found"
    exit 1
fi

APP_DIR="$1"
STREAMLIT_PATH="$(dirname "$0")/../Streamlit/$APP_DIR"

# Directory existence check
if [ ! -d "$STREAMLIT_PATH" ]; then
    echo "Error: Directory not found: $STREAMLIT_PATH"
    exit 1
fi

echo "========================================="
echo "Deploying Streamlit App: $APP_DIR"
echo "Connection: $CONNECTION"
echo "========================================="
echo ""

# Move to directory
cd "$STREAMLIT_PATH"

# Configuration file check
if [ ! -f "snowflake.yml" ]; then
    echo "Error: snowflake.yml not found"
    exit 1
fi

if [ ! -f "streamlit_app.py" ]; then
    echo "Error: streamlit_app.py not found"
    exit 1
fi

echo "✓ Configuration files validated"

# Validate query_warehouse in snowflake.yml
if ! grep -q "query_warehouse" snowflake.yml; then
    echo "Warning: query_warehouse not found in snowflake.yml"
fi

echo ""

# Deploy
echo "Deploying to Snowflake..."
snow streamlit deploy --connection "$CONNECTION" --replace

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""

# Get app URL
APP_NAME=$(grep "name:" snowflake.yml | head -1 | awk '{print $2}' | tr -d '"' | tr -d "'")
if [ -n "$APP_NAME" ]; then
    echo "Getting app URL..."
    snow streamlit get-url "$APP_NAME" --connection "$CONNECTION"
fi
