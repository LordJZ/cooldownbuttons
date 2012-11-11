--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CDB = CDB
local items = CreateFrame('frame')
CDB.items = items

items:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

--local L = CooldownButtons.L
--local LPT = LibStub("LibPeriodicTable-3.1")

------
local DF
local newList, newDict, del, deepDel, deepCopy = CDB.GetRecyclingFunctions()
local string_find = string.find
------

function items:Init()
    self.db = CDB.db
    self.itemCooldowns = {}

    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED")

    self:BAG_UPDATE_COOLDOWN()
end

function items:UNIT_INVENTORY_CHANGED() self:BAG_UPDATE_COOLDOWN() end

function items:BAG_UPDATE_COOLDOWN()
    local hasNewCooldown = false
    for i = 1, 18 do
        local start, duration, enable = GetInventoryItemCooldown("player", i)
        if enable == 1 and start > 0 and duration > 3 then
            local itemName, itemID, itemTexture = self:GetItemInfo(GetInventoryItemLink("player",i))
            if CDB:AddCooldown("Item", itemName, itemID, itemTexture) then
                self.itemCooldowns[itemID] = true
                hasNewCooldown = true
            end
        end
    end
    for i = 0, 4 do
        local slots = GetContainerNumSlots(i)
        for j = 1, slots do
            local start, duration, enable = GetContainerItemCooldown(i,j)
            if enable == 1 and start > 0 and duration > 3 then
                local itemName, itemID, itemTexture = self:GetItemInfo(GetContainerItemLink(i,j))
                local itemEquipLoc  = select(9, GetItemInfo(itemID))
                if not (itemEquipLoc == "INVTYPE_TRINKET") then
                    if CDB:AddCooldown("Item", itemName, itemID, itemTexture) then
                      self.itemCooldowns[itemID] = true
                      hasNewCooldown = true
                    end
                end
            end
        end
    end

    if hasNewCooldown == true then
        CDB:SortCooldowns()
        self:notifyOptionsUpdate()
    end
end

function items:notifyOptionsUpdate()
   if( CDB_Options ~= nil and CDB_Options.UpdateHiddenItemSettings ~= nil ) then
      CDB_Options:UpdateHiddenItemSettings()
   end
end

function items:GetItemInfo(itemlink)
    if not itemlink then return nil end
    local itemID   = select(3, string_find(itemlink, "Hitem:(%d+)"))
    
    local sets = self.db.profile.cooldownSets
    for name, data in pairs(sets) do
        if (data.type == "Item") and (data.ids[itemID] == true) then
            return name, itemID, data.icon
        end
    end
    return select(1, GetItemInfo(itemID)), itemID, select(10, GetItemInfo(itemID))
end
