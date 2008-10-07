--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CooldownButtons = _G.CooldownButtons
local CooldownButtonsConfig = CooldownButtons:GetModule("Config")
local L = CooldownButtons.L
local DF  = LibStub("LibDeformat-3.0")

local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local getOrder, createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor = CooldownButtonsConfig:GetWidgetAPI()
local string_find = string.find

local createSpellConfigStuff, createItemConfigStuff
local addNewItemData = ""
function CooldownButtonsConfig:SavedPetCooldownsConfig()
    local options = self.options
    options.args.cooldownSettings.args.saved.args.petspells = {
        type = "group",
        name = L["Pet Spells"],
        childGroups = "select",
        order = getOrder(),
        args = {
        },
    }
    --/dump CooldownButtons:GetModule("Config").options.args.cooldownSettings.args.saved.args.items.args
    local petArgs = options.args.cooldownSettings.args.saved.args.petspells.args

    local i = 1
    local spellAdded = false
    while true do
        local spellName, spellRank = GetSpellName(i, BOOKTYPE_PET)

        if not spellName then do break end end
        CDBTooltipTextRight2:SetText("")
        CDBTooltipTextRight3:SetText("")
        CDBTooltip:SetSpell(i, BOOKTYPE_PET)
        local hasCD =  (CDBTooltipTextRight2:GetText() and (DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_MIN) or DF:Deformat(CDBTooltipTextRight2:GetText(), SPELL_RECAST_TIME_SEC))) or (CDBTooltipTextRight3:GetText() and (DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_MIN) or DF:Deformat(CDBTooltipTextRight3:GetText(), SPELL_RECAST_TIME_SEC)))

        if hasCD then
            petArgs[string.replace(spellName," ","_")] = createPetSpellConfigStuff(spellName)
            spellAdded = true
        end
        i = i + 1
    end
    
    -- No Pet Spell with Cooldown found
    if not spellAdded then
        CooldownButtonsConfig.options.args.cooldownSettings.args.saved.args.petspells = nil
    end

end

function createPetSpellConfigStuff(cooldownName)
    local db = CooldownButtons.savedDB.profile.Spells[cooldownName]
    local confname =  cooldownName
    return {
        type = "group",
        name = confname,
        order = getOrder(),
        set = function( k, v )
                if k.arg == "posx" then
                    if not (tonumber(v) == nil) then
                        db.pos.x = tonumber(v);
                    end
                elseif k.arg == "posy" then
                    if not (tonumber(v) == nil) then
                        db.pos.y = tonumber(v);
                    end
                elseif k.arg == "hide" or
                       k.arg == "save" then
                    db[k.arg] = v
                    CooldownButtons:GetModule("Cooldown Manager"):sortCooldowns()
                else
                    db[k.arg] = v
                end
              end,
        get = function( k )
                if k.arg == "posx" then
                    return tostring(db.pos.x)
                elseif k.arg == "posy" then
                    return tostring(db.pos.y)
                else
                    return db[k.arg]
                end
              end,
        args = {
            header_00 = createHeader(confname),
            radioHide = createToggle(L["Hide Button"], "", "hide", true),
            radioSave = createToggle(L["Save Button Position"], "", "save", nil ,function() return db.hide end),

            desc = createDescription(L["Here you can Setup at what position the Cooldown Button for the selected Spell should be drawn to."]),
            pos_x = createInput(L["X - Axis"], L["Set the Position on X-Axis."], "posx", nil ,function() return db.hide end),
            pos_y = createInput(L["Y - Axis"], L["Set the Position on Y-Axis."], "posy", nil ,function() return db.hide end),

            showAnchor = createExecute(L["Show Movable Button"], "", cooldownName, function(k)
                local BarManager = CooldownButtons:GetModule("Bar Manager")
                if not BarManager.anchorDB[k.arg] then
                    k.option.name = L["Hide Movable Button"]
                    BarManager:ShowAnchor(k.arg, "Spell")
                else
                    k.option.name = L["Show Movable Button"]
                    BarManager:HideAnchor(k.arg)
                end
                LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
            end, nil, function() return db.hide end),
        },
    }
end
