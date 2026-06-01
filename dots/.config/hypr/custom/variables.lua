terminal =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'kitty -1' 'foot' 'alacritty' 'wezterm' 'konsole' 'kgx' 'uxterm' 'xterm'"
fileManager =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'dolphin' 'nautilus' 'nemo' 'thunar' 'kitty -1 fish -c yazi'"
browser =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'firefox' 'google-chrome-stable' 'zen-browser' 'brave' 'chromium' 'microsoft-edge-stable' 'opera' 'librewolf'"
codeEditor =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'command -v nvim && kitty -1 nvim' 'code' 'windsurf' 'antigravity' 'codium' 'cursor' 'zed' 'zedit' 'zeditor' 'kate' 'gnome-text-editor' 'emacs'  'command -v micro && kitty -1 micro'"
officeSoftware =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'wps' 'onlyoffice-desktopeditors' 'libreoffice'"
textEditor =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'command -v nvim && kitty -1 nvim' 'kate' 'gnome-text-editor' 'emacs'"
volumeMixer = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'pavucontrol-qt' 'pavucontrol'"
settingsApp =
    "XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh 'qs -p ~/.config/quickshell/$qsConfig/settings.qml' 'systemsettings' 'gnome-control-center' 'better-control'"
taskManager =
    "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'command -v btop && kitty -1 fish -c btop' 'gnome-system-monitor' 'plasma-systemmonitor --page-name Processes'"