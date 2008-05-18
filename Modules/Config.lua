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
local CooldownButtonsConfig = CooldownButtons:NewModule("Config","AceConsole-3.0","AceEvent-3.0")
local L = CooldownButtons.L
local LS2 = LibStub("LibSink-2.0")

CooldownButtonsConfig.options = {}
local options = CooldownButtonsConfig.options
local db
-- Functions
local createBarSettings

options.type = "group"
options.childGroups = "tab"
options.name = "Cooldown Buttons r"..CooldownButtons.rev
options.get = function( k ) return db[k.arg] end
options.set = function( k, v ) db[k.arg] = v end
options.args = {}
options.plugins = {}

options.args.barSettings = { 
    type = "group",
    name = L["Bar Settings"],
    order = 0,
    args = {},
}

options.args.cooldownSettings = {
    type = "group",
    name = L["Cooldown Settings"],
    order = 1,
    args = {},
}

if LS2 then
    options.args.announcements = {
        type = "group",
        name = L["Announcements Settings"],
        order = 2,
        args = {
        },
    }
end

options.args.testmode = {
    type = "group",
    name = "Test Mode",
    order = 3,
    args = {},
}

options.args.faq = {
    type = "group",
    name = "FAQ/Info",
    order = 5,
    args = {},
}

local openConfigUI
function CooldownButtonsConfig:OnInitialize()
    db = CooldownButtons.db.profile

    -- Profiles Configtab
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(CooldownButtons.db)
    options.args.profiles.order = 4
    
    -- LibSink ConfigTab
    if LS2 then
        self:LibSinkConfig()
    end
    
    local createHeader = select(2, self:GetWidgetAPI())
    local createToggle = select(7, self:GetWidgetAPI())
    options.args.barSettings.args["general__Bar_Settings_Stuff"] = {
        type = "group",
        name = L["General Settings"],
        order = 0,
        set = function(k,v) 
                db[k.arg] = v 
                db.barSettings.Items.disableBar = v
              end,
        get = function(k) return db[k.arg] end,
        args = {
            header_00 = createHeader(L["Item to Spells"]),
            toggleMoving = createToggle(L["Move Items to Spells Cooldown Bar"], "", "moveItemsToSpells", true, nil, nil),
        },
    }

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Cooldown Buttons", options)

    LibStub("AceConfigDialog-3.0"):SetDefaultSize("Cooldown Buttons", 700, 560)
    self:RegisterChatCommand("cdb", openConfigUI)
    self:RegisterChatCommand("CooldownButtons", openConfigUI)
end

function openConfigUI()
    -- Setup Saved Cooldown Settings
    if not CooldownButtonsConfig.SavedCooldownsConfigIsSet then
        CooldownButtonsConfig:SavedCooldownsConfig()
    end
    -- Setup Hidden Cooldown Settings
--    if not CooldownButtonsConfig.HiddenCooldownsConfigIsSet then
--        CooldownButtonsConfig:HiddenCooldownsConfig()
--    end
    -- Setup Item Cooldown Grouping Settings
    if not CooldownButtonsConfig.ItemCooldownGroupingConfigIsSet then
        CooldownButtonsConfig:ItemCooldownGroupingConfig()
    end
    
    --LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
    LibStub("AceConfigDialog-3.0"):Open("Cooldown Buttons")
end
