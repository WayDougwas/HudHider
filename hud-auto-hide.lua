local function a(a)
    local a = { prototype = {} }
    a.prototype.__index = a.prototype
    a.prototype.constructor = a
    return a
end

local function b(a, b)
    a.____super = b
    local c = setmetatable({ __index = b }, b)
    setmetatable(a, c)

    local d = getmetatable(b)
    if d then
        if type(d.__index) == "function" then c.__index = d.__index end
        if type(d.__newindex) == "function" then c.__newindex = d.__newindex end
    end

    setmetatable(a.prototype, b.prototype)
    if type(b.prototype.__index) == "function" then a.prototype.__index = b.prototype.__index end
    if type(b.prototype.__newindex) == "function" then a.prototype.__newindex = b.prototype.__newindex end
    if type(b.prototype.__tostring) == "function" then a.prototype.__tostring = b.prototype.__tostring end
end

local function c(a, ...)
    local a = setmetatable({}, a.prototype)
    a:____constructor(...)
    return a
end

local d = {}
local e = global or storage

-- =========================
-- NullHudController
-- =========================
local f = a()
f.name = "NullHudController"

function f.prototype.____constructor(a) end
function f.prototype.manual_hud_toggle(a) end
function f.prototype.manual_hud_show_everything(a) end
function f.prototype.inventory_opened(a) end
function f.prototype.inventory_closed(a) end
function f.prototype.stack_changed(a) end
function f.prototype.inventory_changed(a) end

-- =========================
-- BaseHudController
-- =========================
local g = a()
g.name = "BaseHudController"

function g.prototype.____constructor(a, player, ignore_mods, ignore_vanilla)
    a.player = player
    a.ignore_mods = ignore_mods
    a.ignore_vanilla = ignore_vanilla
end

function g.prototype.manual_hud_show_everything(a)
    a:hud_show_everything()
    e.reveal_gui = {}

    if not a.ignore_vanilla then
        a.player.game_view_settings.show_controller_gui = true
        a.player.game_view_settings.show_minimap = true
        a.player.game_view_settings.show_research_info = true
        a.player.game_view_settings.show_side_menu = true
        a.player.game_view_settings.show_alert_gui = true
    end
end

function g.prototype.manual_hud_toggle(a) end
function g.prototype.inventory_opened(a) end
function g.prototype.inventory_closed(a) end
function g.prototype.stack_changed(a) end
function g.prototype.inventory_changed(a) end

function g.prototype.hud_update(a, show)
    e.show_hud = show
    if not e.reveal_gui then e.reveal_gui = {} end

    -- HUD VANILLA
    if not a.ignore_vanilla then
        a.player.game_view_settings.show_minimap = show
        a.player.game_view_settings.show_research_info = show
        a.player.game_view_settings.show_side_menu = show
        a.player.game_view_settings.show_alert_gui = show
    end

    a:hud_update_quickbar()

    -- HUD DE MODS
    if a.ignore_mods then return end

    for _, root in pairs(a.player.gui.children) do
        for _, element in ipairs(root.children) do
            if show then
                element.visible = e.reveal_gui[element.name] or element.visible
            else
                e.reveal_gui[element.name] = element.visible
                element.visible = false
            end
        end
    end
end

function g.prototype.hud_update_quickbar(a)
    if a.ignore_vanilla then return end

    a.player.game_view_settings.show_controller_gui =
        e.show_hud
        or not a.player.is_cursor_empty()
        or a.player.in_combat
end

function g.prototype.hud_show_everything(a)
    for _, root in pairs(a.player.gui.children) do
        for _, element in ipairs(root.children) do
            element.visible = true
        end
    end
end

-- =========================
-- AutoHudController
-- =========================
local h = a()
h.name = "AutoHudController"
b(h, g)

function h.prototype.inventory_opened(a) a:hud_update(true) end
function h.prototype.inventory_closed(a) a:hud_update(false) end
function h.prototype.stack_changed(a) a:hud_update_quickbar() end
function h.prototype.inventory_changed(a) a:hud_update_quickbar() end

-- =========================
-- ManualHudController
-- =========================
local i = a()
i.name = "ManualHudController"
b(i, g)

function i.prototype.manual_hud_toggle(a)
    a:hud_update(not e.show_hud)
end

-- =========================
-- Controller factory
-- =========================
function d.get_controller(player_index)
    local settings_p = settings.get_player_settings(player_index)

    local manual =
        settings_p["hud-auto-hide-show-manual-setting"].value == true

    local ignore_mods =
        settings_p["hud-auto-hide-ignore-mods-setting"].value == true

    local ignore_vanilla =
        settings_p["hud-auto-hide-ignore-vanilla-setting"].value == false

    local player = game.get_player(player_index)
    if not player then
        return c(f)
    end

    if manual then
        return c(i, player, ignore_mods, ignore_vanilla)
    end

    return c(h, player, ignore_mods, ignore_vanilla)
end

return d
