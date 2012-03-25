--[[
Name: CooldownButtons
Project Revision: 223
File Revision: 183 
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

local getName, setName, createNewGroup
function CooldownButtonsConfig:ItemCooldownGroupingConfig()
    self.ItemCooldownGroupingConfigIsSet = true
    
    local options = self.options
    options.args.cooldownSettings.args.itemgrouping = {
        type = "group",
        name = "Cooldown Grouping",
        order = getOrder(),
        set = setName,
        get = getName,
        hidden = true,
        args = {
            bla = createDescription("Under construction ..."),
            groupName = createInput("New Group", "Enter a Group Name.", "newGroupName"),
            createGroupe = createExecute("Create Group", "", "newGroupName", createNewGroup),
        },
    }
--    for iterate itemgroups .... do
--        options.args.cooldownSettings.args.itemgrouping.args["groupStuff"] = {
--        }
--    end
end

do
    local groupName = ""
    function createNewGroup()
        ChatFrame1:AddMessage("These function will create a Group called \""..groupName.."\" sometimes... maybe...")
    end
    
    function getName(k)
        return groupName
    end
    
    function setName(k,v)
        groupName = v
    end
end
