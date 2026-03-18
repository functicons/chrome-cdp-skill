#!/usr/bin/env bash
# install.sh — Set up native messaging host for Tab Control
#
# Usage: ./install.sh <chrome-extension-id>
#
# Steps:
#   1. Load the extension in Chrome (chrome://extensions → Load unpacked)
#   2. Copy the extension ID shown on the extensions page
#   3. Run: ./install.sh <extension-id>
#
# This creates the native messaging host manifest so Chrome can launch
# the native-host.mjs bridge process when the extension connects.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_NAME="com.anthropic.cdp_tab_control"
HOST_WRAPPER="${SCRIPT_DIR}/native-host-wrapper.sh"
HOST_SCRIPT="${SCRIPT_DIR}/native-host.mjs"

main() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <chrome-extension-id>"
    echo ""
    echo "To find your extension ID:"
    echo "  1. Open chrome://extensions"
    echo "  2. Enable Developer mode (top-right toggle)"
    echo "  3. Load the extension from: ${SCRIPT_DIR}/../extension"
    echo "  4. Copy the ID shown under the extension name"
    exit 1
  fi

  local ext_id="$1"

  # Validate extension ID format (32 lowercase letters)
  if ! echo "${ext_id}" | grep -qE '^[a-z]{32}$'; then
    echo "Warning: Extension ID '${ext_id}' doesn't match expected format (32 lowercase letters)."
    echo "Proceeding anyway..."
  fi

  # Determine manifest directory based on platform
  local manifest_dir
  case "$(uname -s)" in
    Darwin)
      manifest_dir="${HOME}/Library/Application Support/Google/Chrome/NativeMessagingHosts"
      ;;
    Linux)
      manifest_dir="${HOME}/.config/google-chrome/NativeMessagingHosts"
      ;;
    *)
      echo "Error: Unsupported platform $(uname -s)"
      exit 1
      ;;
  esac

  mkdir -p "${manifest_dir}"

  # Make scripts executable
  chmod +x "${HOST_WRAPPER}" "${HOST_SCRIPT}"

  # Write native messaging host manifest
  local manifest_file="${manifest_dir}/${HOST_NAME}.json"
  cat > "${manifest_file}" <<MANIFEST
{
  "name": "${HOST_NAME}",
  "description": "Tab Control — bridge for Chrome extension to CLI",
  "path": "${HOST_WRAPPER}",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://${ext_id}/"
  ]
}
MANIFEST

  echo "Native messaging host installed:"
  echo "  Manifest: ${manifest_file}"
  echo "  Host:     ${HOST_WRAPPER} -> ${HOST_SCRIPT}"
  echo "  Extension: ${ext_id}"
  echo ""
  echo "Setup complete. Click the Tab Control extension icon to share tabs."
}

main "$@"
