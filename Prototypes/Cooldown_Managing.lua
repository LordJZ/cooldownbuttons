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
        if CooldownButtons:GetModule("Saved").registerCooldown then -- Fix nil error
            return CooldownButtons:GetModule("Saved"):registerCooldown(kind, name, id, texture, true)
        end
    end
    if CooldownButtons.db.profile.moveItemsToSpells and self:GetName() == "Items"  then
        if CooldownButtons:GetModule("Spells").registerCooldown then -- Fix nil error
            return CooldownButtons:GetModule("Spells"):registerCooldown(kind, name, id, texture)
        end
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
                "order"    , 0
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

function CooldownEngine:checkDurationLimit(start, duration)
    if self.db.enableDurationLimit then
        if self.db.showAfterLimit then
            return (start + duration - GetTime()) < self.db.durationTime
        else
            return duration < self.db.durationTime
        end
    else
        return true
    end
end

function CooldownEngine:sortCooldowns()
    local sortMe = newList()
    for cooldownName, cooldownData in self:IterateCooldowns() do
        local start, duration = self:GetCooldown(cooldownName)
        if self:checkDurationLimit(start, duration) then
            table_insert(sortMe, newList(tonumber(string_format("%.3f", start + duration - GetTime())), cooldownName))
            cooldownData.hide = false
        else
            cooldownData.hide = true
        end
        cooldownData.order = 0
    end
    local order = 1
    table_sort(sortMe, function(a, b) return a[1] < b[1] end)
    for _, data in pairs(sortMe) do
        cooldownList[self.name][data[2]].order = order
        order = order + 1
    end
    sortMe = deepDel(sortMe)
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

local _formatString_
function formatTime(time, mode)
    if mode == "00:00m" or mode == "00:00M" then
        if time < 3600 then
            _formatString_ = date("%M:%S", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            return _formatString_
        else
            _formatString_ = date("%H:%M", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            if mode == "00:00m" then
                return _formatString_.."h"
            else
                return _formatString_.."H"
            end
        end
    elseif mode == "0m" or mode == "0M" then
        if time < 60 then
            _formatString_ = date("%S", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            return _formatString_
        elseif  time < 3600  then
            _formatString_ = date("%M", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            if mode == "0m" then
                return _formatString_.."m"
            else
                return _formatString_.."M"
            end
        else
            _formatString_ = date("%H", 82800 + time)
            if string.sub(_formatString_, 1, 1) == "0" then
                _formatString_ = string.sub(_formatString_, 2)
            end
            if mode == "0m" then
                return _formatString_.."h"
            else
                return _formatString_.."H"
            end
        end
    end
end
