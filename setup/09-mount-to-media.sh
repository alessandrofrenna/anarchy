UDISKS_RULE_FILE="/etc/udev/rules.d/99-udisks2.rules"
RULE='ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"'

# Check if the rule does NOT exist in the file
# grep -q: quiet mode, exits immediately with status 0 if found
# ! grep: executes the 'if' block if grep does not find the line
if ! grep -qF -- "${RULE}" "${UDISKS_RULE_FILE}" 2>/dev/null; then
  # Append the line if it doesn't exist
  echo "${RULE}" | sudo tee -a "${UDISKS_RULE_FILE}" >/dev/null
  echo "Adding rule to mount drive under /media"
else
  echo "Rule to mount drive under /media already exists"
fi

MEDIA_CONF_FILE="/etc/tmpfiles.d/media.conf"
CONFIG_LINE='D /media 0755 root root 0 -'
if ! grep -qF -- "${CONFIG_LINE}" "${MEDIA_CONF_FILE}" 2>/dev/null; then
  # Append the line if it doesn't exist
  echo "${CONFIG_LINE}" | sudo tee -a "${MEDIA_CONF_FILE}" >/dev/null
  echo "Created ${MEDIA_CONF_FILE}"
else
  echo "${MEDIA_CONF_FILE} already exists"
fi