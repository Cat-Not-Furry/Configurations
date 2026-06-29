#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Selector de sesion de pantalla
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ -t 0 ] && [ -z "$SSH_TTY" ]; then
  exec sdm
fi
