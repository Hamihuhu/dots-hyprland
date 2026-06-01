hl.monitor({
    output = "DVI-D-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = "1",
})

hl.monitor({
    output = "DP-1",
    mode = "1920x1080@60",
    position = "1920x0",
    scale = "1",
})

hl.monitor({
    output = "HDMI-A-3",
    mode = "1920x1080@60",
    position = "0x1080",
    scale = "1",
})

-- Workspace rules
hl.workspace_rule({ workspace = "1", monitor = "DVI-D-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", persistent = true, default = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-3", persistent = true, default = true })

