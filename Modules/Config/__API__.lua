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

do
    local optionOrder = 0
    local function getOrder() optionOrder = optionOrder + 1; return optionOrder end
    local createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor
    
    function createHeader(name, hidden)
        return {
            type = "header",
            name = name,
            order = getOrder(),
            hidden = hidden,
        }
    end

    function createDescription(name, hidden)
        return {
            type = "description",
            name = name,
            order = getOrder(),
            hidden = hidden,
        }
    end

    function createInput(name, desc, arg, full, disabled, hidden)
        return {
            type = "input",
            name = name,
            desc = desc,
            order = getOrder(),
            arg = arg,
            width = full and "full",
            disabled = disabled,
            hidden = hidden,
        }
    end

    function createRange(name, desc, arg, mms, full, disabled, hidden)
        return {
            type = "range",
            name = name,
            desc = desc,
            order = getOrder(),
            min = mms[1], max = mms[2], step = mms[3],
            arg = arg,
            width = full and "full",
            disabled = disabled,
            hidden = hidden,
        }
    end

    function createSelect(name, desc, arg, values, full, disabled, hidden)
        return {
            type = "select",
            name = name,
            desc = desc,
            order = getOrder(),
            values = values,
            arg = arg,
            width = full and "full",
            disabled = disabled,
            hidden = hidden,
        }
    end

    function createToggle(name, desc, arg, full, disabled, hidden)
        return {
            type = "toggle",
            name = name,
            desc = desc,
            order = getOrder(),
            arg = arg,
            width = full and "full",
            disabled = disabled,
            hidden = hidden,
        }
    end

    function createExecute(name, desc, arg, func, full, disabled, hidden)
        return {
            type = "execute",
            name = name,
            desc = desc,
            order = getOrder(),
            arg = arg,
            func = func,
            width = full and "full",
            disabled = disabled,
            hidden = hidden,
        }
    end

    function createColor(name, desc, arg, alpha, full, disabled, hidden)
        return {
            type = "color",
            name = name,
            desc = desc,
            order = getOrder(),
            hasAlpha = alpha,
            arg = arg,
            width = full and "full",
            disabled = disabled,
            hidden = hidden,
        }
    end

    function CooldownButtonsConfig:GetWidgetAPI()
        return getOrder, createHeader, createDescription, createInput, createRange, createSelect, createToggle, creteExecute, createColor
    end
end
