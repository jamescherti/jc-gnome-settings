#!/usr/bin/env bash
#
# Alternative GNOME key bindings
# (Some key bindings follow Vim-like conventions)
#
# This file is part of the jc-gnome-settings:
# https://github.com/jamescherti/jc-gnome-settings
#
# Copyright (C) 2021-2026 James Cherti
#
# Distributed under terms of the MIT license.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

set -euf -o pipefail
IFS=$'\n\t'

# shellcheck disable=SC2317
error_handler() {
  local errno="$?"
  echo "Error: ${BASH_SOURCE[1]}:${BASH_LINENO[0]}" \
    "(${BASH_COMMAND} exited with status $errno)" >&2
  exit "${errno}"
}

init() {
  trap "error_handler" ERR
  set -o errtrace

  if [ "$(id -u)" -eq "0" ]; then
    echo "Error: root privileges are not required to run this script." >&2
    exit 1
  fi

  cd "$(dirname "${BASH_SOURCE[0]}")"
}

run() {
  echo "$@"
  "$@"
}

gset() {
  run gsettings set "$@" || return 1
  return 0
}

main() {
  # Rebind Super+n from the default Super+s to free Super+s for activating the
  # screensaver
  if type -P gnome-shell &>/dev/null; then
    gset org.gnome.shell.keybindings toggle-quick-settings "['<Super>n']"
  fi
  gset org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>s']"

  gset org.gnome.desktop.wm.keybindings minimize "['<Control><Alt>d']"

  gset org.gnome.desktop.wm.keybindings activate-window-menu '@as []'
  gset org.gnome.desktop.wm.keybindings close "['<Control><Alt>z']"
  gset org.gnome.desktop.wm.keybindings maximize "['<Super>k']"
  gset org.gnome.mutter.keybindings toggle-tiled-left "['<Super>h']"
  gset org.gnome.mutter.keybindings toggle-tiled-right "['<Super>l']"

  gset org.gnome.settings-daemon.plugins.media-keys \
    decrease-text-size "['<Super>minus']"

  gset org.gnome.settings-daemon.plugins.media-keys \
    increase-text-size "['<Shift><Super>equal']"

  # gset org.gnome.shell.keybindings show-screenshot-ui "['<Control><Alt>c']"

  gset org.gnome.shell.keybindings toggle-overview "['<Control><Alt>w']"

  # Vim-like keybindings (move workspace left/right)
  gset org.gnome.desktop.wm.keybindings move-to-workspace-left \
    "['<Shift><Control><Alt>h']"
  gset org.gnome.desktop.wm.keybindings move-to-workspace-right \
    "['<Shift><Control><Alt>l']"

  # Vim-like keybindings (switch to workspace)
  gset org.gnome.desktop.wm.keybindings \
    switch-to-workspace-left "['<Control><Alt>h']"
  gset org.gnome.desktop.wm.keybindings \
    switch-to-workspace-right "['<Control><Alt>l']"

  gset org.gnome.desktop.wm.keybindings cycle-windows "['<Alt>Tab']"

  gset org.gnome.desktop.wm.keybindings \
    cycle-windows-backward "['<Shift><Alt>Tab']"

  gset org.gnome.desktop.wm.keybindings switch-applications "@as []"
  gset org.gnome.desktop.wm.keybindings switch-applications-backward " @as []"

}

init
main "$@"

echo
echo "Success."
