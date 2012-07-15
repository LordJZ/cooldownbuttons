--[[
Name: CooldownButtons
Project Revision: 223
File Revision: 223 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local _G = _G
local CooldownButtons = _G.CooldownButtons
local CooldownButtonsSpells = CooldownButtons:NewModule("Spells", "AceEvent-3.0")

local L = CooldownButtons.L
local DF  = LibStub("LibDeformat-3.0")
local LPT = LibStub("LibPeriodicTable-3.1")
local CooldownManager = CooldownButtons:GetModule("Cooldown Manager")

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
    self:ResetSpells() -- Init Spell Table
    self:SPELL_UPDATE_COOLDOWN()
    self:PET_BAR_UPDATE_COOLDOWN()
end

function CooldownButtonsSpells:IterateSpellTable()
    return pairs(self.spellTable)
end

function CooldownButtonsSpells:SPELL_UPDATE_COOLDOWN()
    local treeTable   = self.treeTable
    local spellTable  = self.spellTable
    local spellsToAdd = newList()
    local spellTreeTable = newList(newList(),newList(),newList(),newList(),newList())
    for _, spellData in pairs(self.spellTable) do
        local spellName  = spellData.spellName
        local spellIndex = spellData.spellIndex
        local start, duration, enable = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
        if enable == 1 and start > 0 and duration >= 3 then
            spellTreeTable[spellData.spellTree][start*duration] = 1 + (spellTreeTable[spellData.spellTree][start*duration] or 0)
            if not CooldownManager:CheckRegistred(spellName) then
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
                if not CooldownManager:CheckRegistred(treeName) then
                    CooldownManager:Add("Spell", treeName, spellIndex, treeTexture)
                end
            end
        end
    end
    for spellName in pairs(spellsToAdd) do
        local spellIndex = self.spellTable[spellName].spellIndex
        local spellTexture = self.spellTable[spellName].spellTexture
        CooldownManager:Add("Spell", spellName, spellIndex, spellTexture)
        self.cooldownsChanged = true
    end
    spellsToAdd = deepDel(spellsToAdd)
    spellTreeTable = deepDel(spellTreeTable)
end

function CooldownButtonsSpells:PET_BAR_UPDATE_COOLDOWN()
    if not UnitExists("pet") or CooldownButtons.db.profile.hidePetSpells then return end
    for spellIndex = 0, 9 do
        local spellName = GetPetActionInfo(spellIndex)
        if spellName ~= nil then
            local start, duration, enable = GetPetActionCooldown(spellIndex)
            if enable == 1 and start > 0 and duration >= 3 then
                local texture = select(3, GetSpellInfo(spellName)) or select(3, GetPetActionInfo(spellIndex))
                if not CooldownManager:CheckRegistred(spellName) then
                    CooldownManager:Add("PetAction", spellName, spellIndex, texture)
                end
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
            if spellName and (not self.spellTable[spellName] or (
                self.spellTable[spellName] and
                (self.spellTable[spellName]["spellIndex"] ~= spellIndex) and
                (self.spellTable[spellName]["spellID"] == spellID)))
            then
                if self.spellTable[spellName] then self.spellTable[spellName] = del(self.spellTable[spellName]) end

                self.spellTable[spellName] = newDict(
                    "spellName"    , spellName,
                    "spellIndex"   , spellIndex,
                    "spellID"      , spellID,
                    "spellknownCD" , _GetKnownCooldown(spellIndex),
                    "spellTexture" , GetSpellTexture(spellIndex, BOOKTYPE_SPELL),
                    "spellTree"    , spellTree
                )
                local _, class = UnitClass("player")
                if class == "DEATHKNIGHT" and self.spellTable[spellName].spellknownCD == nil then
                    self.spellTable[spellName] = del(self.spellTable[spellName])
                end
            end
        end
    end
end

function _GetKnownCooldown(spellIndex)
    CDBTooltipTextRight2:SetText("")
    CDBTooltipTextRight3:SetText("")
    CDBTooltipTextRight4:SetText("")
    CDBTooltip:SetSpellBookItem(spellIndex, BOOKTYPE_SPELL)
    return (
            (
                CDBTooltipTextRight2:GetText()
                and (DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_MIN)
                or   DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_SEC))
            ) or (
                CDBTooltipTextRight3:GetText()
                and (DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_MIN)
                or   DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_SEC))
            ) or (
                CDBTooltipTextRight4:GetText()
                and (DF:Deformat(CDBTooltipTextRight4:GetText(), SPELL_RECAST_TIME_MIN)
                or   DF:Deformat(CDBTooltipTextRight4:GetText(), SPELL_RECAST_TIME_SEC))
            )
           )
end

function _GetSpellName(index)
    local spell, rank = GetSpellBookItemName(index, BOOKTYPE_SPELL)
    local spellLink   = GetSpellLink(index, BOOKTYPE_SPELL)
    if not spellLink then
        return nil, nil
    end

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

CooldownButtonsSpells.spellGroups[L["Spellgroup: Shoots"]] = newDict(
    "name",    L["Spellgroup: Shoots"],
    "texture", "Interface\\Icons\\Ability_Hunter_Assassinate2",
    "ids",
        newList(
        "CDB_Spellgroup.Shoots.Explosive_Shot",
        "CDB_Spellgroup.Shoots.Arcane_Shot",
        "CDB_Spellgroup.Shoots.Kill_Shot" )
)

CooldownButtonsSpells.spellGroups[L["Spellgroup: Shocks"]] = newDict(
    "name", L["Spellgroup: Shocks"],
    "texture", "Interface\\AddOns\\CooldownButtons\\Icons\\shocks.tga",
    "ids",
        newList(
        "CDB_Spellgroup.Shocks.Frost_Shock",
        "CDB_Spellgroup.Shocks.Flame_Shock",
        "CDB_Spellgroup.Shocks.Earth_Shock",
        "CDB_Spellgroup.Shocks.Wind_Shock" )
)

CooldownButtonsSpells.spellGroups[L["Spellgroup: Overpower/Revenge"]] = newDict(
    "name", L["Spellgroup: Overpower/Revenge"],
    "texture", "Interface\\AddOns\\CooldownButtons\\Icons\\warrior_2spells.tga",
    "ids", newList( "CDB_Spellgroup.Warrior.Overpower", "CDB_Spellgroup.Warrior.Revenge" )
)

-- LPT Spell Database
LPT:AddData("CDB_Spellgroup", "$Rev: 223 $", {
    -- Hunter Traps
    ["CDB_Spellgroup.Traps.Immolation_Trap"] = "13795:"..GetSpellInfo(13795)..",82945:"..GetSpellInfo(82945),
    ["CDB_Spellgroup.Traps.Explosive_Trap"]  = "13813:"..GetSpellInfo(13813)..",82939:"..GetSpellInfo(82939),
    ["CDB_Spellgroup.Traps.Freezing_Trap"]   = "1499:" ..GetSpellInfo(1499) ..",60192:"..GetSpellInfo(60192),
    ["CDB_Spellgroup.Traps.Frost_Trap"]      = "13809:"..GetSpellInfo(13809),
    ["CDB_Spellgroup.Traps.Snake_Trap"]      = "34600:"..GetSpellInfo(34600),
    ["CDB_Spellgroup.Shoots.Explosive_Shot"] = "53301:"..GetSpellInfo(53301),
    ["CDB_Spellgroup.Shoots.Arcane_Shot"]    = "3044:" ..GetSpellInfo(3044),
    ["CDB_Spellgroup.Shoots.Kill_Shot"]      = "53351:"..GetSpellInfo(53351),
    -- Shaman Shocks
    ["CDB_Spellgroup.Shocks.Frost_Shock"]    = "8056:" ..GetSpellInfo(8056),
    ["CDB_Spellgroup.Shocks.Flame_Shock"]    = "8050:" ..GetSpellInfo(8050),
    ["CDB_Spellgroup.Shocks.Earth_Shock"]    = "8042:" ..GetSpellInfo(8042),
    ["CDB_Spellgroup.Shocks.Wind_Shock"]     = "57994:" ..GetSpellInfo(57994),
    -- Warrior Stuff
    ["CDB_Spellgroup.Warrior.Overpower"] = "7384:"..GetSpellInfo(7384),
    ["CDB_Spellgroup.Warrior.Revenge"] = "6572:"..GetSpellInfo(6572),
}) 
--/run ChatFrame1:AddMessage(tostring(select(1,GetSpellInfo(1020))));