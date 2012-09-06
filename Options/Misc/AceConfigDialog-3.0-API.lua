--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

CDB_OptionsApi = { }
local CDB_OptionsApi = CDB_OptionsApi
CDB_OptionsApi.optionOrder = 0
function CDB_OptionsApi:getOrder() self.optionOrder = self.optionOrder + 1; return self.optionOrder end

function CDB_OptionsApi:createGroup(name, desc, childGroups, disabled, hidden)
    return {
        type = "group",
        childGroups = childGroups,
        name = name,
        desc = desc,
        order = self:getOrder(),
        args = {},
        hidden = hidden,
        disabled = disabled,
    }
end

function CDB_OptionsApi:createHeader(name, hidden)
    return {
        type = "header",
        name = name,
        order = self:getOrder(),
        hidden = hidden,
    }
end

function CDB_OptionsApi:createDescription(name, hidden)
    return {
        type = "description",
        name = name,
        order = self:getOrder(),
        hidden = hidden,
    }
end

function CDB_OptionsApi:createInput(name, desc, arg, width, disabled, hidden)
    return {
        type = "input",
        name = name,
        desc = desc,
        order = self:getOrder(),
        arg = arg,
        width = width,
        disabled = disabled,
        hidden = hidden,
    }
end

function CDB_OptionsApi:createRange(name, desc, arg, mms, width, disabled, hidden)
    return {
        type = "range",
        name = name,
        desc = desc,
        order = self:getOrder(),
        min = mms[1], max = mms[2], step = mms[3],
        arg = arg,
        width = width,
        disabled = disabled,
        hidden = hidden,
    }
end

function CDB_OptionsApi:createFontSelect(name, desc, arg, values, width, disabled, hidden)
    return {
        type = "select",
        dialogControl = "LSM30_Font",
        name = name,
        desc = desc,
        order = self:getOrder(),
        values = values,
        arg = arg,
        width = width,
        disabled = disabled,
        hidden = hidden,
    }
end

function CDB_OptionsApi:createSelect(name, desc, arg, values, width, disabled, hidden)
    return {
        type = "select",
        name = name,
        desc = desc,
        order = self:getOrder(),
        values = values,
        arg = arg,
        width = width,
        disabled = disabled,
        hidden = hidden,
    }
end

function CDB_OptionsApi:createToggle(name, desc, arg, width, disabled, hidden)
    return {
        type = "toggle",
        name = name,
        desc = desc,
        order = self:getOrder(),
        arg = arg,
        width = width,
        disabled = disabled,
        hidden = hidden,
    }
end

function CDB_OptionsApi:createExecute(name, desc, arg, func, confirm, width, disabled, hidden)
    return {
        type = "execute",
        name = name,
        desc = desc,
        order = self:getOrder(),
        arg = arg,
        func = func,
        width = width,
        disabled = disabled,
        hidden = hidden,
        confirm = confirm and true,
        confirmText = confirm,
    }
end

function CDB_OptionsApi:createColor(name, desc, arg, alpha, width, disabled, hidden)
    return {
        type = "color",
        name = name,
        desc = desc,
        order = self:getOrder(),
        hasAlpha = alpha,
        arg = arg,
        width = width,
        disabled = disabled,
        hidden = hidden,
    }
end

function CDB_OptionsApi:injectSetGet(obj, set, get)
    obj.set = set
    obj.get = get
end
