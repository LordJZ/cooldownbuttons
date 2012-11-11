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
local spells = CreateFrame('frame')
CDB.spells = spells

spells:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

--local L = CooldownButtons.L
--local LPT = LibStub("LibPeriodicTable-3.1")

------
local DF
local newList, newDict, del, deepDel, deepCopy = CDB.GetRecyclingFunctions()
local string_find = string.find
------

function spells:Init()
    DF = LibStub("LibDeformat-3.0")
    
    self.tooltip = CreateFrame("GameTooltip", "CDBTooltip", UIParent, "GameTooltipTemplate")
    self.tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    self.db = CDB.db
    self.spellTable = newList()
    self.treeTable  = newList()

    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    self:RegisterEvent("SPELLS_CHANGED")


    self:SPELLS_CHANGED() -- Init Spell Table
    self:SPELL_UPDATE_COOLDOWN()
    self:PET_BAR_UPDATE_COOLDOWN()
end

function spells:SPELL_UPDATE_COOLDOWN()
    local hasNewCooldown = false
    local treeTable   = self.treeTable
    local spellTable  = self.spellTable
    local spellsToAdd = newList()
    local spellTreeTable = newList(newList(),newList(),newList(),newList())
    for _, spellData in pairs(self.spellTable) do
        local spellID = spellData.spellID
        local spellName  = spellData.spellName
        local start, duration, enable = GetSpellCooldown(spellID)
        if enable == 1 and start > 0 and duration >= 3 then
            spellTreeTable[spellData.spellTree][start*duration] = 1 + (spellTreeTable[spellData.spellTree][start*duration] or 0)
            spellsToAdd[spellName] = newList(spellID, start, duration)
        end
    end
    for treeIndex = 1, 2 do -- General Tab and current Spec
        for time in pairs(spellTreeTable[treeIndex]) do
            if spellTreeTable[treeIndex][time] > 3 then
                local spellID = nil
                local spellIndex = nil
                for spellName, spellData in pairs(spellsToAdd) do
                    if treeIndex == spellTable[spellName].spellTree then
                        if spellData[2] * spellData[3] == time then
                            spellID = spellData[1]
                            spellsToAdd[spellName] = del(spellsToAdd[spellName])
                        end
                    end
                end
                local treeName    = treeTable[treeIndex].treeName
                local treeTexture = treeTable[treeIndex].treeTexture

                if CDB:AddCooldown("Spell", treeName, spellID, treeTexture) then
                    hasNewCooldown = true
                end
            end
        end
    end
    for spellName in pairs(spellsToAdd) do
        local spellID   = self.spellTable[spellName].spellID
        local spellTexture = self.spellTable[spellName].spellTexture
        
        if CDB:AddCooldown("Spell", spellName, spellID, spellTexture) then
            hasNewCooldown = true
        end
    end
    if hasNewCooldown == true then
        CDB:SortCooldowns()
    end

    --cleanup
    spellsToAdd = deepDel(spellsToAdd)
    spellTreeTable = deepDel(spellTreeTable)
end

function spells:PET_BAR_UPDATE_COOLDOWN()
    local hasNewCooldown = false
    if not UnitExists("pet") --[[ oder config sagt keine pets !]] then return end
    for spellIndex = 0, 9 do
        local spellName = GetPetActionInfo(spellIndex)
        if spellName ~= nil then
            local start, duration, enable = GetPetActionCooldown(spellIndex)
            if enable == 1 and start > 0 and duration >= 3 then
                local texture = select(3, GetPetActionInfo(spellIndex))
                local spellID = select(8, GetPetActionInfo(spellIndex))
                if CDB:AddCooldown("PetAction", spellName, spellID, texture) then
                    hasNewCooldown = true
                end
            end
        end
    end
    if hasNewCooldown == true then
        CDB:SortCooldowns()
    end
end

function spells:SPELLS_CHANGED()
    local treeTable   = self.treeTable
    local spellTable  = self.spellTable
    for spellTree = 1, 2 do -- General Tab and current Spec
        local treeName, treeTexture, offset, num = GetSpellTabInfo(spellTree)
        treeTable[spellTree] = newDict(
            "treeName"    , treeName,
            "treeTexture" , treeTexture
        )
        for j = 1, num do
            local spellIndex = offset + j
            local spellName, spellID, texture = self:GetSpellInfo(spellIndex, BOOKTYPE_SPELL)
            if spellName ~= nil then
            	self:insertSpell(spellName, spellID, texture, spellTree)
            else
                local flyoutName, _, flyoutSlots, flyoutIsKnown = GetFlyoutInfo(spellID);
                if flyoutIsKnown then
                    for slot = 1, flyoutSlots do
                        local spellID, isKnown = GetFlyoutSlotInfo(spellID, slot)
                        if isKnown then
                            local spellName, _, texture = GetSpellInfo(spellID)
                            if spellName == nil then
                                if spellID ~= 13219 then -- Allready known: Old Wound Poison thats no longer available... http://old.wowhead.com/spell=13219
                                    DEFAULT_CHAT_FRAME:AddMessage("Unknown SpellID "..spellID.." in Flyout #"..spellID.."("..flyoutName..") please report on http://www.wowace.com/addons/cooldownbuttons/")
                                end
                            else
                                self:insertSpell(spellName, spellID, texture, spellTree)
                            end
                        end
                    end
                end
            end
        end
    end
end

function spells:insertSpell(spellName, spellID, texture, spellTree)
	if not self.spellTable[spellName] then
		self.spellTable[spellName] = newDict(
			"spellName"    , spellName,
			"spellID"      , spellID,
			"spellknownCD" , self:GetKnownCooldown(spellID),
			"spellTexture" , texture,
			"spellTree"    , spellTree
		)
		local _, class = UnitClass("player")
		if class == "DEATHKNIGHT" and self.spellTable[spellName].spellknownCD == nil then
			self.spellTable[spellName] = del(self.spellTable[spellName])
		end
	end
end

function spells:GetKnownCooldown( spellID)
    CDBTooltipTextRight2:SetText("")
    CDBTooltipTextRight3:SetText("")
    CDBTooltipTextRight4:SetText("")
    CDBTooltip:SetSpellByID(spellID)
    return (
            (
                CDBTooltipTextRight2:GetText()
                and (DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_MIN)
                or   DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_SEC)
                or   DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_HOURS))
            ) or (
                CDBTooltipTextRight3:GetText()
                and (DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_MIN)
                or   DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_SEC)
                or   DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_HOURS))
            ) or (
                CDBTooltipTextRight4:GetText()
                and (DF:Deformat(CDBTooltipTextRight4:GetText(), SPELL_RECAST_TIME_MIN)
                or   DF:Deformat(CDBTooltipTextRight4:GetText(), SPELL_RECAST_TIME_SEC)
                or   DF:Deformat(CDBTooltipTextRight4:GetText(), SPELL_RECAST_TIME_HOURS))
            )
           )
end

function spells:GetSpellInfo(index)
    local spellType, spellBookId = GetSpellBookItemInfo(index, BOOKTYPE_SPELL)
    if spellType == "FLYOUT" then
    	return nil, spellBookId, spellType
    end
    
    local spellName = GetSpellBookItemName(index, BOOKTYPE_SPELL)
    local spellLink = GetSpellLink(index, BOOKTYPE_SPELL)
    local spellID   = select(3, string_find(spellLink, "spell:(%d+)"))
    
    local sets = self.db.profile.cooldownSets
    for name, data in pairs(sets) do
        if (data.type == "Spell") and (data.ids[spellID] == true) then
            return name, spellID, data.icon
        end
    end
    return spellName, spellID, GetSpellTexture(index, BOOKTYPE_SPELL)
end
