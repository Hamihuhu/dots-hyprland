hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)
