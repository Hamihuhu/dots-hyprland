hl.bind(
    "CTRL+SUPER+ALT+Slash",
    hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"),
    { description = "Edit user keybinds" }
)

-- Gestures --
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
hl.gesture({
    fingers = 3,
    direction = "pinchin",
    action = "float",
})
hl.gesture({
    fingers = 3,
    direction = "pinchout",
    action = "fullscreen",
})
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "special",
    workspace_name = "special",
})

-- Unbind --
hl.unbind("SUPER + SHIFT + L")
hl.unbind("SUPER + L")
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + Apostrophe")
hl.unbind("SUPER + O")
hl.unbind("SUPER + X")
hl.unbind("SUPER + Q")

-- Unbind focus in direction
hl.unbind("SUPER + Left")
hl.unbind("SUPER + Right")
hl.unbind("SUPER + Up")
hl.unbind("SUPER + Down")
hl.unbind("SUPER + BracketLeft")
hl.unbind("SUPER + BracketRight")

-- Unbind move in direction
hl.unbind("SUPER + SHIFT + Left")
hl.unbind("SUPER + SHIFT + Right")
hl.unbind("SUPER + SHIFT + Up")
hl.unbind("SUPER + SHIFT + Down")

-- Bind again
for i = 1, 6 do
    local arrowkey = { "H", "L", "K", "J", "BracketLeft", "BracketRight" }
    local focusdir = { "l", "r", "u", "d", "l", "r" }
    hl.bind("SUPER + " .. arrowkey[i], hl.dsp.focus({ direction = focusdir[i] }))
end
--#/# bind = SUPER + SHIFT, ←/↑/→/↓,, -- Move in direction
for i = 1, 4 do
    local arrowkey = { "H", "L", "K", "J" }
    local focusdir = { "l", "r", "u", "d" }
    hl.bind("SUPER + SHIFT + " .. arrowkey[i], hl.dsp.window.move({ direction = focusdir[i] }))
end

hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock" })
hl.bind("SUPER + O", hl.dsp.layout("splitratio +0.1"), { repeating = true })
hl.bind("SUPER + X", hl.dsp.window.close(), { description = "Close" })
