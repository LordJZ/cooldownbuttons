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
local CooldownButtonsItems = CooldownButtons:NewModule("Items", "AceEvent-3.0")
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
            if not CooldownManager:CheckRegistred(itemName) then
                CooldownManager:Add("Item", itemName, itemID, itemTexture)
            end
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
                if not (itemEquipLoc == "INVTYPE_TRINKET") and not CooldownManager:CheckRegistred(itemName) then
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
CooldownButtonsItems.itemGroups[L["Potions"]] = newDict(
    "name",    L["Potions"],
    "texture", "Interface\\AddOns\\CooldownButtons\\Icons\\healmana.tga",
    "ids", newList("CDB_Itemgroup.Potions")
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
    ["CDB_Itemgroup.Potions"] = "32947:1,32948:1,3251:1,32783:1,32909:1,32902:1,32905:1,32904:1,32903:1,18839:1,18841:1,5632:1,33934:1,33935:1,22839:1,4596:1,12190:1,31677:1,31676:1,6049:1,5634:1,6050:1,5633:1,13461:1,20002:1,13457:1,13456:1,1710:1,13460:1,6149:1,13458:1,13459:1,13455:1,22838:1,23822:1,33092:1,22837:1,6051:1,737:1,22828:1,22849:1,2633:1,858:1,3385:1,4623:1,5816:1,3387:1,20008:1,34440:1,9036:1,22845:1,32840:1,31838:1,31839:1,31852:1,31853:1,31840:1,31841:1,31854:1,31855:1,22836:1,22841:1,32846:1,22842:1,32847:1,17348:1,13446:1,22847:1,17351:1,13444:1,22844:1,32844:1,18253:1,22846:1,32845:1,3827:1,23823:1,33093:1,13442:1,118:1,3384:1,2455:1,2456:1,3087:1,6052:1,13462:1,5631:1,32784:1,32910:1,9030:1,32762:1,32763:1,6048:1,22871:1,22826:1,22829:1,22832:1,22850:1,17349:1,3928:1,17352:1,13443:1,2459:1,6372:1,28101:1,28100:1,9144:1",
    
    -- Healtstones
    ["CDB_Itemgroup.Healthstone"]="22682:1,19045:1,20520:1,12662:1,18637:1,4381:1,15723:1,4392:1,18606:1,32578:1,23381:1,25880:1,23386:1,23334:1,27553:1,1703:1,11562:1,23354:1,25883:1,23329:1,22795:1,1322:1,22788:1,18645:1,5510:1,19010:1,19011:1,19008:1,19009:1,25881:1,18607:1,9172:1,5511:1,19006:1,19007:1,3823:1,14894:1,22261:1,35287:1,9421:1,19012:1,19013:1,5514:1,8007:1,22044:1,5513:1,8008:1,22103:1,22104:1,22105:1,16023:1,5512:1,19004:1,19005:1,11952:1,22797:1,25884:1,31451:1,17747:1,25550:1,1970:1,25498:1,25882:1,5205:1,4366:1,7676:1,11951:1",
    
    -- Drums (Leatherworking)
    ["CDB_Itemgroup.Drums"]="29528:1,29530:2,29531:3,29532:4,29529:5",
})