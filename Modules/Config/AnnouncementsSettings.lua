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
local L = CooldownButtons.L
local LS2 = LibStub("LibSink-2.0")

local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()

function CooldownButtonsConfig:LibSinkConfig()
    local options = self.options
    local db = CooldownButtons.db.profile
    LS2.SetSinkStorage(CooldownButtons, CooldownButtons.db.profile.LibSinkAnnouncmentConfig)
    options.args.announcements.args.LibSink = {
        type = "group",
        name = L["Announcement"],
        order = 0,
        args = {},
    }
    options.args.announcements.args.LibSink.args.header_00 = {
        type = "header",
        name = L["Announcement Message"],
        order = 0,
    }
    options.args.announcements.args.LibSink.args.LibSinkAnnouncmentMessage = {
        type = "input",
        name = "",
        order = 10,
        arg  = "LibSinkAnnouncmentMessage",
        get = function( k ) return db[k.arg] end,
        set = function( k, v ) db[k.arg] = v end,
        width= "double",
    }
    options.args.announcements.args.LibSink.args.desc = {
        type = "description",
        name = L["Use \'$cooldown\' to add Cooldown name."].."\n"..
               L["Use \'$icon\' to add Cooldown Icon."].."\n"..
               L["Default Message: "]..L["Cooldown on $cooldown ready!"],
        order = 20,
    }
    options.args.announcements.args.LibSink.args.showTexture = {
        type = "toggle",
        name = L["Show Cooldown Icon in Annoucnement"],
        order = 21,
        arg  = "LibSinkAnnouncmentShowTexture",
        get = function( k ) return db[k.arg] end,
        set = function( k, v ) db[k.arg] = v end,
        width= "full",
    }
    options.args.announcements.args.LibSink.args.desc2 = {
        type = "description",
        name = L["This option will not affect the \'$icon\' Tag."],
        order = 22,
    }
    options.args.announcements.args.LibSink.args.AnnouncementColor = {
        type = "color",
        name = L["Announcement Color"],
        order = 22,
        hasAlpha = false,
        arg = "LibSinkAnnouncmentColor",
        get = function( k ) local t = db[k.arg]; return t.Red, t.Green, t.Blue end,
        set = function( k, v, v2 ,v3 ) local t = db[k.arg]
                t.Red = v
                t.Green = v2
                t.Blue = v3
              end,
        width = "full",
    }
    options.args.announcements.args.LibSink.args.lsk = LS2.GetSinkAce3OptionsDataTable(CooldownButtons)
end
