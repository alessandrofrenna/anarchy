#!/bin/bash

run_bg() {
  # Use coproc so stdout/stderr are not captured and rofi can exit immediately
  coproc ( "$@" >/dev/null 2>&1 )
}

write_message() {
  local icon="<span font_size=\"medium\">$1</span>"
  local text="<span font_size=\"medium\">$2</span>"
  echo -n "$icon  $text"
}