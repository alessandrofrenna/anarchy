is_installed() {
  if $(yay -Qi ${1} &>/dev/null); then
    echo 0
    return
  fi
  echo 1
  return
}