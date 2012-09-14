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

local string_format = string.format

function CDB_Options:LoadAnnouncenentSettings()
    self.options.args.notifications = API:createGroup(L["GROUP_NOTIFICATION"], L["GROUP_NOTIFICATION_DESC"])
    local notifications = self.options.args.notifications.args
    
    local LS2 = LibStub("LibSink-2.0")
    if LS2 then
        local db = CDB.db.profile.notifications.sink
        LS2.SetSinkStorage(CDB, CDB.db.profile.notifications.sink.sinkStorage)
        
        notifications.notifications = API:createGroup(L["NOTIFICATION_SUB_NOTIFICATIONS"], L["NOTIFICATION_SUB_NOTIFICATIONS_SUB"])
        notifications.notifications.args.message = API:createInput(L["NOTIFICATION_MESSAGE"], L["NOTIFICATION_MESSAGE_DESC"], "message", "full")
        notifications.notifications.args.texture = API:createToggle(L["NOTIFICATION_SHOW_ICON"], L["NOTIFICATION_SHOW_ICON_DESC"], "showIcon")
        notifications.notifications.args.color = API:createColor(L["NOTIFICATION_COLOR"], L["NOTIFICATION_COLOR_DESC"], "color")
        notifications.notifications.args.output = LS2.GetSinkAce3OptionsDataTable(CDB)
        notifications.notifications.args.output.inline = true
        notifications.notifications.args.output.order = 10000 -- force last option
        
        local function get(key) if key.type == "input" then return tostring(db[key.arg]) end return db[key.arg] end
        local function set(key, value) if key.type == "input" then if not (tonumber(value) == nil) then value = tonumber(value) end end db[key.arg] = value end
        local function getColor(key) local c = db[key.arg] return c.Red, c.Green, c.Blue end
        local function setColor(key, r, g, b) local c = db[key.arg] c.Red = r c.Green = g c.Blue = b end
        API:injectSetGet(notifications.notifications, set, get) 
        API:injectSetGet(notifications.notifications.args.color, setColor, getColor) 
    end

    do -- Chat Post
        notifications.chat = API:createGroup(L["NOTIFICATION_SUB_CHATPOST"], L["NOTIFICATION_SUB_CHATPOST_DESC"])
       
        notifications.chat.args.enable = API:createToggle(L["CHATPOST_ENABLE"], L["CHATPOST_ENABLE_DESC"], "enable")
        notifications.chat.args.custommessage = API:createInput(L["CHATPOST_MESSAGE"],L["CHATPOST_MESSAGE_DESC"], "message", "full")
        notifications.chat.args.messageDescription = API:createDescription(L["CHATPOST_MESSAGE_HELP"])
        notifications.chat.args.submenuOutput = API:createGroup("Output")
        notifications.chat.args.submenuOutput.inline = true
        notifications.chat.args.submenuOutput.args.say           = API:createToggle(L["CHATPOST_LOCATION_SAY"], L["CHATPOST_LOCATION_DESC"], "say")
        notifications.chat.args.submenuOutput.args.party         = API:createToggle(L["CHATPOST_LOCATION_PARTY"], L["CHATPOST_LOCATION_DESC"], "party")
        notifications.chat.args.submenuOutput.args.raid          = API:createToggle(L["CHATPOST_LOCATION_RAID"], L["CHATPOST_LOCATION_DESC"], "raid")
        notifications.chat.args.submenuOutput.args.guild         = API:createToggle(L["CHATPOST_LOCATION_GUILD"], L["CHATPOST_LOCATION_DESC"], "guild")
        notifications.chat.args.submenuOutput.args.officer       = API:createToggle(L["CHATPOST_LOCATION_OFFICER"], L["CHATPOST_LOCATION_DESC"], "officer")
        notifications.chat.args.submenuOutput.args.emote         = API:createToggle(L["CHATPOST_LOCATION_EMOTE"], L["CHATPOST_LOCATION_DESC"], "emote")
        notifications.chat.args.submenuOutput.args.raidwarn      = API:createToggle(L["CHATPOST_LOCATION_RAIDWARN"], L["CHATPOST_LOCATION_DESC"], "raidwarn")
        notifications.chat.args.submenuOutput.args.battleground  = API:createToggle(L["CHATPOST_LOCATION_BATTLEGROUND"], L["CHATPOST_LOCATION_DESC"], "battleground")
        notifications.chat.args.submenuOutput.args.yell          = API:createToggle(L["CHATPOST_LOCATION_YELL"], L["CHATPOST_LOCATION_DESC"], "yell")
        notifications.chat.args.submenuOutput.args.chatframe     = API:createToggle(L["CHATPOST_LOCATION_CHATFRAME"], L["CHATPOST_LOCATION_DESC"], "chatframe")
        notifications.chat.args.submenuOutput.args.channelheader = API:createHeader(L["CHATPOST_LOCATION_CUSTOM_CHANNELS"])
        notifications.chat.args.submenuOutput.args.channel5      = API:createToggle("", L["CHATPOST_LOCATION_DESC"], "channel5")
        notifications.chat.args.submenuOutput.args.channel6      = API:createToggle("", L["CHATPOST_LOCATION_DESC"], "channel6")
        notifications.chat.args.submenuOutput.args.channel7      = API:createToggle("", L["CHATPOST_LOCATION_DESC"], "channel7")
        notifications.chat.args.submenuOutput.args.channel8      = API:createToggle("", L["CHATPOST_LOCATION_DESC"], "channel8")
        notifications.chat.args.submenuOutput.args.channel9      = API:createToggle("", L["CHATPOST_LOCATION_DESC"], "channel9")
        notifications.chat.args.submenuOutput.args.channel10     = API:createToggle("", L["CHATPOST_LOCATION_DESC"], "channel10")

        local db = CDB.db.profile.notifications.chat
        local function get(key) if key.type == "input" then return tostring(db[key.arg]) end return db[key.arg] end
        local function set(key, value) if key.type == "input" then if not (tonumber(value) == nil) then value = tonumber(value) end end db[key.arg] = value end
        local function getChannel(key) return db.targets[key.arg] end
        local function setChannel(key, value) db.targets[key.arg] = value end
        API:injectSetGet(notifications.chat, set, get) 
        API:injectSetGet(notifications.chat.args.submenuOutput, setChannel, getChannel) 
        
        self:RegisterEvent("CHANNEL_UI_UPDATE")
        self:CHANNEL_UI_UPDATE()
    end
end

function CDB_Options:CHANNEL_UI_UPDATE()
    local chanlist = self.options.args.notifications.args.chat.args.submenuOutput.args
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