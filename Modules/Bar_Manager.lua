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
local BarManager = CooldownButtons:NewModule("Bar Manager", "AceTimer-3.0")
local L = CooldownButtons.L
local CooldownManager = CooldownButtons:GetModule("Cooldown Manager")
local ButtonManager = CooldownButtons:GetModule("Button Manager")
local LS2 = LibStub("LibSink-2.0")

------
local newList, newDict, del, deepDel, deepCopy = CooldownButtons.GetRecyclingFunctions()
------

function BarManager:OnInitialize()
    self.bars = {"Spells", "Items", "Expiring", "Saved"}
end

function BarManager:OnEnable()
    self.db = {["G"] = CooldownButtons.db.profile,}
    for k, v in ipairs(self.bars) do
        self.db[v] = CooldownButtons:GetBarSettings(v)
    end
    self.anchorDB = {}
    
    self:ScheduleRepeatingTimer("OnUpdate",0.5)
end

function BarManager:FireSinkMessage(cooldownName, texture)
    if LS2 then
        local message = CooldownButtons:gsub(CooldownButtons.db.profile.LibSinkAnnouncmentMessage, "$cooldown", cooldownName)
        message = CooldownButtons:gsub(message, "$icon", "|T"..texture.."::|t")
        local tex = ((CooldownButtons.db.profile.LibSinkAnnouncmentShowTexture and texture) or nil)
        local c = CooldownButtons.db.profile.LibSinkAnnouncmentColor
        LS2.Pour(CooldownButtons, message, c.Red, c.Green, c.Blue, nil, nil, nil, nil, nil, tex)
    end
end

function BarManager:OnUpdate()
    for k, v in CooldownManager:IterateCooldowns() do
        if CooldownButtons.db.profile.moveItemsToSpells and (v.bar == "Items") 
        or not CooldownButtons.db.profile.moveItemsToSpells and ((v.bar ~= "Items") and v.kind == "Item") then
            CooldownManager:sortCooldowns()
        end
        if true then -- false if drop due to  moveItemsToSpells decision
            local start, duration = _G["Get"..v.kind.."Cooldown"](v.id, BOOKTYPE_SPELL)
            local time = start + duration - GetTime()
            if false or ((not start) or (start == 0)) then--hideFrame
                if not v.hide then
                    if self.db[v.bar].showPulse then
                        local button = ButtonManager:GetButton(v.button)
                        if not button.pulseActive then
                            self:FireSinkMessage(v.name, v.tex)
                            button.pulse.cIdx = v.idx
                            button.pulse:SetScript("OnUpdate", button.pulse.pulseHandler)
                        end
                    else
                        self:FireSinkMessage(v.name, v.tex)
                        CooldownManager:Remove(v.idx)
                    end
                else -- Silently Remove if hidden, _MAYBE_ later with announcement :)
                    CooldownManager:Remove(v.idx)
                end
            else
                if not v.hide then
                    local expiring = CooldownManager:CheckExpiring(v)
                    local saved = CooldownManager:CheckSaved(v)
                    if ((saved) and v.bar ~= "Saved") or ((not saved) and (v.bar == "Saved")) then
                        CooldownManager:TriggerSaved(k)
                    end
                    if ((expiring) and v.bar ~= "Expiring") or ((not expiring) and (v.bar == "Expiring")) then
                        CooldownManager:TriggerExpired(k)
                    end
                    ButtonManager:DrawButton(v, self.db[v.bar])
                end
            end
        end
    end
    for k, v in pairs(self.anchorDB) do
        if not ButtonManager:GetButton(self.anchorDB[k].button).movin then
            ButtonManager:DrawAnchor(self.anchorDB[k], self.db[k] or self.db[v.bar])
        end
    end
end

function BarManager:ShowAnchor(module, kind)
    local anchor, id = ButtonManager:GetButton()
    self.anchorDB[module] = newDict(
        "button", id,
        "kind", kind,
        "name", kind and module,
        "id"  , kind and module,
        "bar" , kind and "Saved"
    )
    anchor.texture:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")
    anchor:SetMovable(true)
    anchor:EnableMouse(true)
    anchor.used = true
    anchor.anchorIdx = module
    anchor:SetFrameStrata("HIGH")
    anchor.cooldown:SetCooldown(0, 0)
    anchor.text:Hide()
    ButtonManager:DrawAnchor(self.anchorDB[module], self.db[module] or self.db[self.anchorDB[module].bar])
end

function BarManager:HideAnchor(module)
    local anchor, id = ButtonManager:GetButton(self.anchorDB[module].button)
    self.anchorDB[module] = deepDel(self.anchorDB[module])
    anchor:SetMovable(false)
    anchor:EnableMouse(false)
    anchor.used = false
    anchor:SetFrameStrata("MEDIUM")
    anchor:Hide()
end
