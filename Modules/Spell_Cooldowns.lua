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
local CooldownButtonsSpells = CooldownButtons:NewModule("Spells","AceEvent-3.0")
CooldownButtonsSpells.rev = tonumber(("$Revision$"):match("%d+")) or 0
local L = CooldownButtons.L
local DF  = LibStub("LibDeformat-3.0")
local LPT = LibStub("LibPeriodicTable-3.1")

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local string_find = string.find
------

function CooldownButtonsSpells:OnInitialize()
    self.db = CooldownButtons.db.profile.barSettings[self:GetName()]

    self.tooltip = CreateFrame("GameTooltip", "CDBTooltip", UIParent, "GameTooltipTemplate")
	self.tooltip:SetOwner(UIParent, "ANCHOR_NONE")

    self.spellTable  = newList()
    self.treeTable   = newList()

    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
    self:RegisterEvent("SPELLS_CHANGED", "ResetSpells")

    CooldownButtons:GetModule("Config"):AddBarSettings(L["Spells"], "Spells", self.db, 10)
end

function CooldownButtonsSpells:OnEnable()
    self:InitBarEngine()
    self:InitButtonEngine()
    self:InitCooldownEngine()
    self:ResetSpells() -- Init Spell Table
    self:SPELL_UPDATE_COOLDOWN()
    self:PET_BAR_UPDATE_COOLDOWN()
    
    -- Fix nil Index error... (maybe-.-)
    self.itemGroups  = CooldownButtons:GetModule("Items").itemGroups
end

function CooldownButtonsSpells:IterateSpellTable()
    return pairs(self.spellTable)
end

function CooldownButtonsSpells:SPELL_UPDATE_COOLDOWN()
    local treeTable   = self.treeTable
    local spellTable  = self.spellTable
    local spellsToAdd = newList()
    local spellTreeTable = newList(newList(),newList(),newList(),newList())
    for _, spellData in pairs(self.spellTable) do
        local spellName  = spellData.spellName
        local spellIndex = spellData.spellIndex
        local start, duration, enable = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
        if enable == 1 and start > 0 and duration > 3 then
            spellTreeTable[spellData.spellTree][start*duration] = 1 + (spellTreeTable[spellData.spellTree][start*duration] or 0)
            if not self:IsCooldown(spellName) then
                spellsToAdd[spellName] = newList(self.spellTable[spellName].spellIndex, start, duration)
            end
        end
    end
    for treeIndex = 1, GetNumSpellTabs() do 
        for time in pairs(spellTreeTable[treeIndex]) do
            if spellTreeTable[treeIndex][time] > 3 then
                local spellIndex = nil
                for spellName, spellData in pairs(spellsToAdd) do
                    if treeIndex == spellTable[spellName].spellTree then
                        if spellData[2] * spellData[3] == time then
                            spellIndex = spellData[1]
                            spellsToAdd[spellName] = del(spellsToAdd[spellName])
                        end
                    end
                end
                local treeName    = treeTable[treeIndex].treeName
                local treeTexture = treeTable[treeIndex].treeTexture

                self:registerCooldown("Spell", treeName, spellIndex, treeTexture)
            end
        end
    end
    for spellName in pairs(spellsToAdd) do
        local spellIndex = self.spellTable[spellName].spellIndex
        local spellTexture = self.spellTable[spellName].spellTexture
        self:registerCooldown("Spell", spellName, spellIndex, spellTexture)
        self.cooldownsChanged = true
    end
    spellsToAdd = deepDel(spellsToAdd)
    spellTreeTable = deepDel(spellTreeTable)
end

function CooldownButtonsSpells:PET_BAR_UPDATE_COOLDOWN()
    if not UnitExists("pet") then return end
    for spellIndex = 0, 9 do
        local spellName  = GetPetActionInfo(spellIndex)
        if spellName ~= nil then
            local start, duration, enable = GetPetActionCooldown(spellIndex)
            if enable == 1 and start > 0 and duration > 3 then
                self:registerCooldown("PetAction", spellName, spellIndex, select(3, GetSpellInfo(spellName)))
            end
        end
    end
end

local _GetKnownCooldown, _GetSpellName
function CooldownButtonsSpells:ResetSpells()
    local treeTable   = self.treeTable
    local spellTable  = self.spellTable
    for spellTree = 1, GetNumSpellTabs() do
        local treeName, treeTexture, offset, num = GetSpellTabInfo(spellTree)
        treeTable[spellTree] = newDict(
            "treeName"    , treeName,
            "treeTexture" , treeTexture
        )
        for j = 1, num do
            local spellIndex = offset + j
            local spellName, spellID  = _GetSpellName(spellIndex, BOOKTYPE_SPELL)
            if not self.spellTable[spellName] or (self.spellTable[spellName] and (self.spellTable[spellName]["spellIndex"] ~= spellIndex) and (self.spellTable[spellName]["spellID"] == spellID)) then
                if self.spellTable[spellName] then self.spellTable[spellName] = del(self.spellTable[spellName]) end

                self.spellTable[spellName] = newDict(
                    "spellName"    , spellName,
                    "spellIndex"   , spellIndex,
                    "spellID"      , spellID,
                    "spellknownCD" , _GetKnownCooldown(spellIndex),
                    "spellTexture" , GetSpellTexture(spellIndex, BOOKTYPE_SPELL),
                    "spellTree"    , spellTree
                )
            end
        end
    end
end

function _GetKnownCooldown(spellIndex)
    CDBTooltipTextRight2:SetText("")
    CDBTooltipTextRight3:SetText("")
    CDBTooltip:SetSpell(spellIndex, BOOKTYPE_SPELL)
    return (CDBTooltipTextRight2:GetText() and (DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_MIN) or DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_SEC))) or (CDBTooltipTextRight3:GetText() and (DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_MIN) or DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_SEC)))
end

function _GetSpellName(index)
    local spell, rank = GetSpellName(index, BOOKTYPE_SPELL)
    local spellLink   = GetSpellLink(index, BOOKTYPE_SPELL)
    local spellID     = select(3, string_find(spellLink, "spell:(%d+)"))
    local group       = select(2, LPT:ItemInSet(spellID, "CDB_Spellgroup"))
    local groupKey    = nil

    for key, value in pairs(CooldownButtonsSpells.spellGroups) do
        if type(value) == "table" then
            for _, curid in pairs(value.ids) do
                if curid == group then
                    groupKey = key
                end
            end
        end
    end
    if groupKey then
        return CooldownButtonsSpells.spellGroups[groupKey].name, spellID
    else
        return spell, spellID
    end
end

-- Spell Groups
CooldownButtonsSpells.spellGroups = newList()
CooldownButtonsSpells.spellGroups[L["Spellgroup: Traps"]] = newDict(
    "name",    L["Spellgroup: Traps"],
    "texture", "Interface\\Icons\\Spell_Frost_ChainsOfIce",
    "ids",
        newList(
        "CDB_Spellgroup.Traps.Immolation_Trap",
        "CDB_Spellgroup.Traps.Explosive_Trap",
        "CDB_Spellgroup.Traps.Freezing_Trap",
        "CDB_Spellgroup.Traps.Frost_Trap",
        "CDB_Spellgroup.Traps.Snake_Trap" )
)

CooldownButtonsSpells.spellGroups[L["Spellgroup: Shocks"]] = newDict(
    "name", L["Spellgroup: Shocks"],
    "texture", "Interface\\AddOns\\CooldownButtons\\shocks.tga",
    "ids",
        newList(
        "CDB_Spellgroup.Shocks.Frost_Shock",
        "CDB_Spellgroup.Shocks.Flame_Shock",
        "CDB_Spellgroup.Shocks.Earth_Shock" )
)

CooldownButtonsSpells.spellGroups[L["Spellgroup: Divine Shields"]] = newDict(
    "name", L["Spellgroup: Shocks"],
    "texture", "Interface\\Icons\\Spell_Holy_DivineIntervention",
    "ids", newList( "CDB_Spellgroup.Shields.Divine_Shield" )
)

-- LPT Spell Database
LPT:AddData("CDB_Spellgroup", "$Rev$", {
    -- Hunter Traps
    ["CDB_Spellgroup.Traps.Immolation_Trap"] = "13795:"..GetSpellInfo(13795)..",14302:"..GetSpellInfo(14302)..",14303:"..GetSpellInfo(14303)..",14304:"..GetSpellInfo(14304)..",14305:"..GetSpellInfo(14305)..",27023:"..GetSpellInfo(27023),
    ["CDB_Spellgroup.Traps.Explosive_Trap"]  = "13813:"..GetSpellInfo(13813)..",14316:"..GetSpellInfo(14316)..",14317:"..GetSpellInfo(14317)..",27025:"..GetSpellInfo(27025),
    ["CDB_Spellgroup.Traps.Freezing_Trap"]   = "1499:" ..GetSpellInfo(1499) ..",14310:"..GetSpellInfo(14310)..",14311:"..GetSpellInfo(14311),
    ["CDB_Spellgroup.Traps.Frost_Trap"]      = "13809:"..GetSpellInfo(13809),
    ["CDB_Spellgroup.Traps.Snake_Trap"]      = "34600:"..GetSpellInfo(34600),
    -- Shaman Shocks
    ["CDB_Spellgroup.Shocks.Frost_Shock"]    = "8056:" ..GetSpellInfo(8056) ..",8058:" ..GetSpellInfo(8058) ..",10472:"..GetSpellInfo(10472)..",10473:"..GetSpellInfo(10473)..",25464:"..GetSpellInfo(25464),
    ["CDB_Spellgroup.Shocks.Flame_Shock"]    = "8050:" ..GetSpellInfo(8050) ..",8052:" ..GetSpellInfo(8052) ..",8053:" ..GetSpellInfo(8053) ..",10447:"..GetSpellInfo(10447)..",10448:"..GetSpellInfo(10448)..",29228:"..GetSpellInfo(29228)..",25457:"..GetSpellInfo(25457),
    ["CDB_Spellgroup.Shocks.Earth_Shock"]    = "8042:" ..GetSpellInfo(8042) ..",8044:" ..GetSpellInfo(8044) ..",8045:" ..GetSpellInfo(8045) ..",8046:" ..GetSpellInfo(8046) ..",10412:"..GetSpellInfo(10412)..",10413:"..GetSpellInfo(10413)..",10414:"..GetSpellInfo(10414)..",25454:"..GetSpellInfo(25454),
    -- Paladin Shields
    ["CDB_Spellgroup.Shields.Divine_Shield"] = "642:"  ..GetSpellInfo(642)  ..",5573:" ..GetSpellInfo(5573) ..",498:"  ..GetSpellInfo(498)  ..",1020:" ..GetSpellInfo(1020),
})
