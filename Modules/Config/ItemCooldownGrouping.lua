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

local CooldownButtons = _G.CooldownButtons
CooldownButtons:CheckVersion("$Revision$")
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
