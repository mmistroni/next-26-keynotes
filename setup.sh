#!/bin/bash

echo "===================================================="
echo "🔍 Starting GCP Credentials Configuration Script..."
echo "===================================================="

# 1. Detect if the script is being executed in a subshell or correctly sourced
# BASH_SOURCE represents the script path when sourced, whereas $0 handles execution checks.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "❌ ERROR: Script is running in an isolated SUBSHELL."
    echo "   Environment exports will be LOST when this script exits."
    echo "   👉 Please run it using: source $0  OR  . $0"
    echo "----------------------------------------------------"
else
    echo "✅ SUCCESS: Script is being SOURCED correctly."
    echo "   Variables will persist in your active terminal session."
    echo "----------------------------------------------------"
fi

# 2. Define pathing and directories
CONF_DIR="/workspaces/next-26-keynotes"
KEY_FILE="$CONF_DIR/gcp_key.json"

echo "📂 Target Directory: $CONF_DIR"
echo "📄 Target Key File Path: $KEY_FILE"

echo "⚙️ Creating directory structure..."
mkdir -p "$CONF_DIR"
if [ $? -eq 0 ]; then
    echo "   ↳ Directory exists or was created successfully."
else
    echo "   ❌ ERROR: Failed to create directory $CONF_DIR"
fi

# 3. Audit the incoming Secret/Environment Variable
echo "----------------------------------------------------"
echo "🔐 Auditing GCP_SA_KEY environment variable..."

if [ -z "${GCP_SA_KEY+x}" ]; then
    echo "   ❌ STATUS: GCP_SA_KEY is completely UNSET in this shell."
elif [ -z "$GCP_SA_KEY" ]; then
    echo "   ⚠️ STATUS: GCP_SA_KEY is initialized, but it is EMPTY (0 characters)."
else
    KEY_LENGTH=${#GCP_SA_KEY}
    echo "   ✅ STATUS: GCP_SA_KEY is populated ($KEY_LENGTH characters detected)."
    
    echo "📝 Writing string payload to $KEY_FILE..."
    printf '%s' "$GCP_SA_KEY" > "$KEY_FILE"
    
    # Verify file existence and contents on disk
    if [ -f "$KEY_FILE" ]; then
        FILE_SIZE=$(wc -c < "$KEY_FILE" | tr -d ' ')
        echo "   ↳ ✅ File written successfully! Disk size: $FILE_SIZE bytes."
    else
        echo "   ↳ ❌ ERROR: Shell reported success, but file was not found on disk."
    fi
fi

# 4. Export and verify target environmental configurations
echo "----------------------------------------------------"
echo "🚀 Exporting environmental context variables..."

export GOOGLE_APPLICATION_CREDENTIALS="$KEY_FILE"
export GOOGLE_CLOUD_PROJECT="datascience-projects"

echo "   ↳ GOOGLE_APPLICATION_CREDENTIALS set to: $GOOGLE_APPLICATION_CREDENTIALS"
echo "   ↳ GOOGLE_CLOUD_PROJECT set to: $GOOGLE_CLOUD_PROJECT"

# Double check the current environment layer can see them
echo "----------------------------------------------------"
echo "📊 Current Shell Environment Verification:"
echo "   Active Project:  $(env | grep GOOGLE_CLOUD_PROJECT || echo 'NOT FOUND')"
echo "   Active Key Path: $(env | grep GOOGLE_APPLICATION_CREDENTIALS || echo 'NOT FOUND')"
echo "===================================================="