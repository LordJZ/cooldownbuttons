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
local CooldownButtonsItems = CooldownButtons:NewModule("Items", "AceEvent-3.0")
CooldownButtonsItems.rev = tonumber(("$Revision$"):match("%d+")) or 0
local L = CooldownButtons.L
local LPT = LibStub("LibPeriodicTable-3.1")
local CooldownManager = CooldownButtons:GetModule("Cooldown Manager")

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local string_find = string.find
------

function CooldownButtonsItems:OnInitialize()
    self.db = CooldownButtons.db.profile.barSettings[self:GetName()]

    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "BAG_UPDATE_COOLDOWN")

    CooldownButtons:GetModule("Config"):AddBarSettings(L["Items"], "Items", self.db, 20)
end

function CooldownButtonsItems:OnEnable()
    self:BAG_UPDATE_COOLDOWN()
end

function CooldownButtonsItems:BAG_UPDATE_COOLDOWN()
    for i = 1, 18 do
        local start, duration, enable = GetInventoryItemCooldown("player", i)
        if enable == 1 and start > 0 and duration > 3 then
            local link = GetInventoryItemLink("player",i)
            local itemName = select(3, string_find(link, "Hitem[^|]+|h%[([^[]+)%]"))
            local itemID   = select(3, string_find(link, "Hitem:(%d+)"))
            local itemTexture = GetInventoryItemTexture("player", i)
            CooldownManager:Add("Item", itemName, itemID, itemTexture)
        end
    end
    for i = 0, 4 do
        local slots = GetContainerNumSlots(i)
        for j = 1, slots do
            local start, duration, enable = GetContainerItemCooldown(i,j)
            if enable == 1 and start > 0 and duration > 3 then
                local link = GetContainerItemLink(i,j)
                local itemID   = select(3, string_find(link, "Hitem:(%d+)"))
                local itemName = self:getItemName(itemID)
                local itemTexture = GetContainerItemInfo(i,j)
                local itemEquipLoc  = select(9, GetItemInfo(itemID))
                if not (itemEquipLoc == "INVTYPE_TRINKET") then
                    CooldownManager:Add("Item", itemName, itemID, itemTexture)
                end
            end
        end
    end
end

function CooldownButtonsItems:getItemName(itemid)
    if not itemid then return nil end
    local group = select(2, LPT:ItemInSet(itemid, "CDB_Itemgroup"))
    for groupKey, value in pairs(self.itemGroups) do
        if type(value) == "table" then
            for _, curid in pairs(value.ids) do
                if curid == group then
                    return groupKey
                end
            end
        end
    end
    return select(1, GetItemInfo(itemid))
end

-- Item Groups and LPT Item Database
CooldownButtonsItems.itemGroups = newList()
CooldownButtonsItems.itemGroups[L["Healing/Mana Potions"]] = newDict(
    "name",    L["Healing/Mana Potions"],
    "texture", "Interface\\AddOns\\CooldownButtons\\healmana.tga",
    "ids", newList("CDB_Itemgroup.Health", "CDB_Itemgroup.Mana", "CDB_Itemgroup.Rejuvenation" )
)
    
CooldownButtonsItems.itemGroups[L["Other Potions"]] = newDict(
    "name",    L["Other Potions"],
    "texture", "Interface\\Icons\\INV_Potion_47",
    "ids", newList("CDB_Itemgroup.Resistance", "CDB_Itemgroup.Rage")
)

CooldownButtonsItems.itemGroups[L["Healthstone"]] = newDict(
    "name",    L["Healthstone"],
    "texture", "Interface\\Icons\\INV_Stone_04",
    "ids", newList("CDB_Itemgroup.Healthstone")
)

CooldownButtonsItems.itemGroups[L["Drums (Leatherworking)"]] = newDict(
    "name",    L["Drums (Leatherworking)"],
    "texture", "Interface\\Icons\\INV_Misc_Drum_02",
    "ids", newList("CDB_Itemgroup.Drums")
)

LPT:AddData("CDB_Itemgroup", "$Rev$", {
    -- Healing potions
    ["CDB_Itemgroup.Health"] = "118:80,858:160,4596:160,929:320,1710:520,11562:670,3928:800,18839:800,13446:1400,31838:1400,31839:1400,31852:1400,31853:1400,28100:1400,33092:2000,23822:2000,22829:2000,32947:2000,33934:2000,"
                             .."32784:1400,32910:1400,32904:2000,32905:2000,17349:640,17348:1120,118:80,858:160,4596:160,929:320,1710:520,11562:670,3928:800,18839:800,13446:1400,31838:1400,31839:1400,31852:1400,31853:1400,"
                             .."28100:1400,33092:2000,23822:2000,22829:2000,32947:2000,33934:2000,32784:1400,32910:1400,32904:2000,32905:2000,17349:640,17348:1120",
    
    -- Mana potions
    ["CDB_Itemgroup.Mana"]   = "2455:160,3385:320,3827:520,6149:800,13443:1200,18841:1200,13444:1800,31840:1800,31841:1800,31854:1800,31855:1800,28101:1800,33093:2400,23823:2400,22832:2400,32948:2400,33935:2400,31677:3200,"
                             .."32909:2400,32783:2400,32903:2400,17351:1120,17352:640,32902:2400,2455:160,3385:320,3827:520,6149:800,13443:1200,18841:1200,13444:1800,31840:1800,31841:1800,31854:1800,31855:1800,28101:1800,"
                             .."33093:2400,23823:2400,22832:2400,32948:2400,33935:2400,31677:3200,32909:2400,32783:2400,32903:2400,17351:1120,17352:640,32902:2400",
    
    -- other potions
    ["CDB_Itemgroup.Resistance"] = "13461:2600,22845:3400,32063:20,22795:1000,6049:1300,13457:2600,22841:3400,6050:1800,13456:2600,22842:3400,6051:400,22847:3400,6052:1800,13458:2600,22844:3400,6048:900,13459:2600,22846:3400",
    ["CDB_Itemgroup.Rage"]       = "5631:30,5633:45,13442:45",
    ["CDB_Itemgroup.Rejuvenation"] = "2456:30,18253:45,22850:45",
    
    -- Healtstones
    ["CDB_Itemgroup.Healthstone"]="5509:500,5510:800,5511:250,5512:100,9421:1200,19004:110,19005:120,19006:275,19007:300,19008:550,19009:600,19010:880,19011:960,19012:1320,19013:1440,22103:2080,22104:2288,22105:2496",
    
    -- Drums (Leatherworking)
    ["CDB_Itemgroup.Drums"]="29528:1,29530:2,29531:3,29532:4,29529:5",
})