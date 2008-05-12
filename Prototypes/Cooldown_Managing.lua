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

local _G = _G
local CooldownButtons = _G.CooldownButtons
CooldownButtons:CheckVersion("$Revision$")
local L = CooldownButtons.L

local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()

---
local string_format = string.format
local table_insert  = table.insert
local table_sort    = table.sort
---
-- Database
local InstanceList  = {}
local cooldownList  = {}
local cooldownCount = {}

local CooldownEngine = {}
function CooldownButtons.defaultModulePrototype:InitCooldownEngine()
    local handle = self.name
    if not InstanceList[handle] then
        InstanceList[handle]  = true
        cooldownList[handle]  = {}
        cooldownCount[handle] = 0
        -- Embed CooldownEngine Stuff
        for name, func in pairs(CooldownEngine) do
            self[name] = func
        end
    end
end

function CooldownEngine:registerCooldown(kind, name, id, texture, saveCall)
    local handle = self.name
    -- register saved Cooldowns in Saved Module!
    if CooldownButtons.savedDB.profile.Spells[name].save and not saveCall then
        return CooldownButtons:GetModule("Saved"):registerCooldown(kind, name, id, texture, true)
    end
    if not cooldownList[handle][name] then
        local button, buttonIndex = self:GetFreeButton()
        if buttonIndex then
            cooldownCount[handle] = cooldownCount[handle] + 1
            cooldownList[handle][name] = newDict(
                "type"     , kind,
                "id"       , id,
                "buttonID" , buttonIndex,
                "texture"  , texture,
                "order"    , 0,
                "saved"    , 0
            )
            button.used  = true

            if name == L["Spellgroup: Shocks"] or name == L["Spellgroup: Traps"]
            or name == L["Spellgroup: Divine Shields"] then
                button.texture:SetTexture(self.spellGroups[name].texture)

            elseif name == L["Healing/Mana Potions"]
            or name == L["Other Potions"] or name == L["Healthstone"] then
                button.texture:SetTexture(self.itemGroups[name].texture)
            else
                button.texture:SetTexture(texture)
            end

            button.cooldown:SetCooldown(self:GetCooldown(name))
            button.cooldown.spell = name

            self:sortCooldowns()
            return buttonIndex
        end
    end
end

function CooldownEngine:unregisterCooldown(name, saveCall)
    local handle = self.name
    if cooldownList[handle][name] then
        cooldownCount[handle] = cooldownCount[handle] - 1
        local frame = self:GetButton(cooldownList[handle][name]["buttonID"])
        frame:Hide()
        frame.text:Hide()
        frame.used = false
        frame.usedInBar = ""
        cooldownList[handle][name] = del(cooldownList[handle][name])
        self:sortCooldowns()
    end
    if saveCall then -- Update all Cooldowns
        CooldownButtons:GetModule("Items"):BAG_UPDATE_COOLDOWN()
        CooldownButtons:GetModule("Spells"):SPELL_UPDATE_COOLDOWN()
        CooldownButtons:GetModule("Spells"):PET_BAR_UPDATE_COOLDOWN()
    end
end

function CooldownEngine:IsCooldown(name)
    local handle = self.name
    if cooldownList[handle][name] then
        return true
    else
        return false
    end
end

function CooldownEngine:GetCooldown(name, data)
    local handle = self.name
    if data then
        return cooldownList[handle][name]
    else
        if cooldownList[handle][name] then
            return _G["Get"..cooldownList[handle][name]["type"].."Cooldown"](cooldownList[handle][name]["id"], BOOKTYPE_SPELL)
        else
            return nil, nil
        end
    end
end

function CooldownEngine:GetNumCooldowns()
    return cooldownCount[self.name]
end

function CooldownEngine:IterateCooldowns()
    return pairs(cooldownList[self.name])
end

function CooldownEngine:sortCooldowns()
    local handle = self.name
    local sortMe = newList()
    for k, v in self:IterateCooldowns() do
        local cooldownName = k
        local cooldownData = v
        if cooldownData["saved"] == 0 then -- at the moment always 0 ^^
            local start, duration = self:GetCooldown(cooldownName)
            local remaining = tonumber(string_format("%.3f", start + duration - GetTime() ))
            table_insert(sortMe, newList(remaining, cooldownName))
        end
    end
    local counts = 1
    table_sort(sortMe, function(a, b) return a[1] < b[1] end)
    for _, data in pairs(sortMe) do
        cooldownList[handle][data[2]].order = counts
        counts = counts + 1
    end
    sortMe = del(sortMe)
end

function CooldownEngine:GetCooldownText(name, trigger)
    local handle = self.name
    if cooldownList[handle][name] then
        local start, duration = self:GetCooldown(name)
        return self:formatCooldownTime((start + duration - GetTime()) ,trigger)
    else
        return ""
    end
end

local formatTime
function CooldownEngine:formatCooldownTime(time, trigger)
    if trigger then
        return formatTime(time, self.db.textStyle)
    else
        return formatTime(time, "00:00m")
    end
end

function formatTime(time, mode)
    if mode == "00:00m" or mode == "00:00M" then
        if time < 3600 then
            return date("%M:%S", 82800 + time)
        else
            return date("%H:%M:%S", 82800 + time)
        end
    elseif mode == "0m" or mode == "0M" then
        if time < 60 then
            return date("%S", 82800 + time)
        elseif  time < 3600  then
            if mode == "0m" then
                return date("%Mm", 82800 + time)
            else
                return date("%MM", 82800 + time)
            end
        else
            if mode == "0m" then
                return date("%Hh", 82800 + time)
            else
                return date("%HH", 82800 + time)
            end
        end
    end
end
