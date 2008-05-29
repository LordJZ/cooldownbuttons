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

--if true then return end

local _G = _G
local CooldownButtons = _G.CooldownButtons
CooldownButtons:CheckVersion("$Revision$")
local LayoutManager = CooldownButtons:NewModule("Layout Manager")
local L = CooldownButtons.L

local LBF = LibStub("LibButtonFacade", true)

---
local string_gsub = string.gsub
local table_insert = table.insert
---

local addonName  = "CooldownButtons"
local cyTemplate = {}

function LayoutManager:Setup()
    self.LayoutMod = false
    if LBF then
        self.LayoutMod = "LBF"
		LBF:RegisterSkinCallback("Cooldown Buttons", self.SkinChanged, self)
    elseif IsAddOnLoaded("cyCircled") then
        self.LayoutMod = "cyCircled"
        _G.cyCircled_CooldownButtons = cyCircled:NewModule(addonName)
        for name, func in pairs(cyTemplate) do
            _G.cyCircled_CooldownButtons[name] = func
        end
        _G.cyCircled_CooldownButtons:AddBar() -- AddBar On Setup
    end
    self:AddBar("Cooldown Buttons")
end

function LayoutManager:AddBar(barName)
    if not self.LayoutMod then
        return
    elseif self.LayoutMod == "LBF" then
        self.barGroup = LBF:Group("Cooldown Buttons", barName)
        local db = CooldownButtons.db.profile.barSettings.Spells
        self.barGroup.SkinID   = db.LBF_Data.SkinID
        self.barGroup.Backdrop = db.LBF_Data.Backdrop
        self.barGroup.Gloss    = db.LBF_Data.Gloss
--    elseif self.LayoutMod == "cyCircled" then
--        _G.cyCircled_CooldownButtons:AddBar()
    end
end

function LayoutManager:AddElement(barName, buttonName)
    if not self.LayoutMod then
        return
    elseif self.LayoutMod == "LBF" then
        self.barGroup:AddButton(_G[buttonName])
    elseif self.LayoutMod == "cyCircled" then
        _G.cyCircled_CooldownButtons:AddElement(buttonName)
    end
end

function LayoutManager:SkinChanged(SkinID, Gloss, Backdrop, Group)
--    if Group then
        local db = CooldownButtons.db.profile.barSettings.Spells
        db.LBF_Data.SkinID   = SkinID
        db.LBF_Data.Gloss    = Gloss
        db.LBF_Data.Backdrop = Backdrop
--    else
--        for _, db in pairs(CooldownButtons.db.profile.barSettings) do
--            db.LBF_Data.SkinID   = SkinID
--            db.LBF_Data.Gloss    = Gloss
--            db.LBF_Data.Backdrop = Backdrop
--        end
--    end
end

-------------------------------
-- cyCircled Module Template --
-------------------------------

cyTemplate.defaultCfg = {}
cyTemplate.elements = {}
function cyTemplate:AddonLoaded()
    self.db = cyCircled:AcquireDBNamespace(addonName)
    cyCircled:RegisterDefaults(addonName, "profile", self.defaultCfg)
end

function cyTemplate:GetElements()
    return self.defaultCfg
end

function cyTemplate:AddBar()
    self.defaultCfg["Cooldowns"] = true
    self.elements = {
        ["Cooldowns"] = {
            args = {
                button = { width = 35, height = 35, },
                parentname = false,
            },
            elements = {}, 
        },
    }
end

function cyTemplate:AddElement(buttonName)
    table_insert(self.elements["Cooldowns"].elements, buttonName)
    self:ApplySkin()
    self:ApplyColors()
end
    