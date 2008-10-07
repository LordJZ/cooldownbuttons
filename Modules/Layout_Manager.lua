--[[
Name: CooldownButtons
Project Revision: @project-revision@
File Revision: @file-revision@ 
Author(s): Netrox (netrox@sourceway.eu)
Website: http://www.wowace.com/projects/cooldownbuttons/
SVN: svn://svn.wowace.com/wow/cooldownbuttons/mainline/trunk
License: All rights reserved.
]]

local _G = _G
local CooldownButtons = _G.CooldownButtons
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
        self.barGroup.Colors   = db.LBF_Data.Colors
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

function LayoutManager:SkinChanged(SkinID, Gloss, Backdrop, Group, Button, Colors)
--    if Group then
        local db = CooldownButtons.db.profile.barSettings.Spells
        db.LBF_Data.SkinID   = SkinID
        db.LBF_Data.Gloss    = Gloss
        db.LBF_Data.Backdrop = Backdrop
        db.LBF_Data.Colors   = Colors
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
    