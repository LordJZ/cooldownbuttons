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

local CooldownButtons = LibStub("AceAddon-3.0"):NewAddon("Cooldown Buttons", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
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
CooldownButtons.rev = 0
function CooldownButtons:OnInitialize()
    -- Revision/Version
    self:CheckVersion("$Revision$")
    
    -- Check for v2 Database
    if not CooldownButtonsDB or (CooldownButtonsDB and not CooldownButtonsDB.useingCDBv2) then
        -- Reset the Database
        CooldownButtonsDB = {}
        CooldownButtonsSavedDB = {}
        CooldownButtonsDB.useingCDBv2 = true
        updateNotifyPopup()
    end
    
    -- Loading Databases
    self.db = LibStub("AceDB-3.0"):New("CooldownButtonsDB", defaults, "Default")
    self.savedDB = LibStub("AceDB-3.0"):New("CooldownButtonsSavedDB", defaultSaved, UnitName("player").." - "..GetRealmName())
end

function CooldownButtons:OnEnable()
    self:GetModule("Layout"):Setup()
    -- Check for OmniCC and turn off all OmniCC settings if not aviable
    if IsAddOnLoaded("OmniCC") then
        local major, minor, patch = LibStub("LibDeformat-3.0"):Deformat(OmniCCDB.version, "%d.%d.%d")
        local OCCversion = tonumber(major..minor..patch)
        self.noOmniCC = not (OCCversion >= 211)
    else
        self.noOmniCC = true
    end
    if self.noOmniCC == true then
        for k,v in pairs(self.db.profile.barSettings) do
            self.db.profile.barSettings[k].showOmniCC = false
        end
    end
end

function CooldownButtons:CheckVersion(revision)
    local rev = tonumber((revision):match("%d+")) or 0
    if rev > self.rev then
        self.rev = rev
    end
end

function CooldownButtons:gsub(text, variable, value)
	if (value) then
		text = string_gsub(text, variable, value);
	elseif (string_find(text, " "..variable)) then
		text = string_gsub(text, " "..variable, "");
	else
		text = string_gsub(text, variable, "");
	end
	return text;
end


--/run CooldownButtonsDB.useingCDBv2 = false
-- Function to show Update Notify
updateNotifyPopup = function()
	if not StaticPopupDialogs["CooldownButtons_UPDATE_NOTIFY_DIALOG"] then
		StaticPopupDialogs["CooldownButtons_UPDATE_NOTIFY_DIALOG"] = {}
	end
	local t = StaticPopupDialogs["CooldownButtons_UPDATE_NOTIFY_DIALOG"]
	for k in pairs(t) do
		t[k] = nil
	end
	t.text = "Welcome to |cFFCCCC00Cooldown Buttons v2|r\n\n"
           .."This is a total rewrite of the \"old\" Cooldown Buttons, "
           .."it has a complete new configuration and new Features!\n\n"
           .."At this place all previous settings are reseted due to "
           .."changes in the settings Database.\n\n"
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
                },

                -- Button Layout
                buttonCount = 10,
                buttonScale = 1,
                buttonAlpha = 1,
                buttonSpacing = 45,
                buttonDirection = "right",

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
                fontFace ="Skurri",
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
