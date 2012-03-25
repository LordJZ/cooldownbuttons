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

    function createFontSelect(name, desc, arg, values, full, disabled, hidden)
        return {
            type = "select",
            dialogControl = "LSM30_Font",
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
