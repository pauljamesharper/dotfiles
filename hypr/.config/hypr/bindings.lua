-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Vim-style hjkl navigation ---------------------------------------------------
-- Move the old SUPER+J / SUPER+L actions out of the way first.
o.rebind("SUPER + U", "Toggle window split", hl.dsp.layout("togglesplit"))
o.rebind("SUPER + Y", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
hl.unbind("SUPER + ALT + L")
o.rebind("SUPER + ALT + Y", "Cycle workspace layout back", "omarchy-hyprland-workspace-layout-toggle back")

-- Focus (was: SUPER+J toggle split, SUPER+K keybindings, SUPER+L cycle layout)
o.rebind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.rebind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.rebind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- Swap windows
o.rebind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.rebind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.rebind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.rebind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Keybinding help on SUPER+/ (was: monitor scaling up, moved to SUPER+CTRL+/)
o.rebind("SUPER + SLASH", "Keybindings", "omarchy-menu-keybindings")
o.rebind("SUPER + CTRL + SLASH", "Monitor scaling up", "omarchy-hyprland-monitor-scaling up")
