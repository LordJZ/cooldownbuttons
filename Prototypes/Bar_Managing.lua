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
local LS2 = LibStub("LibSink-2.0")

local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()

-- Database
local InstanceList = {}
local OnUpdateList = {}
local LBFGroupList = {}

local BarEngine = {}
function CooldownButtons.defaultModulePrototype:InitBarEngine(noUpdate)
    local handle = self.name
    if not InstanceList[handle] then
        InstanceList[handle] = true
        --LBFGroupList[handle] = nil
        -- Embed BarEngine Stuff
        for name, func in pairs(BarEngine) do
            self[name] = func
        end
        if not noUpdate then
            -- Embed AceTimer Stuff if not embeded yet
            if not LibStub("AceTimer-3.0").embeds[self] then
                LibStub("AceTimer-3.0"):Embed(self)
            end
            OnUpdateList[handle] = self:ScheduleRepeatingTimer("OnUpdate", 0.25)
            -- Add Bar to ButtonFacade/cyCircled Support
            CooldownButtons:GetModule("Layout"):AddBar(self:GetName())
        elseif noUpdate == "save" then
            -- Embed AceTimer Stuff if not embeded yet
            if not LibStub("AceTimer-3.0").embeds[self] then
                LibStub("AceTimer-3.0"):Embed(self)
            end
            OnUpdateList[handle] = self:ScheduleRepeatingTimer("OnUpdateSaved", 0.25)
            -- Add Bar to ButtonFacade/cyCircled Support
            CooldownButtons:GetModule("Layout"):AddBar(self:GetName())
        else
        end
    end
end

function BarEngine:GetLBFBarGroup(handler)
    return LBFGroupList[handler]
end

function BarEngine:SetLBFBarGroup(handler, barGroup)
    LBFGroupList[handler] = barGroup
end

local pulseHandler
function BarEngine:OnUpdate()
    --local handle = self.name
    for k, v in self:IterateCooldowns() do
        local cooldownName = k
        local cooldownData = v
        local db = CooldownButtons.savedDB.profile[self:GetName()][cooldownName]
        if db.save == true then -- drop Cooldown from normal loop becouse it is saved
            self:unregisterCooldown(cooldownName, true)
        else
            local start, duration = self:GetCooldown(cooldownName)
            local time = start + duration - GetTime()
            local hideFrame = false or ((not start) or (start == 0))
            if hideFrame then
                if self.db.showPulse then
                    local button = self:GetButton(cooldownData["buttonID"])
                    if not button.pulseActive then
                        if LS2 then
                            local message = CooldownButtons:gsub(CooldownButtons.db.profile.LibSinkAnnouncmentMessage, "$cooldown", cooldownName)
                            LS2.Pour(CooldownButtons, message, 1, 1, 1, nil, nil, nil, nil, nil, cooldownData["texture"])
                        end
                        button.pulse.cooldownName = cooldownName
                        button.pulse:SetScript("OnUpdate", function(self, elapsed) pulseHandler(self.cooldownName, self.module, elapsed) end)
                    end
                else
                    if LS2 then
                        local message = CooldownButtons:gsub(CooldownButtons.db.profile.LibSinkAnnouncmentMessage, "$cooldown", cooldownName)
                        LS2.Pour(CooldownButtons, message, 1, 1, 1, nil, nil, nil, nil, nil, cooldownData["texture"])
                    end
                    self:unregisterCooldown(cooldownName)
                end
            else
                if cooldownData["order"] <= self.db.buttonCount then
                    self:DrawButton(cooldownData["buttonID"], cooldownData["order"])
                    self:ButtonUpdateTimer(cooldownData["buttonID"], time)
                else
                    local frame = self:GetButton(cooldownData["buttonID"])
                    frame:Hide()
                    frame.text:Hide()
                end
            end
        end
    end
    if self.anchorVisible and not self:GetButton(self.anchorID).movin then
        self:DrawButton(self.anchorID, ((not self.db.showCenter and 0) or (0.5 + (self:GetNumCooldowns() / 2))) + 1)
    end
end

function BarEngine:OnUpdateSaved()
    for k, v in self:IterateCooldowns() do
        local cooldownName = k
        local cooldownData = v
        local kind = (((v.type == "Item") and "Items") or (((v.type == "Spell") or (v.type == "PetAction")) and "Spells"))
        local db = CooldownButtons.savedDB.profile[kind][cooldownName]
        if db.save == false then -- drop Cooldown from saved loop becouse it is NOT saved
            self:unregisterCooldown(cooldownName, true)
        else
            local start, duration = self:GetCooldown(cooldownName)
            local time = start + duration - GetTime()
            local hideFrame = false or ((not start) or (start == 0))
            if hideFrame then
                if LS2 then
                    local message = CooldownButtons:gsub(CooldownButtons.db.profile.LibSinkAnnouncmentMessage, "$cooldown", cooldownName)
                    LS2.Pour(CooldownButtons, message, 1, 1, 1, nil, nil, nil, nil, nil, cooldownData["texture"])
                end
                if self.db.showPulse then
                    local button = self:GetButton(cooldownData["buttonID"]) -- <- this is line 35
                    if not button.pulseActive then
                        button.pulse.cooldownName = cooldownName
                        button.pulse:SetScript("OnUpdate", function(self, elapsed) pulseHandler(self.cooldownName, self.module, elapsed) end)
                    end
                else
                    self:unregisterCooldown(cooldownName)
                end
            else
                self:DrawButton(cooldownData["buttonID"], 0, {x = db.pos.x, y = db.pos.y})
                self:ButtonUpdateTimer(cooldownData["buttonID"], time)
            end
        end
    end
    local anchor = self:GetButton(self.anchorID)
    if self.anchorVisible and not anchor.movin then
        self:DrawButton(self.anchorID, 0, anchor.anchorPos)
    end
end

function pulseHandler(cooldownName, modulName, elapsed)
    local module = CooldownButtons:GetModule(modulName)
    local cooldown = module:GetCooldown(cooldownName, true)
    local frame = module:GetButton(cooldown["buttonID"])
    if not frame.pulseActive then
        local icon = frame.texture
        if icon and frame:IsVisible() then
            local pulse = frame.pulse
            if pulse then
                pulse.scale = 1
                pulse.icon:SetTexture(icon:GetTexture())
                local r, g, b = icon:GetVertexColor()
                pulse.icon:SetVertexColor(r, g, b, 0.7)
                frame.pulseActive = true
            end
        end
    else
        local pulse = frame.pulse
        if pulse.scale >= 2 then
            pulse.dec = 1
        end
        pulse.scale = max(min(pulse.scale + (pulse.dec and -1 or 1) * pulse.scale * (elapsed/0.5), 2), 1)
        if pulse.scale <= 1 then
            pulse.icon:Hide()
            pulse.dec = nil
            frame.pulseActive = false
            module:unregisterCooldown(cooldownName)
            pulse:SetScript("OnUpdate", nil)
        else
            pulse.icon:Show()
            pulse.icon:SetHeight(pulse:GetHeight() * pulse.scale)
            pulse.icon:SetWidth(pulse:GetWidth() * pulse.scale)
        end
    end
end

function BarEngine:ShowAnchor()
    local anchor, id = self:GetFreeButton()
    self.anchorID = id
    self.anchorVisible = true
    anchor.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
    anchor:SetMovable(true)
    anchor.used = true
    anchor:SetFrameStrata("HIGH")
    self:DrawButton(id, ((not self.db.showCenter and 0) or (0.5 + (self:GetNumCooldowns() / 2))) + 1)
end

function BarEngine:HideAnchor()
    local anchor, id = self:GetButton(self.anchorID)
    self.anchorVisible = false
    anchor:SetMovable(false)
    anchor.used = false
    anchor:SetFrameStrata("MEDIUM")
    anchor:Hide()
end

function BarEngine:ShowSavedAnchor(db, kind, name)
    local anchor, id = self:GetFreeButton()
    self.anchorID = id
    self.anchorVisible = true
    anchor.anchorPos = newDict("x", db.pos.x, "y", db.pos.y)
    anchor.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
    anchor:SetMovable(true)
    anchor.used = true
    anchor.cd = newDict("type", kind, "name", name)
    anchor:SetFrameStrata("HIGH")
    self:DrawButton(id, 0, anchor.anchorPos)
end

function BarEngine:HideSavedAnchor()
    local anchor, id = self:GetButton(self.anchorID)
    self.anchorVisible = false
    anchor.anchorPos = del(anchor.anchorPos)
    anchor:SetMovable(false)
    anchor.used = false
    anchor.cd = del(anchor.cd)
    anchor:SetFrameStrata("MEDIUM")
    anchor:Hide()
end

