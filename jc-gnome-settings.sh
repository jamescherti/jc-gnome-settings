#!/usr/bin/env bash
#
# This file is part of the jc-gnome-settings:
# https://github.com/jamescherti/jc-gnome-settings
#
# Copyright (C) 2021-2024 James Cherti
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
IFS=$'\n\t' # strict mode

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

  # if ! [[ "$DESKTOP_SESSION" =~ ^gnome ]]; then
  #   echo "Error: you need to run this script from a GNOME session."
  #   exit 1
  # fi

  cd "$(dirname "${BASH_SOURCE[0]}")"

  GNOME_TERMINAL_PROFILE="" # will by set by gset_terminal
}

run() {
  echo "$@"
  "$@"
}

gset() {
  run gsettings set "$@" || return 1
  return 0
}

gset_terminal() {
  if [[ "$GNOME_TERMINAL_PROFILE" = "" ]]; then
    GNOME_TERMINAL_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')
  fi
  gset "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/" "$@" || return 1
  return 0
}

main() {
  gset org.gnome.software allow-updates false || true
  gset org.gnome.software download-updates false || true

  gset org.gnome.desktop.wm.preferences button-layout 'close:appmenu'

  # To eliminate the default 60 second delay when logging out
  gset org.gnome.SessionManager logout-prompt false

  # https://askubuntu.com/questions/1073568/preventing-window-resizing-after-resume
  gset org.gnome.desktop.interface scaling-factor 1

  gset org.gnome.desktop.datetime automatic-timezone false
  gset org.gnome.desktop.interface clock-format 12h
  gset org.gnome.desktop.interface clock-show-date true
  gset org.gnome.desktop.interface clock-show-weekday true
  gset org.gnome.desktop.interface cursor-theme Adwaita
  gset org.gnome.desktop.interface document-font-name 'DejaVu Sans 10'
  gset org.gnome.desktop.interface enable-animations true
  gset org.gnome.desktop.interface font-antialiasing 'rgba' # rgba / grayscale
  gset org.gnome.desktop.interface font-hinting 'medium'    # slight / medium / full
  gset org.gnome.desktop.interface font-name 'DejaVu Sans 10'
  gset org.gnome.desktop.interface gtk-theme Adwaita-dark # HighContrastInverse / Adwaita-dark
  gset org.gnome.desktop.interface icon-theme Adwaita
  gset org.gnome.desktop.interface monospace-font-name 'Inconsolata Bold 10'
  gset org.gnome.desktop.interface show-battery-percentage true
  gset org.gnome.desktop.media-handling automount false
  gset org.gnome.desktop.media-handling automount-open false
  gset org.gnome.desktop.media-handling autorun-never true
  gset org.gnome.desktop.notifications show-in-lock-screen false
  # gset org.gnome.desktop.input-sources xkb-options "['caps:none']" # disable caps-lock
  # gset org.gnome.desktop.input-sources xkb-options "['caps:none', 'numpad:mac']"
  # gset org.gnome.desktop.input-sources xkb-options "['caps:none', 'numpad:mac', 'lv3:ralt_switch']"
  gset org.gnome.desktop.input-sources xkb-options \
    "['caps:none', 'numpad:mac', 'compose:ralt']"
  gset org.gnome.desktop.peripherals.keyboard repeat-interval 9
  gset org.gnome.desktop.peripherals.keyboard delay 300
  gset org.gnome.desktop.peripherals.keyboard numlock-state true
  gset org.gnome.desktop.peripherals.keyboard remember-numlock-state true
  gset org.gnome.desktop.peripherals.keyboard repeat true
  gset org.gnome.desktop.peripherals.mouse accel-profile adaptive
  gset org.gnome.desktop.peripherals.mouse middle-click-emulation true
  gset org.gnome.desktop.peripherals.mouse natural-scroll true
  # gset org.gnome.desktop.peripherals.mouse natural-scroll false
  # gset org.gnome.desktop.peripherals.mouse speed 1
  # gset org.gnome.desktop.peripherals.touchpad speed 0.8
  gset org.gnome.desktop.peripherals.touchpad disable-while-typing true
  gset org.gnome.desktop.peripherals.touchpad middle-click-emulation true
  gset org.gnome.desktop.peripherals.touchpad natural-scroll true
  gset org.gnome.desktop.peripherals.touchpad tap-to-click true
  gset org.gnome.desktop.peripherals.trackball accel-profile adaptive
  gset org.gnome.desktop.peripherals.trackball middle-click-emulation true
  gset org.gnome.desktop.peripherals.trackball scroll-wheel-emulation-button 3
  gset org.gnome.desktop.privacy hide-identity true

  # Number of days to keep trash and temporary files
  gset org.gnome.desktop.privacy old-files-age 7

  # Number of days to remember recently used files
  gset org.gnome.desktop.privacy recent-files-max-age 2

  gset org.gnome.desktop.privacy remember-recent-files false
  gset org.gnome.desktop.privacy remove-old-temp-files true

  # Whether to remove old files from the trash automatically
  # (old-files-age if used)
  gset org.gnome.desktop.privacy remove-old-trash-files true

  gset org.gnome.desktop.privacy show-full-name-in-top-bar false
  gset org.gnome.desktop.search-providers disable-external true
  gset org.gnome.desktop.sound event-sounds false
  gset org.gnome.desktop.wm.preferences audible-bell false
  gset org.gnome.desktop.wm.preferences mouse-button-modifier '<Alt>'

  # Resize with Super/Alt+Right Click
  gset org.gnome.desktop.wm.preferences resize-with-right-button true

  gset org.gnome.desktop.wm.preferences titlebar-font 'DejaVu Sans 10'
  gset org.gnome.mutter attach-modal-dialogs false
  gset org.gnome.mutter center-new-windows true

  # Number of milliseconds a client has to respond to a ping request in order to
  # not be detected as frozen. Using 0 will disable the alive check completely.
  # I changed it to 60 because certain programs do not respond to mouse/touchpad
  # after a few seconds.
  gset org.gnome.mutter check-alive-timeout 60000

  # false To prevent the bug "How to stop windows from changing size
  # (maximising) when dragging to screen edge in the GNOME Shell?"
  # https://superuser.com/questions/968900/how-to-stop-windows-from-changing-size-maximising-when-dragging-to-screen-edge
  gset org.gnome.mutter edge-tiling true

  # Another fix for
  # https://askubuntu.com/questions/154377/how-do-i-disable-auto-maximizing-of-newly-launched-windows-in-gnome
  gset org.gnome.mutter auto-maximize false

  gset org.gnome.settings-daemon.plugins.media-keys volume-step 2                     # adjust volume in smaller steps
  gset org.gnome.settings-daemon.plugins.media-keys volume-down-precise-static "['']" # ['<Shift>XF86AudioLowerVolume', '<Ctrl><Shift>XF86AudioLowerVolume']
  gset org.gnome.settings-daemon.plugins.media-keys volume-down-quiet-static "['']"   # ['<Alt>XF86AudioLowerVolume', '<Alt><Ctrl>XF86AudioLowerVolume']
  gset org.gnome.settings-daemon.plugins.media-keys volume-down-static "['']"         # Default: ['XF86AudioLowerVolume', '<Ctrl>XF86AudioLowerVolume']
  gset org.gnome.settings-daemon.plugins.media-keys volume-up-precise-static "['']"   # ['<Shift>XF86AudioRaiseVolume', '<Ctrl><Shift>XF86AudioRaiseVolume']
  gset org.gnome.settings-daemon.plugins.media-keys volume-up-quiet-static "['']"     # ['<Alt>XF86AudioRaiseVolume', '<Alt><Ctrl>XF86AudioRaiseVolume']
  gset org.gnome.settings-daemon.plugins.media-keys volume-up-static "['']"           # Default: ['XF86AudioRaiseVolume', '<Ctrl>XF86AudioRaiseVolume']
  gset org.gnome.shell disable-user-extensions true
  gset org.gnome.shell.app-switcher current-workspace-only true
  gset org.gtk.Settings.FileChooser sort-directories-first true

  gset org.gnome.settings-daemon.plugins.power power-button-action suspend

  # The num of seconds after screensaver activation before locking the screen
  gset org.gnome.desktop.screensaver lock-delay 0

  gset org.gnome.desktop.datetime automatic-timezone false
  if [[ $USER = "media" ]]; then
    gset org.gnome.settings-daemon.plugins.power idle-dim false                      # do not dim screen after a period of inactivity
    gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing      # suspend when on AC
    gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing # set suspend information
    gset org.gnome.desktop.screensaver idle-activation-enabled false
    gset org.gnome.desktop.screensaver lock-enabled false

    gset org.gnome.desktop.session idle-delay 0 # time in seconds before session is considered idle
    gset org.gnome.system.locale region en_US.UTF-8
  else
    gset org.gnome.settings-daemon.plugins.power idle-dim true                       # dim screen after a period of inactivity
    gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing      # don't suspend when on AC
    gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type suspend # set suspend information
    gset org.gnome.desktop.screensaver idle-activation-enabled true
    gset org.gnome.desktop.screensaver lock-enabled true

    gset org.gnome.desktop.session idle-delay 300                                   # time in seconds before session is considered idle
    gset org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 1800     # 30 min
    gset org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 900 # 15 min
    # gset org.gnome.system.locale region en_CA.UTF-8
    gset org.gnome.system.locale region en_US.UTF-8
  fi

  gset org.gnome.desktop.sound allow-volume-above-100-percent false

  if type -P gedit >/dev/null 2>&1; then
    gset org.gnome.gedit.preferences.editor scheme 'oblivion'
  fi

  if type -P gthumb >/dev/null 2>&1; then
    gset org.gnome.gthumb.browser sort-type 'file::name'
    gset org.gnome.gthumb.comments synchronize false
    gset org.gnome.gthumb.browser go-to-last-location false
  fi

  if type -P meld >/dev/null 2>&1; then
    gset org.gnome.meld custom-font 'monospace 16'
    gset org.gnome.meld highlight-current-line false
    gset org.gnome.meld use-system-font false
    gset org.gnome.meld wrap-mode 'none'
    gset org.gnome.meld.WindowState is-maximized true
  fi

  if type -P evince >/dev/null 2>&1; then
    gset org.gnome.Evince page-cache-size 100
  fi

  if type -P nautilus >/dev/null 2>&1; then
    gset org.gnome.nautilus.preferences click-policy single # single / double
    gset org.gnome.nautilus.preferences default-sort-order name
    gset org.gnome.nautilus.preferences show-directory-item-counts never
    gset org.gnome.nautilus.preferences show-image-thumbnails always
    gset org.gnome.nautilus.preferences open-folder-on-dnd-hover false
    gset org.gnome.nautilus.window-state initial-size "(1600, 800)"
    # gset org.gnome.nautilus.window-state sidebar-width 254
  fi
}

init
main "$@"

echo
echo "Success."
