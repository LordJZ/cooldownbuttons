--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local CDB_Options = CDB_Options
local API = CDB_OptionsApi
local L = CDB.L

local string_find = string.find

function CDB_Options:LoadCooldownSettings()
    self.options.args.cooldowns = API:createGroup(L["GROUP_COOLDOWN"], L["GROUP_COOLDOWN_DESC"])
    local cooldowns = self.options.args.cooldowns.args
    
    cooldowns.cd2bar = self:InitCD2BarSettings()
    cooldowns.groups = self:InitGroupSettings()
end

function CDB_Options:InitGroupSettings()
    local parent = API:createGroup(L["COOLDOWN_SUB_GROUPS"], L["COOLDOWN_SUB_GROUPS_DESC"])
    local db = {
        ["cooldownSets"] = CDB.db.profile.cooldownSets,
    }
    parent.args.name = API:createInput(L["COOLDOWN_GROUPS_NEW_NAME"], L["COOLDOWN_GROUPS_NEW_NAME_DESC"], "name")
    parent.args.type = API:createSelect(L["COOLDOWN_GROUPS_NEW_TYPE"], L["COOLDOWN_GROUPS_NEW_TYPE_DESC"], "type", {})
    parent.args.okay = API:createExecute(L["COOLDOWN_GROUPS_NEW_CREATE"], L["COOLDOWN_GROUPS_NEW_CREATE_DESC"], "", createNewExec, nil, "double")
--API:injectSetGet(bars.createnew.args.name, function(k, v) newbarname = v end, function(k) return newbarname end) 

    local groups = parent.args
    groups.subSpell = API:createGroup(L["COOLDOWN_GROUPS_SUB_SPELLS"], L["COOLDOWN_GROUPS_SUB_SPELLS_DESC"])
    groups.subItem = API:createGroup(L["COOLDOWN_GROUPS_SUB_ITEMS"], L["COOLDOWN_GROUPS_SUB_ITEMS_DESC"])
    for name, data in pairs(db.cooldownSets) do
        local entry = groups["sub"..data.type].args
        entry[name] = API:createGroup(name)
        entry[name].args.header = API:createHeader(name)
        if data.type == "Item" then entry[name].args.groupsdesc = API:createDescription(L["COOLDOWN_GROUPS_DESCRIPTION_ITEMS"]) end
        entry[name].args.remove = API:createSelect(L["COOLDOWN_GROUPS_REMOVE"], L["COOLDOWN_GROUPS_REMOVE_DESC"], "remove", {mode = "remove", name = name, data = data,})
        entry[name].args.remove.dialogControl = "CDB_DROPDOWN"
        if data.type == "Spell" then
            local function getAddList()
                local spells = { type = "Spell", ids = {}, }
                for k, v in pairs(CDB.spells.spellTable) do
                    if v.spellknownCD then
                        spells.ids[v.spellID] = true
                    end
                end
                return spells
            end
            entry[name].args.add = API:createSelect(L["COOLDOWN_GROUPS_ADD_SPELL"], L["COOLDOWN_GROUPS_ADD_SPELL_DESC"], "add", {mode = "add", name = name, data = getAddList(),})
            entry[name].args.add.dialogControl = "CDB_DROPDOWN"
        else --data.type == "Item"
            entry[name].args.adddesc = API:createDescription("\n\n\n"..L["COOLDOWN_GROUPS_ADD_ITEM_EXTRA_DESC"])
            entry[name].args.add = API:createInput(L["COOLDOWN_GROUPS_ADD_ITEM"], L["COOLDOWN_GROUPS_ADD_ITEM_DESC"], "add")
            entry[name].args.okay = API:createExecute(L["COOLDOWN_GROUPS_ADD_BUTTON"], L["COOLDOWN_GROUPS_ADD_BUTTON_DESC"], "", function() end)
        end
    end
    
    API:injectSetGet(parent, false, false)
    return parent
end

function CDB_Options:InitCD2BarSettings()
    local parent = API:createGroup(L["COOLDOWN_SUB_CD2BAR"], L["COOLDOWN_SUB_CD2BAR_DESC"])
    local db = {
        ["bars"] = CDB.db.profile.bars,
        ["type2bar"] = CDB.db.profile.type2bar,
    }
    local cd2bar = parent.args
    local function getBars(k)
        local t = {}
        for name, _ in pairs(db.bars) do
            if k.arg.mode == "remove" then
                if db.type2bar[k.arg.obj][name] then
                    t[name] = name
                end
            else
                if not db.type2bar[k.arg.obj][name] then
                    t[name] = name
                end
            end
        end
        return t
    end
    cd2bar.spellheader = API:createHeader(L["COOLDOWN_CD2BAR_HEADER_SPELLS"])
    cd2bar.spellactive = API:createSelect(L["COOLDOWN_CD2BAR_REMOVE"], L["COOLDOWN_CD2BAR_REMOVE_DESC"], {obj = "Spell", mode = "remove"}, getBars)
    cd2bar.spellinactive = API:createSelect(L["COOLDOWN_CD2BAR_ADD"], L["COOLDOWN_CD2BAR_ADD_DESC"], {obj = "Spell", mode = "add"}, getBars)
    cd2bar.petactionheader = API:createHeader(L["COOLDOWN_CD2BAR_HEADER_PETACTIONS"])
    cd2bar.petactionactive = API:createSelect(L["COOLDOWN_CD2BAR_REMOVE"], L["COOLDOWN_CD2BAR_REMOVE_DESC"], {obj = "PetAction", mode = "remove"}, getBars)
    cd2bar.petactioninactive = API:createSelect(L["COOLDOWN_CD2BAR_ADD"], L["COOLDOWN_CD2BAR_ADD_DESC"], {obj = "PetAction", mode = "add"}, getBars)
    cd2bar.itemheader = API:createHeader(L["COOLDOWN_CD2BAR_HEADER_ITEMS"])
    cd2bar.itemactive = API:createSelect(L["COOLDOWN_CD2BAR_REMOVE"], L["COOLDOWN_CD2BAR_REMOVE_DESC"], {obj = "Item", mode = "remove"}, getBars)
    cd2bar.iteminactive = API:createSelect(L["COOLDOWN_CD2BAR_ADD"], L["COOLDOWN_CD2BAR_ADD_DESC"], {obj = "Item", mode = "add"}, getBars)
    local function set(k, v)
        if k.arg.mode == "add" then
            db.type2bar[k.arg.obj][v] = true
        else -- k.arg.b == "remove"
            db.type2bar[k.arg.obj][v] = false
        end
    end
    API:injectSetGet(parent, set, false)
    return parent
end
