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

local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local getOrder, createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor = CooldownButtonsConfig:GetWidgetAPI()
local string_find = string.find

local createSpellConfigStuff, createItemConfigStuff
local addNewItemData = ""
function CooldownButtonsConfig:SavedCooldownsConfig()
    self.SavedCooldownsConfigIsSet = true

    local options = self.options
    options.args.cooldownSettings.args.saved = {
        type = "group",
        name = L["Save or Hide"],
        order = getOrder(),
        --childGroups = "tab",
        args = {
            spells = {
                type = "group",
                name = L["Spells"],
                childGroups = "select",
                order = getOrder(),
                args = {
                },
            },
            items = {
                type = "group",
                name = L["Items"],
                childGroups = "select",
                order = getOrder(),
                set = function(k,v) addNewItemData = v end,
                get = function(k) return addNewItemData end,
                args = {
                    ["0000"] = {
                        type = "group",
                        name = L["~ Add Item ~"],
                        order = 0,
                        args = {
                            itemName = createInput(L["Item Name or ItemID"], L["You can get the ItemID from www.wowhead.com!"], ""),
                            itemAdd = createExecute("Add", "", "", function(k)
                                    local terror = k.options.args.cooldownSettings.args.saved.args.items.args["0000"].args.errorMessage
                                    terror.name = ""
                                    if addNewItemData == "" then
                                        terror.name = L["No Item given."]
                                        return 1
                                    end
                                    local itemName, itemLink = GetItemInfo(addNewItemData)
                                    if itemName then
                                        local itemID = select(3, string_find(itemLink, "Hitem:(%d+)"))
                                        local itemArgs = k.options.args.cooldownSettings.args.saved.args.items.args
                                        CooldownButtons.savedDB.profile.Items[itemID].save = true
                                        if not itemArgs[itemID] then
                                            itemArgs[itemID] = createItemConfigStuff(itemID)
                                        end
                                        addNewItemData = ""
LibStub("AceConfigDialog-3.0").Status["Cooldown Buttons"].children.cooldownSettings.children.saved.children.items.status.groups.selectedgroup = itemID
LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
                                    else
                                        terror.name = "|c00abcd00"..addNewItemData.."|r "..L["is not an valid ItemName/ID or the Item is not in local Itemcache."]
                                    end
                            end),
                            errorMessage = createDescription(""),
                        },
                    },
                },
            },
        },
    }
    --/dump CooldownButtons:GetModule("Config").options.args.cooldownSettings.args.saved.args.items.args
    local SpellsModule = CooldownButtons:GetModule("Spells")
    local spellArgs = options.args.cooldownSettings.args.saved.args.spells.args
    local spellTree = SpellsModule.treeTable
    for i = 2, GetNumSpellTabs() do
        spellArgs["00SpellTree_NR_"..i] = createSpellConfigStuff(spellTree[i].treeName, true)
    end
    for k, v in SpellsModule:IterateSpellTable() do
        if v.spellknownCD then
            spellArgs[v.spellID] = createSpellConfigStuff(k)
        end
    end

    local itemArgs = options.args.cooldownSettings.args.saved.args.items.args
    local ItemsModule = CooldownButtons:GetModule("Items")
    for k, v in pairs(CooldownButtons.savedDB.profile.Items) do
        itemArgs[tostring(k)] = createItemConfigStuff(k)
    end
end

function createSpellConfigStuff(cooldownName, isSpellTree)
    local db = CooldownButtons.savedDB.profile.Spells[cooldownName]
    local confname = (isSpellTree and "|c0000EB3F"..L["Spelltree: "].."|r"..cooldownName) or cooldownName
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

function createItemConfigStuff(itemID)
    local cooldownName = GetItemInfo(itemID)
    local _db = CooldownButtons.savedDB.profile.Items
    if not cooldownName then
        _db[itemID] = nil
        CooldownButtons:Print("ItemID "..itemID.." is invalid or not in local Itemcache.")
        return nil
    end
    local db = _db[itemID]
    return {
        type = "group",
        name = cooldownName,
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
            header_00 = createHeader(cooldownName),
            radioHide = createToggle(L["Hide Button"], "", "hide", true),
            radioSave = createToggle(L["Save Button Position"], "", "save", nil ,function() return db.hide end),

            desc = createDescription(L["Here you can Setup at what position the Cooldown Button for the selected Spell should be drawn to."]),
            pos_x = createInput(L["X - Axis"], L["Set the Position on X-Axis."], "posx", nil ,function() return db.hide end),
            pos_y = createInput(L["Y - Axis"], L["Set the Position on Y-Axis."], "posy", nil ,function() return db.hide end),

            showAnchor = createExecute(L["Show Movable Button"], "", itemID, function(k)
                local BarManager = CooldownButtons:GetModule("Bar Manager")
                if not BarManager.anchorDB[k.arg] then
                    k.option.name = L["Hide Movable Button"]
                    BarManager:ShowAnchor(k.arg, "Item")
                else
                    k.option.name = L["Show Movable Button"]
                    BarManager:HideAnchor(k.arg)
                end
                LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
            end, nil, function() return db.hide end),

            removeItem = createExecute(L["Remove"], "", itemID, function(k)
                local BarManager = CooldownButtons:GetModule("Bar Manager")
                if BarManager.anchorDB[k.arg] then
                    k.option.name = L["Show Movable Button"]
                    BarManager:HideAnchor(k.arg)
                end
                k.options.args[k[1]].args[k[2]].args[k[3]].args[k[4]] = nil
                _db[k.arg] = nil
                LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
            end),
        },
    }
end
