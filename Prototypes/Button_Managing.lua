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

local _G = _G
local CooldownButtons = _G.CooldownButtons
CooldownButtons:CheckVersion("$Revision$")
local L = CooldownButtons.L
local LSM = LibStub("LibSharedMedia-3.0")

---
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
local math_floor = math.floor
local math_ceil  = math.ceil
---

-- Database
local InstanceList = {}
local buttonList   = {}
local buttonCount  = {}

local ButtonEngine = {}
function CooldownButtons.defaultModulePrototype:InitButtonEngine()
    local handle = self.name
    if not InstanceList[handle] then
        InstanceList[handle] = true
        buttonList[handle]   = {}
        buttonCount[handle]  = 0
        -- Embed ButtonEngine Stuff
        for name, func in pairs(ButtonEngine) do
            self[name] = func
        end
    end
end

function ButtonEngine:NewButton()
    local handle = self.name
    buttonCount[handle] = buttonCount[handle] + 1
    i = buttonCount[handle]
    -- Create button
    local button = CreateFrame("Button", handle.."_"..i, UIParent, "ActionButtonTemplate")
    buttonList[handle][buttonCount[handle]] = button
    --Setup Button
    button:SetClampedToScreen(true)

    button.module = self:GetName()
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self) if self:IsMovable() then self.movin = true; self:StartMoving(); end end)
    button:SetScript("OnDragStop",  function(self) if self:IsMovable() then self:StopMovingOrSizing(); self:SaveAnchorPos() end end )
    button.SaveAnchorPos = function(self)
        if self.module == "Saved" then
            local kind = (((self.cd.type == "Item") and "Items") or (((self.cd.type == "Spell") or (self.cd.type == "PetAction")) and "Spells"))
            local db = CooldownButtons.savedDB.profile[kind][self.cd.name]
            local module = CooldownButtons:GetModule(self.module)
            db.pos.x = self:GetLeft() * module.db.buttonScale
            db.pos.y = self:GetBottom() * module.db.buttonScale
            self.anchorPos.x = db.pos.x
            self.anchorPos.y = db.pos.y
        else
            local module = CooldownButtons:GetModule(self.module)
            module.db.pos.x = self:GetLeft() * module.db.buttonScale
            module.db.pos.y = self:GetBottom() * module.db.buttonScale
        end
        LibStub("AceConfigRegistry-3.0"):NotifyChange("Cooldown Buttons")
        self.movin = false
    end

    button.texture  = _G[("%sIcon"):format(button:GetName())]
    button.cooldown = _G[("%sCooldown"):format(button:GetName())]

    -- Add Button to ButtonFacade/cyCircled Support
    CooldownButtons:GetModule("Layout"):AddElement(self:GetName(), button:GetName())
    
    button.used = false

    button.cooldown.noCooldownCount = 1

    button.textFrame = CreateFrame("Frame", "CooldownButton"..i.."CooldownText", UIParent)
    button.textFrame:SetAllPoints(button)
    button.textFrame:SetFrameLevel(button.cooldown:GetFrameLevel() + 1)
    button.text = button.textFrame:CreateFontString(nil, "OVERLAY")
    button.text:SetFontObject(SystemFont)

    button.pulse = CreateFrame('Frame', nil, button)
    button.pulse:SetAllPoints(button)
    button.pulse:SetToplevel(true)
    button.pulse.icon = button:CreateTexture(nil, 'OVERLAY')
    button.pulse.icon:SetPoint('CENTER')
    button.pulse.icon:SetBlendMode('ADD')
    button.pulse.icon:SetHeight(button:GetHeight())
    button.pulse.icon:SetWidth(button:GetWidth())
    button.pulse.icon:Hide()
    button.pulse.cooldownName = ""
    button.pulse.module = button.module
    button.pulseActive = false
    
    button.id = buttonCount[handle]
    return button, buttonCount[handle]
end

function ButtonEngine:GetButton(id)
    local handle = self.name
    if id and buttonList[handle][id] then
        return buttonList[handle][id], id
    end
end

function ButtonEngine:GetFreeButton()
    local handle = self.name
    for i = 1, buttonCount[handle] do
        if buttonList[handle][i].used == false then
            return self:GetButton(i)
        end
    end
    return self:NewButton()
end

function ButtonEngine:IterateButtons()
    return pairs(buttonList[self.name])
end

function ButtonEngine:DrawButton(buttonID, order, savedPos)
    local handle = self.name
    local button = buttonList[handle][buttonID]
    button:Show()
    button:ClearAllPoints()

    local nCC = button.cooldown.noCooldownCount
    if ((nCC == nil and self.db.showOmniCC == false) or (nCC == 1 and self.db.showOmniCC == true)) then
        if not self.db.showOmniCC then
            button.cooldown.noCooldownCount = 1
        else
            button.cooldown.noCooldownCount = nil
        end
        button.cooldown:SetCooldown(self:GetCooldown(button.cooldown.spell))
    end
    if not self.db.showSpiral then
        button.cooldown:SetAlpha(0)
    else
        button.cooldown:SetAlpha(1)
    end

    -- if not showCenter then [order] else [calcuclate] end
    local centerOffset = ((not self.db.showCenter and order) or (order + 0.5 - (self:GetNumCooldowns() / 2)))

    local pos
    if savedPos and (type(savedPos) == "table") then
        pos = newDict("x", savedPos.x, "y", savedPos.y)
        pos.x = pos.x / self.db.buttonScale
        pos.y = pos.y / self.db.buttonScale
    else
        pos = self:GetPosition(order, centerOffset)
        pos.x = pos.x + (self.db.pos.x / self.db.buttonScale)
        pos.y = pos.y + (self.db.pos.y / self.db.buttonScale)
    end
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", pos.x , pos.y)
    pos = del(pos)

    button:SetScale(self.db.buttonScale)
    button:SetAlpha(self.db.buttonAlpha)
end

function ButtonEngine:GetPosition(order, centerOffset)
    local pos = newDict("x", 0, "y", 0)
    if self.db.buttonMultiRow then
        if order <= self.db.buttonCountPerRow then
            pos.x = self.db.buttonSpacing * (centerOffset - 1)
            pos.y = 0
        else
            local row = math_ceil(centerOffset / self.db.buttonCountPerRow) -1
            pos.x = self.db.buttonSpacing * (centerOffset - 1 - (self.db.buttonCountPerRow * row))
            pos.y = self.db.buttonRowSpacing * row
        end
        if self.db.buttonMRDirection == "right-down" then
            --pos.x = pos.x
            pos.y = pos.y * (-1)
        --elseif self.db.buttonMRDirection == "right-up" then
            --pos.x = pos.x
            --pos.y = pos.y
        elseif self.db.buttonMRDirection == "left-down" then
            pos.x = pos.x * (-1)
            pos.y = pos.y * (-1)
        elseif self.db.buttonMRDirection == "left-up" then 
            pos.x = pos.x * (-1)
            --pos.y = pos.y
        end
    else
        pos.x = self.db.buttonSpacing * (centerOffset - 1)
        pos.y = 0
        if self.db.buttonDirection == "left" then
            pos.x = pos.x * (-1)
            --pos.y = pos.y
        --elseif self.db.buttonDirection == "right" then
            --pos.x = pos.x
            --pos.y = pos.y
        elseif self.db.buttonDirection == "up" then
            pos.y = pos.x
            pos.x = 0
        elseif self.db.buttonDirection == "down" then 
            pos.y = pos.x * (-1)
            pos.x = 0
        end
    end
    return pos
end

function ButtonEngine:ButtonUpdateTimer(buttonID, time)
    local handle = self.name
    local button = buttonList[handle][buttonID]
    if self.db.showTime and not self.db.showOmniCC then
        button.text:Show()
        local c = self.db.fontColorBase
        if self.db.triggerColorFlash and (time <= self.db.colorFlashStartTime) then
            if (math_floor(time) % 2) == 0 then
                c = self.db.fontColorFlash1
            else
                c = self.db.fontColorFlash2
            end
        end
        button.text:SetTextColor(c.Red, c.Green,  c.Blue)
        button.text:SetText(self:formatCooldownTime(time, true))

        button.text:ClearAllPoints()
        local textDirection = self.db.textDirection
        local textDistance = self.db.textDistance
        if textDirection == "left" then
            button.text:SetPoint("RIGHT", button, "CENTER", -(textDistance), 0)
            button.text:SetJustifyH("RIGHT") 
        elseif textDirection == "right" then
            button.text:SetPoint("LEFT", button, "CENTER",   textDistance, 0)
            button.text:SetJustifyH("LEFT") 
        elseif textDirection == "up" then
            button.text:SetPoint("CENTER", button, "CENTER", 2, textDistance   )
            button.text:SetJustifyH("CENTER") 
        elseif textDirection == "down" then 
            button.text:SetPoint("CENTER", button, "CENTER", 2, -(textDistance))
            button.text:SetJustifyH("CENTER") 
        end
        button.text:SetFont(LSM:Fetch("font", self.db.fontFace), self.db.fontSize, "OUTLINE")
        button.text:SetTextColor(c.Red, c.Green,  c.Blue)
        button.text:SetAlpha(self.db.textAlpha)
    else
        button.text:Hide()
    end
end
