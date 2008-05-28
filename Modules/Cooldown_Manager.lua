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
local CooldownManager = CooldownButtons:NewModule("Cooldown Manager")
local L = CooldownButtons.L
local ButtonManager = CooldownButtons:GetModule("Button Manager")

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
------
local NORMAL, SAVED, EXPIRING = 0, 1, 2

function CooldownManager:OnInitialize()
    self.rev = tonumber(("$Revision$"):match("%d+")) or 0
    self.db = newList()
    self.dbNum = 0
    self.dbNumPerBar = {
        ["Spells"]   = 0,
        ["Items"]    = 0,
        ["Expiring"] = 0,
    }
    self.mode = {["NORMAL"] = NORMAL, ["SAVED"] = SAVED, ["EXPIRING"] = EXPIRING}
    --[[
    Item:
        [".start*duration."] = {
            kind = "Item",
            name = "Hearthstone",
            id   = "6948",
            tex  = "Interface\\Icons\\INV_Misc_Rune_01",
        }
    Spell:
    ["Shadowmeld"] = {
            kind = "Spell",
            name = "Shadowmeld",
            id   = "8",
            tex  = "Interface\\Icons\\Ability_Ambush",
        }
    --]]
end

function CooldownManager:OnEnable()
    -- TODO: Do we need OnEnable()?
end

local registerCooldown
function CooldownManager:Add(kind, name, id, texture)
    local saved = self:CheckSaved(kind, name, id)
    local expiring = self:CheckExpiring(kind, id)
    if not self:CheckRegistred(name) then
        if saved then
            return self:registerCooldown(kind, name, id, texture, SAVED)
        end
        if expriring then
            return self:registerCooldown(kind, name, id, texture, EXPIRING)
        end
        return self:registerCooldown(kind, name, id, texture, NORMAL)
    else
    end
end

function CooldownManager:CheckRegistred(name)
    for k, v in pairs(self.db) do
        if v.name == name then
            --self:Remove(k)
            return true
        end
    end
end

function CooldownManager:IterateCooldowns()
    return pairs(self.db)
end

function CooldownManager:CheckSaved(arg1, arg2, arg3) -- kind, name, id
    if type(arg1) == "string" then
        local group = (((arg1 == "Item") and "Items") or (((arg1 == "Spell") or (arg1 == "PetAction")) and "Spells"))
        local object = ((group == "Items") and arg3) or ((group == "Spells") and arg2)
        return (CooldownButtons.savedDB.profile[group][object].save == true)
    elseif type(arg1) == "table" then
        local group = (((arg1.kind == "Item") and "Items") or (((arg1.kind == "Spell") or (arg1.kind == "PetAction")) and "Spells"))
        local object = ((group == "Items") and arg1.id) or ((group == "Spells") and arg1.name)
        return (CooldownButtons.savedDB.profile[group][object].save == true)
    end
end

function CooldownManager:GetSavedPos(arg1, arg2, arg3) -- kind, name, id
    if type(arg1) == "string" then
        local group = (((arg1 == "Item") and "Items") or (((arg1 == "Spell") or (arg1 == "PetAction")) and "Spells"))
        local object = ((group == "Items") and arg3) or ((group == "Spells") and arg2)
        return CooldownButtons.savedDB.profile[group][object].pos
    elseif type(arg1) == "table" then
        local group = (((arg1.kind == "Item") and "Items") or (((arg1.kind == "Spell") or (arg1.kind == "PetAction")) and "Spells"))
        local object = ((group == "Items") and arg1.id) or ((group == "Spells") and arg1.name)
        return CooldownButtons.savedDB.profile[group][object].pos
    end
end

function CooldownManager:SetSavedPos(arg1, arg2, arg3, x, y) -- kind, name, id
    if type(arg1) == "string" then
        local group = (((arg1 == "Item") and "Items") or (((arg1 == "Spell") or (arg1 == "PetAction")) and "Spells"))
        local object = ((group == "Items") and arg3) or ((group == "Spells") and arg2)
        CooldownButtons.savedDB.profile[group][object].pos.x = x
        CooldownButtons.savedDB.profile[group][object].pos.y = y
    elseif type(arg1) == "table" then
        local group = (((arg1.kind == "Item") and "Items") or (((arg1.kind == "Spell") or (arg1.kind == "PetAction")) and "Spells"))
        local object = ((group == "Items") and arg1.id) or ((group == "Spells") and arg1.name)
        CooldownButtons.savedDB.profile[group][object].pos.x = x
        CooldownButtons.savedDB.profile[group][object].pos.y = y
    end
end

function CooldownManager:CheckExpiring(arg1, arg2) -- kind, id
    if type(arg1) == "string" then
        local start, duration = _G["Get"..arg1.."Cooldown"](arg2, BOOKTYPE_SPELL)
        local time = start + duration - GetTime()
        return ((CooldownButtons.db.profile.moveToExpTime > 0) and (time <= CooldownButtons.db.profile.moveToExpTime))
    elseif type(arg1) == "table" then
        local start, duration = _G["Get"..arg1.kind.."Cooldown"](arg1.id, BOOKTYPE_SPELL)
        local time = start + duration - GetTime()
        return ((CooldownButtons.db.profile.moveToExpTime > 0) and (time <= CooldownButtons.db.profile.moveToExpTime))
    elseif type(arg1) == "number" then
        local start, duration = arg1, arg2
        local time = start + duration - GetTime()
        return ((CooldownButtons.db.profile.moveToExpTime > 0) and (time <= CooldownButtons.db.profile.moveToExpTime))
    end
end

function CooldownManager:Remove(idx)
    -- Free Button
    ButtonManager:GetButton(self.db[idx].button):Hide()
    ButtonManager:GetButton(self.db[idx].button).text:Hide()
    ButtonManager:GetButton(self.db[idx].button).used = false
    -- Remove Cooldown
    self.db[idx] = deepDel(self.db[idx])
    self.dbNum = self.dbNum - 1
    -- Resort Cooldowns
    self:sortCooldowns()
end

function CooldownManager:GetNumPerBar(bar)
    return self.dbNumPerBar[bar] - 1  -- sub 1 couse we start count with 1 in sort function
end

function CooldownManager:TriggerSaved(key)
    if self.db[key].mode == SAVED then
        self.db[key].mode = 0
    else
        self.db[key].mode = SAVED
    end
    self:sortCooldowns()
end

function CooldownManager:TriggerExpired(key)
    if self.db[key].mode == EXPIRING then
        self.db[key].mode = 0
    else
        self.db[key].mode = EXPIRING
    end
    self:sortCooldowns()
end

local GetTexture
function CooldownManager:registerCooldown(kind, name, id, texture, switch)
    local start, duration = _G["Get"..kind.."Cooldown"](id, BOOKTYPE_SPELL)
    local index = (((kind == "Item") and start*duration) or (((kind == "Spell") or (kind == "PetAction")) and name))
    local button, bID = ButtonManager:GetButton()
    self.dbNum = self.dbNum + 1
    self.db[index] = newDict(
        "idx"  , index, -- own index
        "kind" , kind,
        "name" , name,
        "id"   , id,
        "tex"  , GetTexture(kind, id, name), 
        "mode" , switch,
        "button", bID
    )

    button.used = true
    button.texture:SetTexture(texture)
    button.cooldown:SetCooldown(start, duration)

    -- Todo: tweak this crap :)
    if name == L["Spellgroup: Shocks"] or name == L["Spellgroup: Traps"]
    or name == L["Spellgroup: Divine Shields"] then
        if not self.spellGroups then
            self.spellGroups = CooldownButtons:GetModule("Spells").spellGroups
        end
        button.texture:SetTexture(self.spellGroups[name].texture)
    elseif name == L["Healing/Mana Potions"]
    or name == L["Other Potions"] or name == L["Healthstone"] then
        if not self.itemGroups then
            self.itemGroups = CooldownButtons:GetModule("Items").itemGroups
        end
        button.texture:SetTexture(self.itemGroups[name].texture)
    else
        button.texture:SetTexture(texture)
    end

    self:sortCooldowns()
end

function GetTexture(kind, id, name)
    if kind == "Item" then
        return select(10, GetItemInfo(id))
    elseif kind == "Spell" then
        return select(3, GetSpellInfo(id, BOOKTYPE_SPELL))
    elseif kind == "PetAction" then
        return select(3, GetSpellInfo(name)) or select(3, GetPetActionInfo(id))
    else
        error("Invalid Cooldowntype.\n"
            .."Type: "..tostring(kind).."\n"
            .."Name: "..tostring(name).."\n"
            .."ID: "  ..tostring(id)  .."\n")
    end
end

local checkDurationLimit, getForcedHidden, switchCase
function CooldownManager:sortCooldowns()
    if self.dbNum ~= 0 then
        local sortMe = newDict(
            "Spells"  , newList(),
            "Items"   , newList(),
            "Expiring", newList()
        )
        for k, v in pairs(self.db) do
            local start, duration = _G["Get"..v.kind.."Cooldown"](v.id, BOOKTYPE_SPELL)
            if self:CheckExpiring(start, duration) then
                table_insert(sortMe["Expiring"], newList(tonumber(string_format("%.3f", start + duration - GetTime())), k))
            elseif self:CheckSaved(v) then
                v.bar = "Saved"
            else
                if checkDurationLimit(start, duration) and getForcedHidden(k, v) == false then
                    if CooldownButtons.db.profile.moveItemsToSpells then
                        table_insert(sortMe["Spells"], newList(tonumber(string_format("%.3f", start + duration - GetTime())), k))
                    else
                        if v.kind == "Spell" or v.kind == "PetAction" then
                            table_insert(sortMe["Spells"], newList(tonumber(string_format("%.3f", start + duration - GetTime())), k))
                        elseif v.kind == "Item" then
                            table_insert(sortMe["Items"], newList(tonumber(string_format("%.3f", start + duration - GetTime())), k))
                        end
                    end
                    v.hide = false
                else
                    v.hide = true
                end
            end
            v.order = 0
            start, duration = nil, nil
        end

        local counts = newList()
        counts["Spells"]   = 1
        counts["Items"]    = 1
        counts["Expiring"] = 1
        for bar in pairs(sortMe) do
            table_sort(sortMe[bar], function(a, b) return a[1] < b[1] end)
            for _, data in pairs(sortMe[bar]) do
                self.db[data[2]].order = counts[bar]
                self.db[data[2]].bar = switchCase[self.db[data[2]].mode](bar)
                counts[bar] = counts[bar] + 1
            end
            self.dbNumPerBar[bar] = counts[bar]
        end
        counts = del(counts)
        sortMe = deepDel(sortMe)
    end
end

switchCase = {
  [0] = function(bar) return bar end,
  [1] = function(bar) return bar end,
  [2] = function(bar) return "Expiring" end,
}

function checkDurationLimit(start, duration)
    if CooldownButtons.db.profile.enableDurationLimit then
        if CooldownButtons.db.profile.showAfterLimit then
            return (start + duration - GetTime()) < CooldownButtons.db.profile.durationTime
        else
            return duration < self.db.durationTime
        end
    else
        return true
    end
end

function getForcedHidden(k, v)
    if v.kind == "Item" then
        return CooldownButtons.savedDB.profile.Items[v.id].hide
    else
        return CooldownButtons.savedDB.profile.Spells[k].hide
    end
end