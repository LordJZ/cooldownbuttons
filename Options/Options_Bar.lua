--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CDB_Options = CDB_Options
local API = CDB_OptionsApi
local L = CDB.L

local opt_directions = {
    ["up"]    = L["OPT_DIRECTIONS_UP"],
    ["down"]  = L["OPT_DIRECTIONS_DOWN"],
    ["left"]  = L["OPT_DIRECTIONS_LEFT"],
    ["right"] = L["OPT_DIRECTIONS_RIGHT"],
}
local opt_mr_directions = {
    ["right-down"] = L["OPT_MULTI_DIRECTIONS_RIGHTDOWN"],
    ["right-up"]   = L["OPT_MULTI_DIRECTIONS_RIGHTUP"],
    ["left-down"]  = L["OPT_MULTI_DIRECTIONS_LEFTDOWN"],
    ["left-up"]    = L["OPT_MULTI_DIRECTIONS_LEFTUP"],

    ["down-right"] = L["OPT_MULTI_DIRECTIONS_DOWNRIGHT"],
    ["down-left"]  = L["OPT_MULTI_DIRECTIONS_DOWNLEFT"],
    ["up-right"]   = L["OPT_MULTI_DIRECTIONS_UPRIGHT"],
    ["up-left"]    = L["OPT_MULTI_DIRECTIONS_UPLEFT"],
}
local opt_text_directions = {
    ["up"]     = L["OPT_TEXT_DIRECTIONS_ABOVE"],
    ["down"]   = L["OPT_TEXT_DIRECTIONS_BELOW"],
    ["left"]   = L["OPT_TEXT_DIRECTIONS_LEFT"],
    ["right"]  = L["OPT_TEXT_DIRECTIONS_RIGHT"],
    ["center"] = L["OPT_TEXT_DIRECTIONS_CENTER"],
}
local opt_text_style = {
    ["00:00m"] = "00:00[h]",
    ["00:00M"] = "00:00[H]",
    ["0m"]     = "00[m||h]",
    ["0M"]     = "00[M||H]",
}
local opt_text_outline = {
    ["none"]         = L["OPT_TEXT_OUTLINE_NONE"],
    ["OUTLINE"]      = L["OPT_TEXT_OUTLINE_THIN"],
    ["THICKOUTLINE"] = L["OPT_TEXT_OUTLINE_THICK"],
}

function CDB_Options:LoadBarSettings()
    self.options.args.bars = API:createGroup(L["GROUP_BAR"], L["GROUP_BAR_DESC"])
    local bars = self.options.args.bars.args

    -- Create new
    do
        local newbarname = ""
        local function createNewExec()
            if (newbarname ~= "") then
                local db = CDB:InitNewBar(newbarname)
                if db then
                    self:AddBarSettings(bars, newbarname, db)
                    LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
                end
            end
        end
        bars.createnew = API:createGroup(L["BAR_SUB_NEWBAR"], L["BAR_SUB_NEWBAR_DESC"])
        bars.createnew.args.name = API:createInput(L["BAR_NEWBAR_NAME"], L["BAR_NEWBAR_NAME_DESC"], "name")
        bars.createnew.args.okay = API:createExecute(L["BAR_NEWBAR_CREATE"], L["BAR_NEWBAR_CREATE_DESC"], "", createNewExec)
        API:injectSetGet(bars.createnew.args.name, function(k, v) newbarname = v end, function(k) return newbarname end) 
    end

    -- Preview mode
    do
        local previewduration = "1"
        local function startPreview()
            CDB:AddPreviewCooldowns(tonumber(previewduration)*60)
        end
        bars.previewmode = API:createGroup(L["BAR_SUB_PREVIEW"], L["BAR_SUB_PREVIEW_DESC"])
        bars.previewmode.args.name = API:createInput(L["BAR_PREVIEW_DURATION"], L["BAR_PREVIEW_DURATION_DESC"], "")
        bars.previewmode.args.enable = API:createExecute(L["BAR_PREVIEW_ENABLE"], L["BAR_PREVIEW_ENABLE_DESC"], "", startPreview)
        
        API:injectSetGet(bars.previewmode, function(k, v) previewduration = v end, function(k) return previewduration end) 
    end
    
    local barsdb = CDB.db.profile.bars
    for name, db in pairs(barsdb) do
        self:AddBarSettings(bars, name, db)
    end
end

function CDB_Options:RemoveBarSettings(bars, name)
    CDB:RemoveBar(name)
    bars[name] = nil 
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
end

function CDB_Options:AddBarSettings(bars, name, db)
    bars[name] = API:createGroup(name)
    do
        bars[name].args.anchor = API:createExecute(L["BAR_SHOW_ANCHOR"], L["BAR_SHOW_ANCHOR_DESC"], "", function()
                local bar = CDB.engine.bars[name].anchor
                if bar:IsShown() then
                    bar:Hide()
                    bars[name].args.anchor.name = L["BAR_SHOW_ANCHOR"]
                    bars[name].args.anchor.desc = L["BAR_SHOW_ANCHOR_DESC"]
                else
                    bar:Show()
                    bars[name].args.anchor.name = L["BAR_HIDE_ANCHOR"]
                    bars[name].args.anchor.desc = L["BAR_HIDE_ANCHOR_DESC"]
                end
        end)
        bars[name].args.remove = API:createExecute(L["BAR_REMOVE_BAR"], L["BAR_REMOVE_BAR_DESC"], "", function() self:RemoveBarSettings(bars, name) end, L["BAR_REMOVE_CONFIRM"])
    end

    bars[name].args.positionheader = API:createHeader(L["BAR_HEADER_POSITION"])
    bars[name].args.positionX = API:createInput(L["BAR_POSITION_X"], L["BAR_POSITION_X_DESC"], "posx")
    bars[name].args.positionY = API:createInput(L["BAR_POSITION_Y"], L["BAR_POSITION_Y_DESC"], "posy")

    bars[name].args.layoutheader = API:createHeader(L["BAR_HEADER_LAYOUT"])

    bars[name].args.multirow = API:createToggle(L["BAR_USEMULTIROW"], L["BAR_USEMULTIROW_DESC"], "multirow", "full")

    bars[name].args.direction = API:createSelect(L["BAR_DIRECTION"], L["BAR_DIRECTION_DESC"], "direction", opt_directions, nil, nil, function() return db.multirow end)
    bars[name].args.rowdirection = API:createSelect(L["BAR_DIRECTION"], L["BAR_DIRECTION_DESC"], "rowdirection", opt_mr_directions, nil, nil, function() return not db.multirow end)
    bars[name].args.center = API:createToggle(L["BAR_FROM_CENTER"], L["BAR_FROM_CENTER_DESC"], "center", nil, function() return db.multirow end)

    bars[name].args.count = API:createInput(L["BAR_MAX_BUTTON"], L["BAR_MAX_BUTTON_DESC"], "count")
    bars[name].args.spacing = API:createRange(L["BAR_BUTTON_SPACING"], L["BAR_BUTTON_SPACING_DESC"], "spacing", {0, 100, 1})

    bars[name].args.countperrow = API:createInput(L["BAR_BUTTONSPERROW"], L["BAR_BUTTONSPERROW_DESC"], "countperrow", nil, nil, function() return not db.multirow end)
    bars[name].args.rowspacing = API:createRange(L["BAR_ROW_SPACING"], L["BAR_ROW_SPACING_DESC"], "rowspacing", {0, 100, 1}, nil, nil, function() return not db.multirow end)

    bars[name].args.alphascaleheader = API:createHeader(L["BAR_HEADER_ALPHASCALE"])
    bars[name].args.scale = API:createRange(L["BAR_SCALE"], L["BAR_SCALE_DESC"], "scale", {0.5, 3, 0.05})
    bars[name].args.alpha = API:createRange(L["BAR_ALPHA"], L["BAR_ALPHA_DESC"], "alpha", {0.1, 1, 0.05})

    local function enableTimer() return db.showomnicc end
    bars[name].args.submenuTimer = API:createGroup(L["BAR_SUB_TIMER"])
    bars[name].args.submenuTimer.args.extrasheader = API:createHeader(L["BAR_TIMER_HEADER_EXTRA"])
    bars[name].args.submenuTimer.args.omnicc = API:createToggle(L["BAR_TIMER_OMNICC"], L["BAR_TIMER_OMNICC_DESC"], "showomnicc", "full")
    bars[name].args.submenuTimer.args.extrasdesc = API:createDescription(L["BAR_TIMER_OMNICC_EXTRADESC"], nil, enableTimer)
    bars[name].args.submenuTimer.args.spiral = API:createToggle(L["BAR_TIMER_SPIRAL"], L["BAR_TIMER_SPIRAL_DESC"], "showspiral", nil, enableTimer)
    bars[name].args.submenuTimer.args.pulse = API:createToggle(L["BAR_TIMER_PULSE"], L["BAR_TIMER_PULSE_DESC"], "showpulse", nil, enableTimer)

    bars[name].args.submenuTimer.args.timerstyleheader = API:createHeader(L["BAR_TIMER_HEADER_STYLE"])
    bars[name].args.submenuTimer.args.showtime = API:createToggle(L["BAR_TIMER_SHOW"], L["BAR_TIMER_SHOW_DESC"], "showtime", nil, enableTimer)
    bars[name].args.submenuTimer.args.style = API:createSelect(L["BAR_TIMER_STYLE"], L["BAR_TIMER_STYLE_DESC"], "style", opt_text_style, nil, enableTimer)
    bars[name].args.submenuTimer.args.showMs = API:createToggle(L["BAR_TIMER_SHOW_MS"], L["BAR_TIMER_SHOW_MS_DESC"], "showMs", nil, enableTimer)
    bars[name].args.submenuTimer.args.showMsLimit = API:createRange(L["BAR_TIMER_SHOW_MS_LIMIT"], L["BAR_TIMER_SHOW_MS_LIMIT_DESC"], "showMsLimit", {0, 100, 1}, nil, enableTimer)

    bars[name].args.submenuTimer.args.textpositionheader = API:createHeader(L["BAR_TIMER_HEADER_POSITION"])
    bars[name].args.submenuTimer.args.distance = API:createRange(L["BAR_TIMER_SPACING"], L["BAR_TIMER_SPACING_DESC"], "textdistance", {0, 100, 1}, nil, function() if enableTimer() then return true else return (db.textdirection == "center") end end)
    bars[name].args.submenuTimer.args.direction = API:createSelect(L["BAR_TIMER_DIRECTION"], L["BAR_TIMER_DIRECTION_DESC"], "textdirection", opt_text_directions, nil, enableTimer)

    local LSM = LibStub("LibSharedMedia-3.0")
    bars[name].args.submenuFont = API:createGroup(L["BAR_SUB_FONT"])
    bars[name].args.submenuFont.args.layoutheader = API:createHeader(L["BAR_FONT_HEADER_LAYOUT"])
    bars[name].args.submenuFont.args.font = API:createFontSelect(L["BAR_FONT_FACE"], L["BAR_FONT_FACE_DESC"], "fontface", function() local fonts, newFonts = LSM:List("font"), {}; for k, v in pairs(fonts) do newFonts[v] = v; end return newFonts; end)
    bars[name].args.submenuFont.args.outline = API:createSelect(L["BAR_FONT_OUTLINE"], L["BAR_FONT_OUTLINE_DESC"], "fontoutline", opt_text_outline)
    bars[name].args.submenuFont.args.size = API:createRange(L["BAR_FONT_SIZE"], L["BAR_FONT_SIZE_DESC"], "fontsize", {5, 25, 1}, "double")
    bars[name].args.submenuFont.args.alpha = API:createRange(L["BAR_FONT_ALPHA"], L["BAR_FONT_ALPHA_DESC"], "textalpha", {0.1, 1, 0.05}, "double")

    bars[name].args.submenuFont.args.colorheader = API:createHeader(L["BAR_FONT_HEADER_COLOR"])
    bars[name].args.submenuFont.args.color = API:createColor(L["BAR_FONT_COLOR"], L["BAR_FONT_COLOR_DESC"], "color", false, "full")

    bars[name].args.submenuFont.args.flashheader = API:createHeader(L["BAR_FONT_HEADER_FLASH"])
    bars[name].args.submenuFont.args.enableflash = API:createToggle(L["BAR_FONT_FLASH"], L["BAR_FONT_FLASH_DESC"], "flash")
    bars[name].args.submenuFont.args.flashstart  = API:createInput(L["BAR_FONT_FLASHSTART"], L["BAR_FONT_FLASHSTART_DESC"], "flashstart")
    bars[name].args.submenuFont.args.flashcolor1 = API:createColor(L["BAR_FONT_FLASH1"], L["BAR_FONT_FLASH1_DESC"], "flashcolor1", false)
    bars[name].args.submenuFont.args.flashcolor2 = API:createColor(L["BAR_FONT_FLASH2"], L["BAR_FONT_FLASH2_DESC"], "flashcolor2", false)

    bars[name].args.submenuLimit = API:createGroup(L["BAR_SUB_LIMIT"], "", nil)--, true)
    bars[name].args.submenuLimit.args.limitheader = API:createHeader(L["BAR_LIMIT_HEADER_LIMIT"])
    bars[name].args.submenuLimit.args.limitMin = API:createToggle(L["BAR_LIMIT_MIN_ENABLE"], L["BAR_LIMIT_MIN_ENABLE_DESC"], "limitMin")
    bars[name].args.submenuLimit.args.limitMinTime = API:createRange(L["BAR_LIMIT_MIN_LIMIT"], L["BAR_LIMIT_MIN_LIMIT_DESC"], "limitMinTime", {3, 14400, 1})
    bars[name].args.submenuLimit.args.limitMax = API:createToggle(L["BAR_LIMIT_MAX_ENABLE"], L["BAR_LIMIT_MAX_ENABLE_DESC"], "limitMax", nil, true, true)
    bars[name].args.submenuLimit.args.limitMaxTime = API:createRange(L["BAR_LIMIT_MAX_LIMIT"], L["BAR_LIMIT_MAX_LIMIT_DESC"], "limitMaxTime", {1, 14400, 1}, nil, true, true)
    bars[name].args.submenuLimit.args.limitAfterMax = API:createToggle(L["BAR_LIMIT_AFTER_MAX_ENABLE"], L["BAR_LIMIT_AFTER_MAX_ENABLE_DESC"], "limitAfterMax", nil, true, true)

    local function notifyCfgChange(option) CDB.engine:UpdateConfig(name, db, option) end
    local function get(key) if key.type == "input" then return tostring(db[key.arg]) end return db[key.arg] end
    local function set(key, value) if key.type == "input" then if not (tonumber(value) == nil) then value = tonumber(value) end end db[key.arg] = value notifyCfgChange(key.arg) end
    local function getColor(key) local c = db[key.arg] return c.Red, c.Green, c.Blue end
    local function setColor(key, r, g, b) local c = db[key.arg] c.Red = r c.Green = g c.Blue = b notifyCfgChange(key.arg) end
    API:injectSetGet(bars[name], set, get) 
    API:injectSetGet(bars[name].args.submenuFont.args.color, setColor, getColor) 
    API:injectSetGet(bars[name].args.submenuFont.args.flashcolor1, setColor, getColor) 
    API:injectSetGet(bars[name].args.submenuFont.args.flashcolor2, setColor, getColor) 
end
