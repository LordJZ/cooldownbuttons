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

local string_format = string.format

function CDB_Options:LoadAnnouncenentSettings()
    self.options.args.announcements = API:createGroup("Announcement Settings")
    local announcements = self.options.args.announcements.args
    
    local LS2 = LibStub("LibSink-2.0")
    if LS2 then
        LS2.SetSinkStorage(CDB, CDB.db.profile.LibSink.config)
        announcements.announcements = API:createGroup("Announcement")
        announcements.announcements.args.messageheader = API:createHeader("Announcement Message")
        announcements.announcements.args.message = API:createInput("", "", "message")
        announcements.announcements.args.messagedescription = API:createDescription("stupid description....")
        announcements.announcements.args.texture = API:createToggle("Show Cooldown Icon in Annoucnement", "", "showIcon")
        announcements.announcements.args.texturedescription = API:createDescription("another stupid description....")
        announcements.announcements.args.texturedescription = API:createColor("Announcement Color", "", "")
        announcements.announcements.args.LibSinkOptions = LS2.GetSinkAce3OptionsDataTable(CDB)
    end

    announcements.chat = API:createGroup("Chat Post")
   
    announcements.chat.args.enable = API:createToggle("Enable Chat Post", "", "enableChatPost")
    announcements.chat.args.messageheader = API:createHeader("Message Settings")
    announcements.chat.args.default = API:createToggle("Use default Message", "", "postDefaultMsg")
    announcements.chat.args.desc1 = API:createDescription("The default message is: Cooldown on $spell active for $time.\n\n")
    announcements.chat.args.desc2 = API:createDescription("If \'Use default Message\' is disabled use the following Text")
    announcements.chat.args.custommessage = API:createInput("Custom Message", "", "chatPostMessage")
    announcements.chat.args.desc3 = API:createDescription("Use $spell for spell name and $time for cooldowntime.")
    announcements.chat.args.submenuOutput = API:createGroup("Output")
    announcements.chat.args.submenuOutput.args.say           = API:createToggle("Say", "Toggle posting to Chat.", "say")
    announcements.chat.args.submenuOutput.args.party         = API:createToggle("Party", "Toggle posting to Chat.", "party")
    announcements.chat.args.submenuOutput.args.raid          = API:createToggle("Raid", "Toggle posting to Chat.", "raid")
    announcements.chat.args.submenuOutput.args.guild         = API:createToggle("Guild", "Toggle posting to Chat.", "guild")
    announcements.chat.args.submenuOutput.args.officer       = API:createToggle("Officer", "Toggle posting to Chat.", "officer")
    announcements.chat.args.submenuOutput.args.emote         = API:createToggle("Emote", "Toggle posting to Chat.", "emote")
    announcements.chat.args.submenuOutput.args.raidwarn      = API:createToggle("Raidwarning", "Toggle posting to Chat.", "raidwarn")
    announcements.chat.args.submenuOutput.args.battleground  = API:createToggle("Battleground", "Toggle posting to Chat.", "battleground")
    announcements.chat.args.submenuOutput.args.yell          = API:createToggle("Yell", "Toggle posting to Chat.", "yell")
    announcements.chat.args.submenuOutput.args.chatframe     = API:createToggle("Default Chatframe", "Toggle posting to Chat.", "chatframe")
    announcements.chat.args.submenuOutput.args.channelheader = API:createHeader("Custom Channels")
    announcements.chat.args.submenuOutput.args.channel5      = API:createToggle("", "Toggle posting to Chat.", "channel5")
    announcements.chat.args.submenuOutput.args.channel6      = API:createToggle("", "Toggle posting to Chat.", "channel6")
    announcements.chat.args.submenuOutput.args.channel7      = API:createToggle("", "Toggle posting to Chat.", "channel7")
    announcements.chat.args.submenuOutput.args.channel8      = API:createToggle("", "Toggle posting to Chat.", "channel8")
    announcements.chat.args.submenuOutput.args.channel9      = API:createToggle("", "Toggle posting to Chat.", "channel9")
    announcements.chat.args.submenuOutput.args.channel10     = API:createToggle("", "Toggle posting to Chat.", "channel10")

    self:RegisterEvent("CHANNEL_UI_UPDATE")
    self:CHANNEL_UI_UPDATE()
end

function CDB_Options:CHANNEL_UI_UPDATE()
    local chanlist = self.options.args.announcements.args.chat.args.submenuOutput.args
    for i = 5, 10 do
        local channame = tostring(select(2,GetChannelName(i)))
        if channame ~= "nil" then
            chanlist["channel"..i].name = string_format("(/%d) %s", i, channame)
            chanlist["channel"..i].disabled = false
        else 
            chanlist["channel"..i].name = string_format("(/%d) %s", i, "No Channel")
            chanlist["channel"..i].disabled = true
--            db.posttochats["channel"..i] = false -- Channel does not exist, so dont post here :P
        end
    end
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
end