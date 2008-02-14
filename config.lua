local CoolDownButtons = LibStub("AceAddon-3.0"):GetAddon("CoolDown Buttons")
local CoolDownButtonsConfig = CoolDownButtons:NewModule("Config","AceConsole-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CoolDown Buttons", false)

local CDBCHelper = {}
local options = {}
local db

options.type = "group"
options.name = "CoolDown Buttons"
options.get = function( k ) return db[k.arg] end
options.set = function( k, v ) db[k.arg] = v; CoolDownButtonsConfig:UpdateConfig(); end
options.args = {}
options.plugins = {}

local opt_directions = {
	["up"]    = L["Up"],
	["down"]  = L["Down"],
	["left"]  = L["Left"],
	["right"] = L["Right"],
}

options.args.display = {
 	type = "group",
    name = L["Display Settings"],
	order = 0,
	args = {
        showAnchor = {
            order = 0,
            name = L["Show Anchor"],
            desc = L["Toggle showing Anchor."],
            type = "toggle",
            arg = "showAnchor",
            width= "full",
        },
        displayDirection = {
            order = 1,
            name = L["Direction"],
            desc = L["Direction from Anchor"],
            type = "select",
            values = opt_directions,
            arg = "direction"
        },
        maxButtons = {
            order = 2,
            name = L["Max Buttons"],
            desc = L["Maximal number of Buttons to display."],
            type = "input",
            arg = "maxbuttons",
            set = function( k, v ) if not (tonumber(v) == nil) then db[k.arg] = tonumber(v); CoolDownButtonsConfig:UpdateConfig(); end end
        },
        dummy1 = { -- Need another line break :)
            order = 3,
            type = "description",
            name = "",
        },
        buttonScale = {
            order = 4,
            name = L["Button Scale"],
            desc = L["Button scaling, this lets you enlarge or shrink your Buttons."],
            type = "range",
            min = 0.5, max = 1.5, step = 0.05,
            arg = "scale",
        },
        buttonAlpha = {
            order = 5,
            name = L["Button Alpha"],
            desc = L["Icon alpha value, this lets you change the transparency of the Button."],
            type = "range",
            min = 0.1, max = 1, step = 0.05,
            arg = "alpha",
        },
    },
}

options.args.posting = {
	type = "group",
	name = L["Posting Settings"],
	order = 2,
	args = {
        enablePosting = {
            order = 0,
            name = L["Enable Chatpost"],
            desc = L["Toggle posting to Chat."],
            type = "toggle",
            arg = "chatPost",
        },
        chatPostList = {}, -- Later :)
    },
}

options.args.posting.args.chatPostList = {
    type = "group",
    name = L["Post to:"],
    guiInline = true,
    order = 1,
    set = function( k, state ) db.posttochats[k.arg] = state; CoolDownButtonsConfig:UpdateConfig(); end,
    get = function( k ) return db.posttochats[k.arg] end,
    args = {
    	enablePostingSay = { arg = "say", order = 0, type = "toggle",
			name = L["Say"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingParty = { arg = "party", order = 1, type = "toggle",
			name = L["Party"],
			desc = L["Toggle posting to Chat."],
        }, dummy1 = { order = 2, type = "description", name = "", },
    	enablePostingRaid = { arg = "raid", order = 3, type = "toggle",
			name = L["Raid"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingGuild = { arg = "guild", order = 4, type = "toggle",
			name = L["Guild"],
			desc = L["Toggle posting to Chat."],
        }, dummy2 = { order = 5, type = "description", name = "", },
    	enablePostingOfficer = { arg = "officer", order = 6, type = "toggle",
			name = L["Officer"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingEmote = { arg = "emote", order = 7, type = "toggle",
			name = L["Emote"],
			desc = L["Toggle posting to Chat."],
        }, dummy3 = { order = 8, type = "description", name = "", },
    	enablePostingRaidWarn = { arg = "raidwarn", order = 9, type = "toggle",
			name = L["Raidwarning"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingBG = { arg = "battleground", order = 10, type = "toggle",
			name = L["Battleground"],
			desc = L["Toggle posting to Chat."],
        }, dummy6 = { order = 11, type = "description", name = "", },
    	enablePostingYell = { arg = "yell", order = 12, type = "toggle",
			name = L["Yell"],
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChatFrame = { arg = "chatframe", order = 13, type = "toggle",
			name = L["Default Chatframe"],
			desc = L["Toggle posting to Chat."],
        },
        desc1 = {
            order = 14,
            type = "description",
            name = "Custom Channels:",
        },
    	enablePostingChannel5 = { arg = "channel5", order = 15, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChannel6 = { arg = "channel6", order = 16, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        }, dummy7 = { order = 17, type = "description", name = "", },
    	enablePostingChannel7 = { arg = "channel7", order = 18, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChannel8 = { arg = "channel8", order = 19, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        }, dummy8 = { order = 20, type = "description", name = "", },
    	enablePostingChannel9 = { arg = "channel9", order = 21, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
        },
    	enablePostingChannel10 = { arg = "channel10", order = 22, type = "toggle",
			name = "",
			desc = L["Toggle posting to Chat."],
            disabled = true,
        },
    },
}

options.args.posting.args.messagesettings = {
    type = "group",
	name = L["Message Settings"],
	order = 0,
	args = {
        usedefault = {
            order = 0,
            name = L["Use default Message"],
            desc = L["Toggle posting the default Message."],
            type = "toggle",
            arg = "postdefaultmsg",
        },
        desc1 = {
            order = 1,
            type = "description",
            name = CoolDownButtons:gsub(L["The default message is: |cFFFFFFFF$RemainingCoolDown|r"],
                                          "$RemainingCoolDown", L["RemainingCoolDown"]).."\n\n",
        },
        desc2 = {
            order = 2,
            type = "description",
            name = CoolDownButtons:gsub(L["If \'|cFFFFFFFF$defaultmsg|r\' is disabled use the following Text"],
                                          "$defaultmsg", L["Use default Message"]),
        },
        custommessage = {
            order = 3,
            name = "",
            desc = L["Set the Text to post."],
            type = "input",
            arg  = "postcustom",
            width= "double",
        },
        desc3 = {
            order = 4,
            type = "description",
            name = L["Use |cFFFFFFFF$spell|r for spell name and |cFFFFFFFF$time|r for cooldowntime."],
        },
    },
}

local getProfilesOptionsTable
do
	local defaultProfiles
	--[[ Utility functions ]]
	-- get exisiting profiles + some default entries
	local tmpprofiles = {}
	local function getProfileList(db, common, nocurrent)
		-- clear old profile table
		local profiles = {}
		
		-- copy existing profiles into the table
		local curr = db:GetCurrentProfile()
		for i,v in pairs(db:GetProfiles(tmpprofiles)) do if not (nocurrent and v == curr) then profiles[v] = v end end
		
		-- add our default profiles to choose from
		for k,v in pairs(defaultProfiles) do
			if (common or profiles[k]) and not (k == curr and nocurrent) then
				profiles[k] = v
			end
		end
		return profiles
	end
	
	function getProfilesOptionsTable(db)
		defaultProfiles = {
			["Default"] = L["Default"],
			[db.keys.char] = L["Char:"] .. " " .. db.keys.char,
			[db.keys.realm] = L["Realm:"] .. " " .. db.keys.realm,
			[db.keys.class] = L["Class:"] .. " " .. UnitClass("player")
		}
		
		local tbl = {
			profiles = {
				type = "group",
				name = L["Profiles"],
				desc = L["Manage Profiles"],
				order = 20,
				args = {
					desc = {
						order = 1,
						type = "description",
						name = L["You can change the active profile of CoolDown Buttons, so you can have different settings for every character"] .. "\n",
					},
					descreset = {
						order = 9,
						type = "description",
						name = L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."],
					},
					reset = {
						order = 10,
						type = "execute",
						name = L["Reset Profile"],
						desc = L["Reset the current profile to the default"],
						func = function() db:ResetProfile() end,
					},
					choosedesc = {
						order = 21,
						type = "description",
						name = "\n" .. L["You can create a new profile by entering a new name in the editbox, or choosing one of the already exisiting profiles."],
					},
					new = {
						name = L["New"],
						desc = L["Create a new empty profile."],
						type = "input",
						order = 30,
						get = function() return false end,
						set = function(info, value) db:SetProfile(value) end,
					},
					choose = {
						name = L["Current"],
						desc = L["Select one of your currently available profiles."],
						type = "select",
						order = 40,
						get = function() return db:GetCurrentProfile() end,
						set = function(info, value) db:SetProfile(value) end,
						values = function() return getProfileList(db, true) end,
					},
					deldesc = {
						order = 70,
						type = "description",
						name = "\n" .. L["Delete existing and unused profiles from the database"],
					},
					delete = {
						order = 80,
						type = "select",
						name = L["Delete a Profile"],
						desc = L["Deletes a profile from the database."],
						get = function() return false end,
						set = function(info, value) db:DeleteProfile(value) end,
						values = function() return getProfileList(db, nil, true) end,
						confirm = true,
						confirmText = L["Are you sure you want to delete the selected profile?"],
					},
				},
			},
		}
		return tbl
	end
end

function CoolDownButtonsConfig:OnInitialize()
	db = CoolDownButtons.db.profile
    options.plugins["profiles"] = getProfilesOptionsTable(CoolDownButtons.db)
	self.options = options
    self:CHANNEL_UI_UPDATE() -- Force Update Channellist for the first time :)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("CoolDown Buttons", options)
	self:RegisterChatCommand("cdb", function() LibStub("AceConfigDialog-3.0"):Open("CoolDown Buttons") end)
	self:RegisterChatCommand("cooldownbuttons", function() LibStub("AceConfigDialog-3.0"):Open("CoolDown Buttons") end)
    self:RegisterMessage("CoolDownButtonsConfigChanged")
    self:RegisterEvent("CHANNEL_UI_UPDATE")
end

function CoolDownButtonsConfig:UpdateConfig()
	self:SendMessage("CoolDownButtonsConfigChanged")
end

function CoolDownButtonsConfig:CoolDownButtonsConfigChanged()
	db = CoolDownButtons.db.profile
end

function CoolDownButtonsConfig:CHANNEL_UI_UPDATE()
    local chanlist = self.options.args.posting.args.chatPostList.args
    for i = 5, 10 do
        local channame = tostring(select(2,GetChannelName(i)))
        if not (channame == "nil") then
            chanlist["enablePostingChannel"..i].name = CoolDownButtons:gsub("(/"..i..") |cFFFFFFFF$defaultmsg|r", "$defaultmsg", channame )
            chanlist["enablePostingChannel"..i].disabled = false
        else 
            chanlist["enablePostingChannel"..i].name = "(/"..i..") No Channel"
            chanlist["enablePostingChannel"..i].disabled = true
            db.posttochats["channel"..i] = false -- Channel does not exist, so dont post here :P
        end
    end
    LibStub("AceConfigRegistry-3.0"):NotifyChange("CoolDown Buttons")
end
