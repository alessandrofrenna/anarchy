FILE_PATH="/etc/modprobe.d/hid_apple.conf"
CONFIG_LINE="options hid_apple fnmode=2"

# Check if the configuration line does NOT exist in the file
# grep -q: quiet mode, exits immediately with status 0 if found
# ! grep: executes the 'if' block if grep does not find the line
if ! grep -qF -- "${CONFIG_LINE}" "${FILE_PATH}" 2>/dev/null; then
  # Append the line if it doesn't exist
  echo "${CONFIG_LINE}" | sudo tee -a "${FILE_PATH}" >/dev/null
  echo "Configuration for Apple (or compatible) keyboards successfully added"
else
  echo "Configuration for Apple (or compatible) keyboards already exists"
fi