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
    
    cooldowns.type2bar = self:IniType2BarSettings()
    --cooldowns.groups = self:InitGroupSettings()
    cooldowns.hiddenCooldowns = self:InitHiddenCooldownSettings()
end	
    
function CDB_Options:InitHiddenCooldownSettings()
	local parent = API:createGroup(L["COOLDOWN_SUB_HIDDEN"], L["COOLDOWN_SUB_HIDDEN_DESC"])
	local db = {
		["hiddenCooldowns"] = CDB.db.profile.hiddenCooldowns,
	}
	local function notifyCfgChange(option) CDB.engine:UpdateConfig(name, db, option) end
	local function setGroupLabel(key, hidden)
		local color
		if hidden then
			color = "|cffff0000"
		else
			color = "|cff00ff00"
		end
		key.arg.group.name = color..key.arg.name.."|r"
	end
	local function getHidden(key)
		return db.hiddenCooldowns[key.arg.type][key.arg.name].hidden
	end
	local function setHidden(key, value)
		if( value == true ) then
			db.hiddenCooldowns[key.arg.type][key.arg.name].hidden = value
		else
			db.hiddenCooldowns[key.arg.type][key.arg.name] = nil
		end
		setGroupLabel(key, value)
		notifyCfgChange("hiddenCooldowns")
	end
			
	local translation = {["Item"] = "items", ["Spell"] = "spells"}
	local function addEntry(type, groupName, entryName)
		local path = translation[type]
		if (parent.args[path].args[groupName] == nil) then
			parent.args[path].args[groupName] = API:createGroup(entryName, "")
			local group = parent.args[path].args[groupName]
			
			local hiddenArg = {type = type, name = entryName, group = group}

			group.args.enabled = API:createToggle(L["COOLDOWN_HIDDEN_HIDE"], L["COOLDOWN_HIDDEN_HIDE_DESC"], hiddenArg)
			
			setGroupLabel({arg = hiddenArg}, getHidden({arg = hiddenArg}))            
		end
	end
	do -- Spells
		parent.args.spells = API:createGroup(L["COOLDOWN_HIDDEN_SPELLS"], L["COOLDOWN_HIDDEN_SPELLS_DESC"])
		for name, data in pairs(CDB.spells.spellTable) do
			if data.spellknownCD then
				local groupName = "spell_byId_"..data.spellID
				
				addEntry("Spell", groupName, name)
			end
		end
	end
	function CDB_Options:UpdateHiddenItemSettings()
		parent.args.items.args = {}    

		parent.args.items.args.guide = API:createDescription(L["COOLDOWN_HIDDEN_ITEMS_GUIDE"])
		
		for itemName, active in pairs(db.hiddenCooldowns.Item) do
			local groupName = "item_byName_"..itemName
			addEntry("Item", groupName, itemName)
		end
		for itemId, active in pairs(CDB.items.itemCooldowns) do
			local name = GetItemInfo(itemId)
			local groupName = "item_byName_"..name
			addEntry("Item", groupName, name)
		end
		LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
	end
	
	do -- Items
		parent.args.items = API:createGroup(L["COOLDOWN_HIDDEN_ITEMS"], L["COOLDOWN_HIDDEN_ITEMS_DESC"])
		self:UpdateHiddenItemSettings()
	end
	
	API:injectSetGet(parent, setHidden, getHidden)
	return parent
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

function CDB_Options:IniType2BarSettings()
    local parent = API:createGroup(L["COOLDOWN_SUB_TYPE2BAR"], L["COOLDOWN_SUB_TYPE2BAR_DESC"])
    local db = {
        ["bars"] = CDB.db.profile.bars,
        ["type2bar"] = CDB.db.profile.type2bar,
    }
    local type2bar = parent.args
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
    local function tableLength(T)
        local count = 0
        for _ in pairs(T) do count = count + 1 end
        return count
    end
    local function isEnabled(k)
        return tableLength(getBars(k)) <= 0
    end
    type2bar.spellheader = API:createHeader(L["COOLDOWN_TYPE2BAR_HEADER_SPELLS"])
    type2bar.spellinactive = API:createSelect(L["COOLDOWN_TYPE2BAR_ADD"], L["COOLDOWN_TYPE2BAR_ADD_DESC"], {obj = "Spell", mode = "add"}, getBars, nil, isEnabled)
    type2bar.spellactive = API:createSelect(L["COOLDOWN_TYPE2BAR_REMOVE"], L["COOLDOWN_TYPE2BAR_REMOVE_DESC"], {obj = "Spell", mode = "remove"}, getBars, nil, isEnabled)
    type2bar.petactionheader = API:createHeader(L["COOLDOWN_TYPE2BAR_HEADER_PETACTIONS"])
    type2bar.petactioninactive = API:createSelect(L["COOLDOWN_TYPE2BAR_ADD"], L["COOLDOWN_TYPE2BAR_ADD_DESC"], {obj = "PetAction", mode = "add"}, getBars, nil, isEnabled)
    type2bar.petactionactive = API:createSelect(L["COOLDOWN_TYPE2BAR_REMOVE"], L["COOLDOWN_TYPE2BAR_REMOVE_DESC"], {obj = "PetAction", mode = "remove"}, getBars, nil, isEnabled)
    type2bar.itemheader = API:createHeader(L["COOLDOWN_TYPE2BAR_HEADER_ITEMS"])
    type2bar.iteminactive = API:createSelect(L["COOLDOWN_TYPE2BAR_ADD"], L["COOLDOWN_TYPE2BAR_ADD_DESC"], {obj = "Item", mode = "add"}, getBars, nil, isEnabled)
    type2bar.itemactive = API:createSelect(L["COOLDOWN_TYPE2BAR_REMOVE"], L["COOLDOWN_TYPE2BAR_REMOVE_DESC"], {obj = "Item", mode = "remove"}, getBars, nil, isEnabled)
    
    local function notifyCfgChange(option) CDB.engine:UpdateConfig(name, db, option) end
    local function set(k, v)
        if k.arg.mode == "add" then
            db.type2bar[k.arg.obj][v] = true
        else -- k.arg.b == "remove"
            db.type2bar[k.arg.obj][v] = false
        end
        notifyCfgChange("type2bar") 
    end
    API:injectSetGet(parent, set, false)
    return parent
end
