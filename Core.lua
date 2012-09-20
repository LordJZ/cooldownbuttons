--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

----------------------
-- Addon declaration
----------------------

CDB = CreateFrame('frame')
local CDB = CDB
local L = LibStub("AceLocale-3.0"):GetLocale("Cooldown Buttons")
CDB.L = L


CDB:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
CDB:RegisterEvent("ADDON_LOADED")

local string_gsub = string.gsub
local string_find = string.find
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

function CDB:ADDON_LOADED(event, addon)
	if addon == "CooldownButtons" then

        -- Revision/Version
        if "@project-version@" ~= "@project".."-version@" then
            self.rev = "@project-version@"
        else
            self.rev = "SVN"    
        end

		self:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil
		if IsLoggedIn() then self:PLAYER_LOGIN() else self:RegisterEvent("PLAYER_LOGIN") end
	end
end

function CDB:Print(t)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99CooldownButtons|r: "..tostring(t))
end

function CDB:PLAYER_LOGIN(event, addon)
    local defaults = {
        profile = {
            ["bars"] = {
                ["**"] = {
                    used = false,
                    posx = 500,
                    posy = 500,
                    -- Button Layout
                    count = 10,
                    scale = 1,
                    alpha = 1,
                    spacing = 5,
                    center = false,
                    direction = "right",
                    -- Multiple Row Layout
                    multirow    = false,
                    countperrow = 5,
                    rowspacing  = 19,
                    rowdirection = "right-down",
                    -- Text Layout
                    style = "00:00m",
                    showMs = true,
                    showMsLimit = 5,
                    textdirection = "down",
                    textalpha = 1,
                    textdistance = 1,
                    -- Font Settings
                    fontoutline = "none",
                    fontface = "Skurri",
                    fontsize = 14,
                    flash = false,
                    flashstart = 10,
                    -- Font colors
                    color       = { Red = 1, Green = 1,   Blue = 1, },
                    flashcolor1 = { Red = 1, Green = 0.9, Blue = 0, },
                    flashcolor2 = { Red = 1, Green = 0,   Blue = 0, },
                    -- Misc Options
                    showtime   = true,
                    showspiral = true,
                    showpulse  = false,
                    showomnicc = false,
                    -- Limitations
                    limitMin = false,
                    limitMax = false,
                    limitMinTime = 3,
                    limitMaxTime = 14400,
                    limitAfterMax = false,
                },
                ["Default"] = {
                    used = true,
                    posx = 450,
                    posy = 550,
                },
            },
            ["cooldownSets"] = self.InitDefaultCooldownSets(),
            ["hiddenCooldowns"] = {
                ["**"] = { -- Spell / PetAction / Item
                    ["**"] = {
                        hidden = false,
                    }
                }
            },
            ["type2bar"] = {
                ["**"] = { -- Spell / PetAction / Item
                    ["**"] = false, -- Barname
                    ["Default"] = true,
                },
            },
            ["notifications"] = {
                ["sink"] = {
                    message = L["DEFAULT_LIBSINK_MESSAGE"],
                    showIcon = true,
                    color = { Red = 1, Green = 1, Blue = 1, },
                    sinkStorage = { sink20OutputSink = "Default" },
                },
                ["chat"] = {
                    enable = true,
                    message = L["DEFAULT_CHATPOST_MESSAGE"],
                    targets = {
                        chatframe = true,
                        say = false,
                        party = false,
                        raid = false,
                        guild = false,
                        officer = false,
                        emote = false,
                        raidwarn = false,
                        battleground = false,
                        yell = false,
                        channel5 = false,
                        channel6 = false,
                        channel7 = false,
                        channel8 = false,
                        channel9 = false,
                        channel10 = false,
                    },
                },
            },
        },
    }
    self.db = LibStub("AceDB-3.0"):New("CooldownButtonsDB", defaults)
    
    self.cooldowns = {}
    self.cooldownsSort = {}
    
    self.engine:Init()
    self.spells:Init()
    self.items:Init()
    
	SLASH_CooldownButtons1 = "/cooldownbuttons";
	SLASH_CooldownButtons2 = "/cdb";
	SlashCmdList["CooldownButtons"] = function()
        --@do-not-package@
        local dontRemoveMe = true
        --@end-do-not-package@
        if LoadAddOn("CooldownButtons_Options") or dontRemoveMe then
            self.options = CDB_Options
            CDB_Options:Open()
        end
    end
end

function CDB:UpdateCooldowns()
    self.engine:Update()
end

function CDB:InitNewBar(name)
    local db = self.db.profile.bars[name]
    if not db.used then
        db.used = true
        self.engine.bars[name] = self.engine:CreateBar(name, db)
        return db
    end
end

function CDB:RemoveBar(name)
    local db = self.db.profile.bars
    db[name] = nil
    if self.engine.bars[name] then
        self.engine:Remove(name)
    end
end

do
    local funcs = {
        GetSpellCooldown = _G.GetSpellCooldown,
        GetItemCooldown = _G.GetItemCooldown,
        GetPetActionCooldown = _G.GetPetActionCooldown,
        GetSpellLink = _G.GetSpellLink,
        GetPetActionLink = _G.GetSpellLink,
        GetItemLink = function(arg) return select(2, GetItemInfo(arg)) end,

        GetPreviewLink = function() return "[Preview]" end,
        GetPreviewCooldown = function(_, self) return self.previewstart, self.previewduration end,
    }
    function CDB:AddCooldown(type, name, id, texture, preview)
        if not self.cooldowns[name] then
            self.cooldowns[name] = {
                type = type,
                id = id,
                name = name,
                texture = texture,
                active = true,
                Link = function(self)
                	 if type == "Spell" or type == "PetAction" then
                	 	return funcs["Get"..type.."Link"](self.id)
                	 else
                	 	return funcs["Get"..type.."Link"](self.name)
                	 end
                end,
                Timer = function(self)
                	 if type == "Spell" or type == "PetAction" then
                	 	return funcs["GetSpellCooldown"](self.id)
                	 else
                	 	return funcs["Get"..type.."Cooldown"](self.id, self)
                	 end
                end,
                -- For preview mode
                preview = preview and true,
                previewduration = preview,
                previewstart = preview and GetTime(),
            }
            table_insert(self.cooldownsSort, name)

            return true
        else
            local wasActive = self.cooldowns[name].active
            self.cooldowns[name].index = index -- Update Index for the case that we've learned a new Spell
            self.cooldowns[name].active = true
            if preview then self.cooldowns[name].previewstart = GetTime() end

            return not wasActive
        end
    end
end

function CDB:RemoveCooldown(name)
    --self:Print("RemoveCooldown("..name..")")
    if self.cooldowns[name] then
        self.cooldowns[name].active = false
        if self.cooldowns[name].preview then
            self.cooldowns[name] = nil
            for k, v in pairs(self.cooldownsSort) do
                if v == name then
                    table_remove(self.cooldownsSort, k)
                end
            end
        end
    end
    self:SortCooldowns()
end

function CDB:RemovePreviewCooldowns()
    --self:Print("RemovePreviewCooldowns()")
    for name, data in pairs(self.cooldowns) do
        if data.preview then
            self:RemoveCooldown(name)
        end
    end
    self:SortCooldowns()
end

function CDB:AddPreviewCooldowns(duration)
    --self:Print("AddPreviewCooldowns()")
    local count = 0
    for name, data in pairs(self.db.profile.bars) do
        if data.count > count then
            for variable = 1, data.count, 1 do
                count = count + 1
                --CDB:Print("PreviewCooldown_"..tostring(count))
                self:AddCooldown("Preview", "PreviewCooldown_"..tostring(count), 0, "Interface\\Icons\\INV_Jewelcrafting_DragonsEye05", duration)
            end
        end
    end
    self:SortCooldowns()
end

function CDB:SortCooldowns()
    table_sort(self.cooldownsSort, function(a, b)
        if (not a) or (not b) then return true end -- security ! 
        local start1, duration1 = CDB.cooldowns[a]:Timer()
        local start2, duration2 = CDB.cooldowns[b]:Timer()

        if start1 == nil or duration1 == nill then
            return true
        elseif start2 == nill or duration2 == nil then
            return false
        else
            local cd1 = start1 + duration1
            local cd2 = start2 + duration2
            return cd1 < cd2
        end
    end)
    self:UpdateCooldowns()
end

function CDB.gsub(text, variable, value)
	if (value) then
		text = string_gsub(text, variable, value)
	elseif (string_find(text, " "..variable)) then
		text = string_gsub(text, " "..variable, "")
	else
		text = string_gsub(text, variable, "")
	end
	return text
end

-- from ckknight's LibDogTag-3.0, with his permission:
do
    local poolNum = 0
    local newList, newDict, del, deepDel, deepCopy
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
    CDB.GetRecyclingFunctions = function() return newList, newDict, del, deepDel, deepCopy end
end
-- end of ckknight's code
