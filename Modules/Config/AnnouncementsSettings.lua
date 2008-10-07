--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CooldownButtons = _G.CooldownButtons
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
