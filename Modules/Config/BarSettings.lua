--[[
Name: CooldownButtons
Revision: $Rev$
Author(s): Dodge (Netrox @ Sen'Jin-EU / kujanssen@gmail.com)
Website: - none -
Documentation: http://wiki.wowace.com/CooldownButtons
SVN: http://svn.wowace.com/wowace/trunk/CooldownButtons
Description: Shows simple Buttons for your Cooldowns :)
Dependencies: LibStub, Ace3, LibSink-2.0. SharedMedia-3.0, LibPeriodicTable-3.1
License: GPL v2 or later.
]]

--[[
Copyright (C) 2008 Dodge

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

local CooldownButtons = _G.CooldownButtons
CooldownButtons:CheckVersion("$Revision$")
local CooldownButtonsConfig = CooldownButtons:GetModule("Config")
local options = CooldownButtonsConfig.options
local db = CooldownButtonsConfig.db
local L = CooldownButtons.L
local LSM = LibStub("LibSharedMedia-3.0")

local getOrder, createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor = CooldownButtonsConfig:GetWidgetAPI()

local opt_directions = {
    ["up"]    = L["Up"],
    ["down"]  = L["Down"],
    ["left"]  = L["Left"],
    ["right"] = L["Right"],
}
local opt_mr_directions = {
    ["right-down"] = L["Right - Down"],
    ["right-up"]   = L["Right - Up"],
    ["left-down"]  = L["Left - Down"],
    ["left-up"]    = L["Left - Up"],
}
local opt_text_directions = {
    ["up"]    = L["Above"],
    ["down"]  = L["Below"],
    ["left"]  = L["Left"],
    ["right"] = L["Right"],
}
local opt_text_style = {
    ["00:00m"] = "00:00[h]",
    ["00:00M"] = "00:00[H]",
    ["0m"]     = "00[m||h]",
    ["0M"]     = "00[M||H]",
}

function CooldownButtonsConfig:AddBarSettings(title, moduleName, db, myOrder, savedMenu)
    self.options.args.barSettings.args[title] = createBarSettings(title, moduleName, db, myOrder, savedMenu)
--        expiringSettings = getBarLayoutOptions("expiring", L["Expiring"]),
--        savedSettings    = getBarLayoutOptions("---", L["Saved"]),
--        dotSettings      = getBarLayoutOptions("---", L["HoTs/DoTs"]),
end

function createBarSettings(title, moduleName, db, myOrder, savedMenu)
    return {
        type = "group",
        name = title,
        order = myOrder,
        set = function( k, v ,v2, v3) 
                if k.arg == "posx" then
                    if not (tonumber(v) == nil) then
                        db.pos.x = tonumber(v);
                    end
                elseif k.arg == "posy" then
                    if not (tonumber(v) == nil) then
                        db.pos.y = tonumber(v);
                    end
                elseif k.arg == "buttonCount"
                    or k.arg == "buttonCountPerRow"
                    or k.arg == "buttonSpacing"
                    or k.arg == "buttonRowSpacing" 
                    or k.arg == "textDistance"
                    or k.arg == "colorFlashStartTime"
                    or k.arg == "durationTime" then
                    if not (tonumber(v) == nil) then
                        db[k.arg] = tonumber(v);
                    end
                elseif k.arg == "fontColorBase"
                    or k.arg == "fontColorFlash1"
                    or k.arg == "fontColorFlash2" then
                    local t = db[k.arg]
                    t.Red = v
                    t.Green = v2
                    t.Blue = v3
                else
                    db[k.arg] = v
                end
              end,
        get = function( k ) 
                if k.arg == "posx" then
                    return tostring(db.pos.x)
                elseif k.arg == "posy" then
                    return tostring(db.pos.y)
                elseif k.arg == "buttonCount"
                    or k.arg == "buttonCountPerRow"
                    or k.arg == "buttonSpacing"
                    or k.arg == "buttonRowSpacing"
                    or k.arg == "textDistance"
                    or k.arg == "colorFlashStartTime"
                    or k.arg == "durationTime" then
                    return tostring(db[k.arg])
                elseif k.arg == "fontColorBase"
                    or k.arg == "fontColorFlash1"
                    or k.arg == "fontColorFlash2" then
                    local t = db[k.arg]
                    return t.Red, t.Green, t.Blue
                else
                    return db[k.arg]
                end
              end,
        args = {
            showAnchor = createExecute(L["Show Anchor"], "", moduleName, function(k)
                local module = CooldownButtons:GetModule(k.arg)
                if not module.anchorVisible then
                    k.option.name = L["Hide Anchor"]
                    module:ShowAnchor()
                else
                    k.option.name = L["Show Anchor"]
                    module:HideAnchor()
                end
                LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
            end, nil, function() return db.disableBar end, savedMenu),
            disableBar = createToggle(L["Disable"], L["Disable this Buttonbar."], "disableBar", nil, nil, savedMenu),
            
            header_00 = createHeader(L["Position"], savedMenu),
            pos_x = createInput(L["X - Axis"], L["Set the Position on X-Axis."], "posx", nil, function() return db.disableBar end, savedMenu),
            pos_y = createInput(L["Y - Axis"], L["Set the Position on Y-Axis."], "posy", nil, function() return db.disableBar end, savedMenu),
            header_01 = createHeader(L["Alpha & Scale"]),
            buttonScale = createRange(L["Button Scale"], L["Set the Button scaling."], "buttonScale", {0.5, 2.5, 0.05}, nil, function() return db.disableBar end),
            buttonAlpha = createRange(L["Button Alpha"], L["Set the Button transparency."], "buttonAlpha", {0.1, 1, 0.05}, nil, function() return db.disableBar end),

            header_10 = createHeader(L["Layout"], savedMenu),
            buttonCount = createInput(L["Max Buttons"], L["Maximal number of Buttons to display."], "buttonCount", nil, function() return db.disableBar end, savedMenu),
            buttonDirection = createSelect(L["Direction"], L["Direction from Anchor."], "buttonDirection", opt_directions, nil, function() return db.disableBar end, savedMenu),
            showCenter = createToggle(L["Center from Anchor"], L["Toggle Anchor to be the Center of the bar."], "showCenter", nil, function() return db.disableBar end, savedMenu),
            desc = createDescription(L["If you enable the \"Center from Anchor\" you can set \"Direction\" to Up/Down for vertical and Left/Right for horizontal grow."], savedMenu),

            header_20 = createHeader(L["Multi Row Layout"], savedMenu),
            buttonMultiRow = createToggle(L["Use Multirow"], L["Toggle useing Multirow."], "buttonMultiRow", nil, function() return db.disableBar end, savedMenu),
            break_20 = createDescription("", savedMenu),
            buttonCountPerRow = createInput(L["Max Buttons per Row"], L["Maximal number of Buttons per Row to display."], "buttonCountPerRow", nil, function() return db.disableBar end, savedMenu),
            buttonMRDirection = createSelect(L["Direction"], L["Direction from primary Row."], "buttonMRDirection", opt_mr_directions, nil, function() return db.disableBar end, savedMenu),

            header_30 = createHeader(L["Spacing"], savedMenu),
            buttonSpacing = createInput(L["Button Spacing"], L["Set the spacing between Buttons."], "buttonSpacing", nil, function() return db.disableBar end, savedMenu),
            buttonRowSpacing = createInput(L["Row Spacing"], L["Set the spacing between Rows."], "buttonRowSpacing", nil, function() return db.disableBar end, savedMenu),

            timerSettings = {
                type = "group",
                name = L["Timer Settings"],
                order = getOrder(),
                disabled =  function() return db.disableBar end,
                args = {
                    header_00 = createHeader(L["Extras"]),
                    showOmniCC = createToggle(L["Enable OmniCC Settings (Req. OCC >= 2.1.1)"], L["Switch to OmniCC settings."], "showOmniCC", true, function() return CooldownButtons.noOmniCC end),
                    extras = createDescription(L["The following Options are only aviable if OmniCC Settings are disabled for this Bar."]),
                    showSpiral = createToggle(L["Show Cooldown Spiral"], L["Toggle showing Cooldown Spiral on the Buttons."], "showSpiral", nil, function() return db.showOmniCC end),
                    showPulse = createToggle(L["Enable Pulse Effect"], L["Toggle Pulse effect."], "showPulse", nil, function() return db.showOmniCC end),

                    header_10 = createHeader(L["Timer Style"]),
                    showTime = createToggle(L["Show Time"], L["Toggle showing Cooldown Time at the Buttons."], "showTime", nil, function() return db.showOmniCC end),
                    textStyle = createSelect(L["Style"], L["Set how the Timertext should look like."], "textStyle", opt_text_style, nil, function() return db.showOmniCC end),

                    header_20 = createHeader(L["Text Position"]),
                    textDistance = createInput(L["Text Spacing"], L["Set the spacing between Button and Text."], "textDistance", nil, function() return db.showOmniCC end),
                    textDirection = createSelect(L["Position"], L["Position from Button."], "textDirection", opt_text_directions, nil, function() return db.showOmniCC end),
                },
            },

            textSettings = {
                type = "group",
                name = L["Font Settings"],
                order = getOrder(),
                disabled =  function() return db.showOmniCC or db.disableBar end,
                args = {
                    header_00 = createHeader(L["Font Layout"]),
                    fontFace = createSelect(L["Font Face"], L["Set the Font type."], "fontFace", function() local fonts, newFonts = LSM:List("font"), {}; for k, v in pairs(fonts) do newFonts[v] = v; end return newFonts; end),
                    fontSize = createRange(L["Font size"], L["Set the Font size."], "fontSize", {5, 25, 1}),

                    header_01 = createHeader(L["Alpha"]),
                    textAlpha = createRange(L["Text Alpha"], L["Set the Text transparency."], "textAlpha", {0.1, 1, 0.05}, true),

                    header_10 = createHeader(L["Font Color"]),
                    fontColorBase = createColor(L["Default Font Color"], L["Set the default Font color."], "fontColorBase", false, true),


                    header_20 = createHeader(L["Flashing Font"]),
                    triggerColorFlash = createToggle(L["Enable flashing Color"], L["Toggle flashing Color."], "triggerColorFlash"),
                    colorFlashStartTime = createInput(L["Start Time"], L["Time when the flashing should start (in seconds)."], "colorFlashStartTime"),
                    fontColorFlash1 = createColor(L["Flash Color 1"], L["Set the flash Font color 1."], "fontColorFlash1", false),
                    fontColorFlash2 = createColor(L["Flash Color 2"], L["Set the flash Font color 2."], "fontColorFlash2", false),
                },
            },

            limitationSettings = {
                type = "group",
                name = L["Time Limit"],
                order = getOrder(),
                disabled =  function() return db.showOmniCC or db.disableBar end,
                args = {
                    header_00 = createHeader(L["Time Limit"]),
                    enableLimit = createToggle(L["Enable Time Limit"], L["Toggle hiding long Cooldowns."], "enableDurationLimit"),
                    showAfterLimit = createToggle(L["Show after Limit"], L["Toggle showing the Cooldowns after passing the Limit."], "showAfterLimit"),
                    limitTime = createInput(L["Limit (in seconds)"], L["Maximum Cooldown duration to show (in seconds)."], "durationTime"),
                },
            },
        },
    }
end
