#!/usr/bin/env bash

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(cat /etc/hostname)

# Options
shutdown=' Shutdown'
reboot=' Reboot'
lock=' Lock'
suspend='  Suspend'
logout='  Logout'
yes='וֹ Yes'
no='תּ No'

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p "$host" \
    -mesg "Uptime: $uptime"
}

# Confirmation CMD
confirm_cmd() {
  rofi -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?'
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
      mpc -q pause
      amixer set Master mute
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
        openbox --exit
      elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
        bspc quit
      elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
        i3-msg exit
      elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
        qdbus org.kde.ksmserver /KSMServer logout 0 0 0
      elif [[ "${DESKTOP_SESSION,,}" == 'hyprland' ]] || [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
        hyprctl dispatch exit 1
      fi
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case $chosen in
  $shutdown)
    run_cmd --shutdown
    ;;
  $reboot)
    run_cmd --reboot
    ;;
  $lock)
    if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]] && command -v hyprlock &>/dev/null; then
      hyprlock
    elif [[ -x '/usr/bin/betterlockscreen' ]]; then
      betterlockscreen -l
    elif [[ -x '/usr/bin/i3lock' ]]; then
      i3lock
    elif command -v swaylock &>/dev/null; then
      swaylock
    fi
    ;;
  $suspend)
    run_cmd --suspend
    ;;
  $logout)
    run_cmd --logout
    ;;
esac
