--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
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
    local spellTreeTable = newList(newList(),newList(),newList(),newList())
    for _, spellData in pairs(self.spellTable) do
        local spellName  = spellData.spellName
        local spellIndex = spellData.spellIndex
        local start, duration, enable = GetSpellCooldown(spellIndex, BOOKTYPE_SPELL)
        if enable == 1 and start > 0 and duration > 3 then
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
            if enable == 1 and start > 0 and duration > 3 then
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
    "texture", "Interface\\AddOns\\CooldownButtons\\Icons\\shocks.tga",
    "ids",
        newList(
        "CDB_Spellgroup.Shocks.Frost_Shock",
        "CDB_Spellgroup.Shocks.Flame_Shock",
        "CDB_Spellgroup.Shocks.Earth_Shock" )
)

CooldownButtonsSpells.spellGroups[L["Spellgroup: Judgements"]] = newDict(
    "name", "Spellgroup: Judgements",
    "texture", "Interface\\Icons\\Spell_Holy_RighteousFury",
    "ids", newList( "CDB_Spellgroup.Judgements.Judgement_of_Wisdom",
        "CDB_Spellgroup.Judgements.Judgement_of_Justice",
        "CDB_Spellgroup.Judgements.Judgement_of_Light")
)

CooldownButtonsSpells.spellGroups[L["Spellgroup: Overpower/Revenge"]] = newDict(
    "name", L["Spellgroup: Overpower/Revenge"],
    "texture", "Interface\\AddOns\\CooldownButtons\\Icons\\warrior_2spells.tga",
    "ids", newList( "CDB_Spellgroup.Warrior.Overpower", "CDB_Spellgroup.Warrior.Revenge" )
)

local WRATH_ERROR_FIX = ""
if GetBuildInfo() == "2.4.3" then
    WRATH_ERROR_FIX = ",5573:"..GetSpellInfo(5573)..",1020:"..GetSpellInfo(1020)
end

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
    ["CDB_Spellgroup.Judgements.Judgement_of_Justice"] = "53407:"..GetSpellInfo(53407),
    ["CDB_Spellgroup.Judgements.Judgement_of_Light"]   = "20271:"..GetSpellInfo(20271),
    ["CDB_Spellgroup.Judgements.Judgement_of_Wisdom"]  = "53408:"..GetSpellInfo(53408),
    -- Warrior Stuff
    ["CDB_Spellgroup.Warrior.Overpower"] = "7384:"  ..GetSpellInfo(7384)  ..",7887:" ..GetSpellInfo(7887)  ..",11584:" ..GetSpellInfo(11584)  ..",11585:" ..GetSpellInfo(11585),
    ["CDB_Spellgroup.Warrior.Revenge"] = "6572:"  ..GetSpellInfo(6572) ..",6574:" ..GetSpellInfo(6574) ..",7379:" ..GetSpellInfo(7379) ..",11600:" ..GetSpellInfo(11600) ..",11601:" ..GetSpellInfo(11601) ..",25288:" ..GetSpellInfo(25288) ..",25269:" ..GetSpellInfo(25269) ..",30357:" ..GetSpellInfo(30357),
}) 
--/run ChatFrame1:AddMessage(tostring(select(1,GetSpellInfo(1020))));