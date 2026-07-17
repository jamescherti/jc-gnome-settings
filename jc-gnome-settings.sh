#!/usr/bin/env bash
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

  GNOME_TERMINAL_PROFILE="" # will be set by gset_terminal
}

run() {
  printf "%s\n" "$*"
  "$@"
}

gset() {
  local schema_path="$1"
  local key="$2"
  local value="$3"

  # Extract the schema name (everything before the first colon, if relocatable)
  local schema="${schema_path%%:*}"

  # 1. Check if the schema exists on this system
  if ! gsettings list-schemas | grep -qFx "$schema"; then
    echo "Skipping: Schema '$schema' not found."
    return 0
  fi

  # 2. Check if the key exists within the schema
  if ! gsettings list-keys "$schema_path" 2>/dev/null | grep -qFx "$key"; then
    echo "Skipping: Key '$key' not found in '$schema_path'."
    return 0
  fi

  # 3. Apply the setting
  run gsettings set "$schema_path" "$key" "$value" || return 0
}

gset_terminal() {
  # First ensure the profile list schema exists
  if ! gsettings list-schemas | grep -qFx "org.gnome.Terminal.ProfilesList"; then
    return 0
  fi

  if [[ "$GNOME_TERMINAL_PROFILE" = "" ]]; then
    GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')
  fi

  if [[ -z "$GNOME_TERMINAL_PROFILE" ]]; then
    return 0
  fi

  gset "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/" "$@" || return 0
}

gnome_terminal() {
  gset_terminal scroll-on-keystroke true
  gset_terminal cursor-shape "'ibeam'"
  gset_terminal cursor-blink-mode "'off'"
}

gnome_privacy() {
  gset org.gnome.desktop.privacy hide-identity true
  gset org.gnome.desktop.notifications show-in-lock-screen false
  gset org.gnome.desktop.privacy old-files-age 7
  gset org.gnome.desktop.privacy recent-files-max-age 2
  gset org.gnome.desktop.privacy remember-recent-files false
  gset org.gnome.desktop.privacy remove-old-temp-files true
  gset org.gnome.desktop.privacy show-full-name-in-top-bar false
  gset org.gnome.desktop.search-providers disable-external true
}

gnome_security() {
  gset org.gnome.desktop.media-handling automount false
  gset org.gnome.desktop.media-handling automount-open false
  gset org.gnome.desktop.media-handling autorun-never true
}

gnome_mutter() {
  gset org.gnome.mutter center-new-windows true
  gset org.gnome.mutter attach-modal-dialogs true
  gset org.gnome.mutter check-alive-timeout 60000
  gset org.gnome.mutter edge-tiling true
  gset org.gnome.mutter auto-maximize false
}

gnome_peripheral() {
  gset org.gnome.desktop.peripherals.keyboard repeat-interval 9
  gset org.gnome.desktop.peripherals.keyboard delay 300
  gset org.gnome.desktop.peripherals.keyboard numlock-state true
  gset org.gnome.desktop.peripherals.keyboard remember-numlock-state true
  gset org.gnome.desktop.peripherals.keyboard repeat true

  gset org.gnome.desktop.peripherals.mouse accel-profile adaptive
  gset org.gnome.desktop.peripherals.mouse middle-click-emulation true
  gset org.gnome.desktop.peripherals.mouse natural-scroll true

  gset org.gnome.desktop.peripherals.touchpad disable-while-typing true
  gset org.gnome.desktop.peripherals.touchpad middle-click-emulation true
  gset org.gnome.desktop.peripherals.touchpad natural-scroll true
  gset org.gnome.desktop.peripherals.touchpad tap-to-click false

  gset org.gnome.desktop.peripherals.trackball accel-profile adaptive
  gset org.gnome.desktop.peripherals.trackball middle-click-emulation true
  gset org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button 3
}

gnome_power() {
  gset org.gnome.settings-daemon.plugins.power power-button-action suspend
  gset org.gnome.settings-daemon.plugins.power idle-dim true
  gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
  gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type suspend

  gset org.gnome.desktop.screensaver idle-activation-enabled true
  gset org.gnome.desktop.screensaver lock-enabled true
  gset org.gnome.desktop.screensaver lock-delay 0

  gset org.gnome.desktop.session idle-delay 300

  gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800
  gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900

  gset org.gnome.desktop.wm.preferences button-layout ':close'
  gset org.gnome.desktop.wm.preferences audible-bell false
  gset org.gnome.desktop.wm.preferences mouse-button-modifier '<Alt>'
  gset org.gnome.desktop.wm.preferences resize-with-right-button true
}

main() {
  SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
  cd "$SCRIPT_DIR"

  gnome_security
  gnome_privacy
  gnome_power
  gnome_peripheral
  gnome_mutter
  gnome_terminal

  gset org.gnome.SessionManager logout-prompt false
  gset org.gnome.desktop.interface show-battery-percentage true
  gset org.gnome.shell.app-switcher current-workspace-only true
  gset org.gtk.Settings.FileChooser sort-directories-first true
  gset org.gnome.desktop.datetime automatic-timezone false
  gset org.gnome.desktop.sound event-sounds false
  gset org.gnome.desktop.sound allow-volume-above-100-percent false

  gset org.gnome.gthumb.browser sort-type 'file::name'
  gset org.gnome.gthumb.comments synchronize false
  gset org.gnome.gthumb.browser go-to-last-location false

  gset org.gnome.meld highlight-current-line false
  gset org.gnome.meld use-system-font false
  gset org.gnome.meld wrap-mode 'none'
  gset org.gnome.meld.WindowState is-maximized true

  gset org.gnome.Evince page-cache-size 100

  gset org.gnome.nautilus.preferences click-policy single
  gset org.gnome.nautilus.preferences default-sort-order name
  gset org.gnome.nautilus.preferences show-directory-item-counts never
  gset org.gnome.nautilus.preferences show-image-thumbnails always
  gset org.gnome.nautilus.preferences open-folder-on-dnd-hover false
  gset org.gnome.nautilus.window-state initial-size "(1600, 800)"

  gset org.gnome.desktop.datetime automatic-timezone false
  gset org.gnome.desktop.interface clock-show-date true
  gset org.gnome.desktop.interface clock-show-weekday true
  gset org.gnome.desktop.interface clock-format 12h
}

init
main "$@"

echo
echo "Success."
