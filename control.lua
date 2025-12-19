local a = {}

local hud = require("hud-auto-hide")
local get_controller = hud.get_controller

script.on_event(defines.events.on_gui_closed, function(event)
    if event.gui_type == defines.gui_type.controller
        or event.gui_type == defines.gui_type.entity then
        get_controller(event.player_index):inventory_closed()
    end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.gui_type == defines.gui_type.controller
        or event.gui_type == defines.gui_type.entity then
        get_controller(event.player_index):inventory_opened()
    end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    get_controller(event.player_index):stack_changed()
end)

script.on_event(defines.events.on_player_ammo_inventory_changed, function(event)
    get_controller(event.player_index):inventory_changed()
end)

script.on_event("hud-auto-hide-show-everything", function(event)
    get_controller(event.player_index):manual_hud_show_everything()
end)

script.on_event("hud-auto-hide-show-manual", function(event)
    get_controller(event.player_index):manual_hud_toggle()
end)

return a
