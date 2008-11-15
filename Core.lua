--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CooldownButtons = LibStub("AceAddon-3.0"):NewAddon("Cooldown Buttons", "AceConsole-3.0")
CooldownButtons.L     = LibStub("AceLocale-3.0"):GetLocale("Cooldown Buttons", false)
local L = CooldownButtons.L

-- Added to Globals (required for cyCircled)
_G.CooldownButtons = CooldownButtons

-- from ckknight's LibDogTag-3.0, with his permission:
local poolNum = 0
local newList, newDict, del, deepDel, deepCopy
do
    local pool = setmetatable({}, {__mode='k'})
    function newList(...)
        poolNum = poolNum + 1
        local t = next(pool)
        if t then
            pool[t] = nil
            for i = 1, select('#', ...) do
                t[i] = select(i, ...)
            end
        else
            t = { ... }
        end
        -- if TABLE_DEBUG and pool == normalPool then
        --     TABLE_DEBUG[#TABLE_DEBUG+1] = { '***', "newList", poolNum, tostring(t), debugstack() }
        -- end
        return t
    end
    function newDict(...)
        poolNum = poolNum + 1
        local t = next(pool)
        if t then
            pool[t] = nil
        else
            t = {}
        end
        for i = 1, select('#', ...), 2 do
            t[select(i, ...)] = select(i+1, ...)
        end
        -- if TABLE_DEBUG and pool == normalPool then
        --     TABLE_DEBUG[#TABLE_DEBUG+1] = { '***', "newDict", poolNum, tostring(t), debugstack() }
        -- end
        return t
    end
    function del(t)
        if type(t) ~= "table" then
            error("Bad argument #1 to `del'. Expected table, got nil.", 2)
        end
        if pool[t] then
            error("Double-free syndrome.", 2)
        end
        pool[t] = true
        poolNum = poolNum - 1
        for k in pairs(t) do
            t[k] = nil
        end
        setmetatable(t, nil)
        t[''] = true
        t[''] = nil
        
        -- if TABLE_DEBUG then
        --     local tostring_t = tostring(t)
        --     TABLE_DEBUG[#TABLE_DEBUG+1] = { '***', "del", poolNum, tostring_t, debugstack() }
        --     for _, line in ipairs(TABLE_DEBUG) do
        --         if line[4] == tostring_t then
        --             line[1] = ''
        --         end
        --     end
        --     pool[t] = nil
        -- end
        return nil
    end
    local deepDel_data
    function deepDel(t)
        local made_deepDel_data = not deepDel_data
        if made_deepDel_data then
            deepDel_data = newList()
        end
        if type(t) == "table" and not deepDel_data[t] then
            deepDel_data[t] = true
            for k,v in pairs(t) do
                deepDel(v)
                deepDel(k)
            end
            del(t)
        end
        if made_deepDel_data then
            deepDel_data = del(deepDel_data)
        end
        return nil
    end
    function deepCopy(t)
        if type(t) ~= "table" then
            return t
        else
            local u = newList()
            for k, v in pairs(t) do
                u[deepCopy(k)] = deepCopy(v)
            end
            return u
        end
    end
end
-- end of ckknight's code

-- Misc functions
CooldownButtons.GetRecyclingFunctions = function() return newList, newDict, del, deepDel, deepCopy end

-- Prototypes
CooldownButtons.defaultModulePrototype = {}

---
local string_gsub = string.gsub
---

-- Declaration of default settings table, definition later :)
local defaults, defaultSaved
local updateNotifyPopup

-- Revision/Version
if "@project-version@" ~= "@project".."-version@" then
    CooldownButtons.rev = "@project-version@"
else
    CooldownButtons.rev = "SVN"    
end
function CooldownButtons:OnInitialize()    
    -- Check for v2.1 Database
    if not CooldownButtonsDB then
        -- Create New
        CooldownButtonsDB = {}
        self:Print("Welcome to CooldownButtons v2.1")
        --updateNotifyPopup()
    elseif(CooldownButtonsDB and not (CooldownButtonsDB.useingCDBv2 == "2.1")) then
        CooldownButtonsDB.useingCDBv2 = "2.1"
        -- Upgrade
    end
    
    -- Loading Databases
    self.db = LibStub("AceDB-3.0"):New("CooldownButtonsDB", defaults, "Default")
    self.savedDB = LibStub("AceDB-3.0"):New("CooldownButtonsSavedDB", defaultSaved, UnitName("player").." - "..GetRealmName())
end

function CooldownButtons:OnEnable()
    self:GetModule("Layout Manager"):Setup()
    -- Check for OmniCC and turn off all OmniCC settings if not aviable
    if IsAddOnLoaded("OmniCC") then
        local major, minor, patch = LibStub("LibDeformat-3.0"):Deformat(OmniCCDB.version, "%d.%d.%d")
        local OCCversion = tonumber(major..minor..patch)
        self.noOmniCC = not (OCCversion >= 211)
    else
        self.noOmniCC = true
    end
    
    CooldownButtons:GetModule("Config"):AddBarSettings(L["Expiring"], "Expiring", self.db.profile.barSettings["Expiring"], 30, nil)
    CooldownButtons:GetModule("Config"):AddBarSettings(L["Saved"], "Saved", self.db.profile.barSettings["Saved"], 40, true)
    
    local _, cls = UnitClass("player")
    if cls == "DEATHKNIGHT" then
        self:Print("Hey Death Knight Player, Cooldown Buttons has some issues with DK. It does not correctly Manage the Rune Cooldowns, currently i don't have much time to play so i also don't have much time to try to fix this issue. My priority is hiting Level 80 with my main char to not miss first Raids and then fixing CDB, but i took the time tomake a small hotfix. DKs now have ALL Spells in Cooldown Settings, so you can Hide every Spell you dont want to see.")
        self:Print("If you have any Ideas or Suggestions to fix the Death Knight Problem just post it on wowace forums (|cffaaaaaahttp://forums.wowace.com/showthread.php?t=11289|r) or Create a Ticket on CDB Project Page: |cffaaaaaahttp://www.wowace.com/projects/cooldownbuttons/|r")
    end
end

function CooldownButtons:gsub(text, variable, value)
	if (value) then
		text = string_gsub(text, variable, value)
	elseif (string_find(text, " "..variable)) then
		text = string_gsub(text, " "..variable, "")
	else
		text = string_gsub(text, variable, "")
	end
	return text
end

function CooldownButtons:GetBarSettings(bar)
	return self.db.profile.barSettings[bar]
end

-- Function to show Update Notify
function updateNotifyPopup()
	if not StaticPopupDialogs["CooldownButtons_UPDATE_NOTIFY_DIALOG"] then
		StaticPopupDialogs["CooldownButtons_UPDATE_NOTIFY_DIALOG"] = {}
	end
	local t = StaticPopupDialogs["CooldownButtons_UPDATE_NOTIFY_DIALOG"]
	for k in pairs(t) do
		t[k] = nil
	end
	t.text = "Welcome to |cFFCCCC00Cooldown Buttons v2.1|r\n\n"
--           .."\n\n"
           .."I hope you like this Addon. Have Fun! :)\n\n"
           .."Note:\nFor more Info read the FAQ-Page in the Config Dialog (/cdb)"
	t.button1 = "OK"
	local dialog, oldstrata
	t.OnAccept = function()
		if dialog and oldstrata then
			dialog:SetFrameStrata(oldstrata)
		end
	end
	t.OnCancel = function()
		if dialog and oldstrata then
			dialog:SetFrameStrata(oldstrata)
		end
	end
	t.timeout = 0
	t.whileDead = 1
	t.hideOnEscape = 1

	dialog = StaticPopup_Show("CooldownButtons_UPDATE_NOTIFY_DIALOG")
	if dialog then
		oldstrata = dialog:GetFrameStrata()
		dialog:SetFrameStrata("TOOLTIP")
	end
end

-- Default settings
defaults = {
    profile = {
        moveToExpTime  = 0,
        moveItemsToSpells = false,

        LibSinkAnnouncmentMessage = L["Cooldown on $cooldown ready!"],
        LibSinkAnnouncmentShowTexture = true,
        LibSinkAnnouncmentColor = { Red = 1, Green = 1, Blue = 1, },
        LibSinkAnnouncmentConfig = { sink20OutputSink = "None" },

        hidePetSpells = false,
        
        chatPost = {
            enableChatPost = false,
            postDefaultMsg = true,
            chatPostMessage = L["Cooldown on $spell active for $time."],
            toChat = {
                ["**"] = false,
            },
        },

        barSettings = {
            ["**"] ={
                disableBar = false,
                -- Position
                pos = { x = 450, y = 550, },
                -- LBF Config
                LBF_Data = {
                    SkinID   = "Blizzard",
                    Gloss    = 0,
                    Backdrop = false,
                    Colors   = {},
                },

                -- Button Layout
                buttonCount = 10,
                buttonScale = 1,
                buttonAlpha = 1,
                buttonSpacing = 45,
                buttonDirection = "right",
                reverseCooldowns = false,

                -- Multiple Row Layout
                buttonMultiRow    = false,
                buttonCountPerRow = 2,
                buttonRowSpacing  = 70,
                buttonMRDirection = "right-down",

                -- Text Layout
                textStyle = "00:00m",
                textSettings  = false,
                textDirection = "down",
                textAlpha = 1,
                textDistance = 28,

                -- Font Settings
                fontOutline = "none",
                fontFace = "Skurri",
                fontSize = 14,
                triggerColorFlash = false,
                colorFlashStartTime = 10,

                -- Font colors
                fontColorBase   = { Red = 1, Green = 1,   Blue = 1, },
                fontColorFlash1 = { Red = 1, Green = 0.9, Blue = 0, },
                fontColorFlash2 = { Red = 1, Green = 0,   Blue = 0, },

                -- Some Settings
                showTime   = true,
                showSpiral = true,
                showPulse  = false,
                showOmniCC = false,
                showCenter = false,

                -- Limitations
                enableDurationLimit = false,
                showAfterLimit = true,
                durationTime = 0,
            },
        },
    },
}
defaultSaved = {
    profile = {
        ["Spells"] = {
            ["**"] = {
                save = false,
                hide = false,
                pos  = { x = 400, y = 400, },
            },
        },
        ["Items"] = {
            ["**"] = {
                save = false,
                hide = false,
                pos  = { x = 400, y = 400, },
            },
        },
    },
}
