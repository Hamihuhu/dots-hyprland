-- Custom window, layer, and workspace rules
-- Window/layer rules: https://wiki.hyprland.org/Configuring/Window-Rules/
-- Workspace rules: https://wiki.hyprland.org/Configuring/Workspace-Rules/

-- ######## Window rules ########

-- Global transparency for all windows
hl.window_rule({
    match = { class = ".*" },
    opacity = "0.95 override 0.88 override",
})

-- Unity should remain fully opaque
hl.window_rule({
    match = { class = "Unity" },
    opacity = "1.0 override 0.88 override",
})

hl.window_rule({
    match = { class = "firefox", title = ".*YouTube.*" },
    opacity = "1.0 override 1.0 override",
})
hl.window_rule({
    match = { class = "firefox", title = ".*Picture-in-Picture.*" },
    opacity = "1.0 override 1.0 override",
})

-- Game: Path to Nowhere
hl.window_rule({
    match = { initial_title = "^(Path to Nowhere).*" },
    float = true,
    size = { "(monitor_w*0.5)", "(monitor_h*0.5)" },
})

-- Show Key floating window
hl.window_rule({
    match = { title = "^(Floating Window - Show Me The Key).*" },
    float = true,
    size = { "(monitor_w*0.1)", "(monitor_h*0.05)" },
    pin = true,
})

-- ######## Unity Editor rules #########
-- Unity floating dialogs (stay focused)
hl.window_rule({
    match = { class = "^(Unity)$", title = "^(Select).*" },
    center = true,
})

local unity_floating_titles = {
    "^(Select).*",
    ".*(Color).*",
}

for _, t in ipairs(unity_floating_titles) do
    hl.window_rule({
        match = { class = "^(Unity)$", initial_title = t },
        stay_focused = true,
    })
end
-------------------------------------

-- Unity tooltip windows (no focus)
local unity_tooltip_titles = {
    "^(UnityTooltipWindow)$",
    "^(Unity)$",
}

for _, t in ipairs(unity_tooltip_titles) do
    hl.window_rule({
        match = { class = "^(Unity)$", title = t },
        no_initial_focus = true,
        no_focus = true,
    })
end
------------------------------------

-- Unity popup dialogs (centered)
local unity_popup_titles = {
    "^(Warning).*",
    "^(Can not).*",
    "^(Missing Project ID).*",
    "^(Inspector - Unsaved Changes Detected).*",
    "^(Cannot restructure Prefab instance).*",
    ".*(have been modified).*",
    "^(Delete).*",
    ".*(Discard).*",
    ".*(Recovering Scene Backups).*",
    ".*(Entering Safe Mode).*",
}

for _, t in ipairs(unity_popup_titles) do
    hl.window_rule({
        match = { class = "^(Unity)$", initial_title = t },
        center = true,
    })
end

-- Fallback: force all Unity windows to the first Unity editor window found.
-- This is intentionally disabled because it affects every Unity instance.
--[[
hl.on("window.open_early", function(window)
    if window.class == "Unity" and not window.title:find("<Vulkan>") then
        local workspace = nil
        for _, w in ipairs(hl.get_windows()) do
            if w.class == "Unity" and w.title:find("<Vulkan>") then
                workspace = w.workspace.id
                break
            end
        end
        if workspace ~= nil then
            hl.dispatch(hl.dsp.window.move({ workspace = workspace, follow = false, silent = true, window = window }))
        end
    end
end)
]]

-- Force Unity child windows to the workspace of the Unity editor that spawned them.
local function get_ppid(pid)
    local f = io.open("/proc/" .. tostring(pid) .. "/stat", "r")
    if not f then
        return nil
    end

    local stat = f:read("*a")
    f:close()

    local rest = stat:match("^%d+ %b() (.+)$")
    if not rest then
        return nil
    end

    local fields = {}
    for x in rest:gmatch("%S+") do
        table.insert(fields, x)
    end

    return tonumber(fields[2])
end

local function same_process_tree(child_pid, parent_pid)
    local pid = child_pid
    while pid and pid > 1 do
        if pid == parent_pid then
            return true
        end
        pid = get_ppid(pid)
    end
    return false
end

hl.on("window.open_early", function(window)
    if window.class ~= "Unity" or window.title:find("<Vulkan>") then
        return
    end

    for _, w in ipairs(hl.get_windows()) do
        if
            w.class == "Unity"
            and w.title:find("<Vulkan>")
            and window.pid
            and w.pid
            and same_process_tree(window.pid, w.pid)
        then
            hl.dispatch(hl.dsp.window.move({
                workspace = w.workspace.id,
                follow = false,
                silent = true,
                window = window,
            }))
            return
        end
    end
end)

hl.on("window.open", function(window)
    if window.class == "Unity" and window.title:find("Select") then
        hl.dispatch(hl.dsp.window.move({
            workspace = window.workspace.id,
            follow = false,
            silent = true,
            window = window,
            center = true,
        }))
    end
end)
