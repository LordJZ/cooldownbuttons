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
local getOrder, createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor = CooldownButtonsConfig:GetWidgetAPI()

local string_format = string.format

function CooldownButtonsConfig:ClickAnnouncementSettings()
    self.ChatPostAnnouncements = true
    local options = self.options
    local db = CooldownButtons.db.profile.chatPost
    
    options.args.announcements.args.chatPostList = {
        type = "group",
        name = L["Chat Post"],
        order = 1,
        set = function( k, state )
            if k.arg == "enableChatPost" then
                db.enableChatPost = state
            elseif k.arg == "postDefaultMsg" then
                db.postDefaultMsg = state
            elseif k.arg == "chatPostMessage" then
                db.chatPostMessage = tostring(state)
            else
                db.toChat[k.arg] = state
            end
        end,
        get = function( k )
            if k.arg == "enableChatPost" then
                return db.enableChatPost
            elseif k.arg == "postDefaultMsg" then
                return db.postDefaultMsg
            elseif k.arg == "chatPostMessage" then
                return tostring(db.chatPostMessage)
            else
                return db.toChat[k.arg]
            end
        end,
        args = {
            enableChatpost = createToggle(L["Enable Chat Post"], L["Enables/Disables Chat Post feature."], "enableChatPost"),
            msg_settings = createHeader(L["Message Settings"]),
            usedefault = createToggle(L["Use default Message"], L["Toggle posting the default Message."], "postDefaultMsg"),
            desc1 = createDescription(string_format(L["The default message is: %s"], L["Cooldown on $spell active for $time."]).."\n\n"),
            desc2 = createDescription(string_format(L["If \'%s\' is disabled use the following Text"], L["Use default Message"])),
            custommessage = createInput(L["Custom Message"], L["Set the Text to post."], "chatPostMessage", true),
            desc3 = createDescription(L["Use $spell for spell name and $time for cooldowntime."]),
            output = {
                type = "group",
                name = L["Output"],
                order = 0,
                args = {
                    enablePostingSay       = createToggle(L["Say"],               L["Toggle posting to Chat."], "say"),
                    enablePostingParty     = createToggle(L["Party"],             L["Toggle posting to Chat."], "party"),
                    enablePostingRaid      = createToggle(L["Raid"],              L["Toggle posting to Chat."], "raid"),
                    enablePostingGuild     = createToggle(L["Guild"],             L["Toggle posting to Chat."], "guild"),
                    enablePostingOfficer   = createToggle(L["Officer"],           L["Toggle posting to Chat."], "officer"),
                    enablePostingEmote     = createToggle(L["Emote"],             L["Toggle posting to Chat."], "emote"),
                    enablePostingRaidWarn  = createToggle(L["Raidwarning"],       L["Toggle posting to Chat."], "raidwarn"),
                    enablePostingBG        = createToggle(L["Battleground"],      L["Toggle posting to Chat."], "battleground"),
                    enablePostingYell      = createToggle(L["Yell"],              L["Toggle posting to Chat."], "yell"),
                    enablePostingChatFrame = createToggle(L["Default Chatframe"], L["Toggle posting to Chat."], "chatframe"),

                    customchans = createHeader(L["Custom Channels"]),
                    enablePostingChannel5  = createToggle("", L["Toggle posting to Chat."], "channel5"),
                    enablePostingChannel6  = createToggle("", L["Toggle posting to Chat."], "channel6"),
                    enablePostingChannel7  = createToggle("", L["Toggle posting to Chat."], "channel7"),
                    enablePostingChannel8  = createToggle("", L["Toggle posting to Chat."], "channel8"),
                    enablePostingChannel9  = createToggle("", L["Toggle posting to Chat."], "channel9"),
                    enablePostingChannel10 = createToggle("", L["Toggle posting to Chat."], "channel10"),
                },
            },
        },
    }
    
    self:RegisterEvent("CHANNEL_UI_UPDATE")
    self:CHANNEL_UI_UPDATE()
end

function CooldownButtonsConfig:CHANNEL_UI_UPDATE()
    local chanlist = self.options.args.announcements.args.chatPostList.args.output.args
    for i = 5, 10 do
        local channame = tostring(select(2,GetChannelName(i)))
        if channame ~= "nil" then
            chanlist["enablePostingChannel"..i].name = string_format("(/%d) %s", i, channame)
            chanlist["enablePostingChannel"..i].disabled = false
        else 
            chanlist["enablePostingChannel"..i].name = string_format("(/%d) %s", i, L["No Channel"])
            chanlist["enablePostingChannel"..i].disabled = true
--            db.posttochats["channel"..i] = false -- Channel does not exist, so dont post here :P
        end
    end
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
end
